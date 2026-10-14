import SwiftUI

/// ISO-week weft from Strung counts. The goals launch key opens this sheet.
struct ClothView: View {
    @ObservedObject var session: HubSession
    @Environment(\.dismiss) private var dismiss
    @State private var openWeek: String?

    private var rows: [WeftRow] { session.store.weftRows() }
    private var years: [Int] {
        Array(Set(rows.map(\.isoYear))).sorted()
    }

    var body: some View {
        NavigationStack {
            Group {
                if let recovery = session.recovery, rows.isEmpty, session.document.stringMarks.isEmpty == false {
                    StatusPage(
                        art: "hed_EmptyList",
                        title: "Weeks could not be read",
                        line: recovery,
                        verb: "Retry",
                        action: { Task { await session.retry() } }
                    )
                } else if rows.isEmpty {
                    StatusPage(
                        art: "hed_EmptyList",
                        title: "No weft this year",
                        line: "A strung knot fills a week",
                        verb: "String",
                        action: { session.armString() }
                    )
                } else {
                    ScrollView {
                        LazyVStack(alignment: .leading, spacing: BeadChrome.pad) {
                            tension
                            ForEach(years, id: \.self) { year in
                                Text(BeadChrome.count(year))
                                    .font(BeadChrome.headline)
                                    .foregroundStyle(DesignTokens.ink)
                                ForEach(rows.filter { $0.isoYear == year }) { row in
                                    weekCard(row)
                                }
                            }
                        }
                        .padding(BeadChrome.pad)
                    }
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(DesignTokens.bg)
            .navigationTitle("Weeks")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .frame(minWidth: 44, minHeight: 44)
                    }
                    .accessibilityLabel("Close")
                }
            }
        }
    }

    private var tension: some View {
        VStack(alignment: .leading, spacing: BeadChrome.tight) {
            Text("Tension")
                .font(BeadChrome.caption)
                .foregroundStyle(DesignTokens.muted)
            Text("\(BeadChrome.count(streak)) weeks in a row")
                .font(BeadChrome.headline)
                .foregroundStyle(DesignTokens.accent)
                .monospacedDigit()
            Text("\(BeadChrome.count(rows.reduce(0) { $0 + $1.strungCount })) strung across \(BeadChrome.count(years.count)) years")
                .font(BeadChrome.body)
                .foregroundStyle(DesignTokens.ink)
        }
        .accessibilityElement(children: .combine)
    }

    private var streak: Int {
        let ordered = rows.sorted { lhs, rhs in
            if lhs.isoYear == rhs.isoYear { return lhs.isoWeek > rhs.isoWeek }
            return lhs.isoYear > rhs.isoYear
        }
        var run = 0
        var expect: (year: Int, week: Int)?
        for row in ordered where row.strungCount > 0 {
            if let expect, row.isoYear != expect.year || row.isoWeek != expect.week {
                break
            }
            run += 1
            expect = previousWeek(year: row.isoYear, week: row.isoWeek)
        }
        return run
    }

    private func previousWeek(year: Int, week: Int) -> (year: Int, week: Int) {
        if week > 1 { return (year, week - 1) }
        return (year - 1, 52)
    }

    private func weekCard(_ row: WeftRow) -> some View {
        VStack(alignment: .leading, spacing: BeadChrome.stack) {
            Button {
                openWeek = openWeek == row.id ? nil : row.id
            } label: {
                HStack(alignment: .center, spacing: BeadChrome.stack) {
                    VStack(alignment: .leading, spacing: BeadChrome.tight) {
                        Text("Week \(BeadChrome.count(row.isoWeek))")
                            .font(BeadChrome.headline)
                            .foregroundStyle(DesignTokens.ink)
                        WeftLoom(count: row.strungCount)
                            .frame(height: 36)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    Text(BeadChrome.count(row.strungCount))
                        .font(BeadChrome.title)
                        .foregroundStyle(DesignTokens.accent)
                        .monospacedDigit()
                }
                .contentShape(Rectangle())
            }
            .buttonStyle(BeadPressStyle())
            if openWeek == row.id {
                let knots = KnotFold.knots(
                    inWeek: row.isoYear,
                    week: row.isoWeek,
                    knots: session.knots,
                    calendar: .current
                )
                ForEach(knots) { knot in
                    Button {
                        session.cover = .thread(knotID: knot.id)
                    } label: {
                        Text(knot.caption.isEmpty ? BeadChrome.dayLabel(knot.dayKey) : knot.caption)
                            .font(BeadChrome.body)
                            .foregroundStyle(DesignTokens.ink)
                            .frame(maxWidth: .infinity, minHeight: 44, alignment: .leading)
                    }
                    .buttonStyle(BeadPressStyle())
                }
            }
        }
        .padding(BeadChrome.stack)
        .frame(maxWidth: .infinity, minHeight: 72, alignment: .leading)
        .background(DesignTokens.surface, in: RoundedRectangle(cornerRadius: BeadChrome.card, style: .continuous))
        .thickFrame()
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Week \(row.isoWeek), \(row.isoYear), \(row.strungCount) strung")
    }
}

/// Seven warp threads crossed by a weft whose weight follows the week's strung count.
struct WeftLoom: View {
    var count: Int

    var body: some View {
        Canvas { context, size in
            let warps = 7
            let step = size.width / CGFloat(warps + 1)
            for index in 1...warps {
                var warp = Path()
                let x = step * CGFloat(index)
                warp.move(to: CGPoint(x: x, y: 0))
                warp.addLine(to: CGPoint(x: x, y: size.height))
                context.stroke(warp, with: .color(DesignTokens.muted), lineWidth: 1)
            }
            let passes = max(count, 1)
            let weight = min(6, 1 + CGFloat(count))
            for pass in 0..<min(passes, 4) {
                var weft = Path()
                let y = size.height * (CGFloat(pass) + 1) / 5
                weft.move(to: CGPoint(x: step, y: y))
                var over = pass.isMultiple(of: 2)
                for index in 1...warps {
                    let x = step * CGFloat(index)
                    weft.addLine(to: CGPoint(x: x, y: y + (over ? -3 : 3)))
                    over.toggle()
                }
                context.stroke(weft, with: .color(count == 0 ? DesignTokens.muted : DesignTokens.accent), lineWidth: weight)
            }
        }
        .accessibilityHidden(true)
    }
}
