import Foundation
import UIKit

/// Simulator demo. Runs once behind `hed.demo.v1`. Today stays Tied with a
/// caption so String is the live verb. Never plants FullMark, and never runs
/// on a device.
enum ThreadSeed {
    static func shouldApply(isSimulator: Bool, defaults: UserDefaults) -> Bool {
        guard isSimulator else { return false }
        return defaults.bool(forKey: ThreadDocument.demoKey) == false
    }

    static func document(now: Date, calendar: Calendar = .current) -> ThreadDocument {
        var marks: [KnotMark] = []
        var strings: [StringMark] = []
        let todayKey = DayKey.make(now, calendar: calendar)
        var days: [Date] = []
        if let prior = calendar.date(byAdding: .year, value: -1, to: now) {
            days.append(prior)
        }
        if let older = calendar.date(byAdding: .year, value: -2, to: now) {
            days.append(older)
        }
        for offset in [-48, -27, -13, -6] {
            if let day = calendar.date(byAdding: .day, value: offset, to: now) {
                days.append(day)
            }
        }
        for (index, day) in days.enumerated() {
            let key = DayKey.make(day, calendar: calendar)
            if key == todayKey { continue }
            let id = UUID()
            let caption = lines[index % lines.count]
            marks.append(KnotMark(id: id, dayKey: key, caption: caption, createdAt: day))
            let file = "hed-seed-\(key).jpg"
            strings.append(
                StringMark(
                    id: UUID(),
                    dayKey: key,
                    knotID: id,
                    fileName: file,
                    media: .photo,
                    createdAt: day.addingTimeInterval(60)
                )
            )
        }
        let tied = KnotMark(
            id: UUID(),
            dayKey: todayKey,
            caption: "Morning light on the thread.",
            createdAt: now
        )
        marks.append(tied)
        var document = ThreadDocument.loose
        document.onboardingComplete = true
        document.knotMarks = marks
        document.stringMarks = strings
        document.knots = KnotFold.knots(knotMarks: marks, stringMarks: strings)
        return document
    }

    @MainActor
    static func mediaPayloads(in document: ThreadDocument) -> [(String, Data)] {
        document.stringMarks.enumerated().map { index, mark in
            (mark.fileName, beadJPEG(shift: index, dayKey: mark.dayKey))
        }
    }

    private static let lines = [
        "Rain on the sill.",
        "Market before noon.",
        "Quiet room, long light.",
        "Walked the long way.",
        "Left the window open.",
        "Thread on the table."
    ]

    @MainActor
    private static func beadJPEG(shift: Int, dayKey: Int) -> Data {
        let side: CGFloat = 640
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: side, height: side))
        let image = renderer.image { ctx in
            let cg = ctx.cgContext
            DesignTokens.bgUI.setFill()
            cg.fill(CGRect(x: 0, y: 0, width: side, height: side))
            let pattern = (shift + dayKey) % 4
            switch pattern {
            case 0:
                DesignTokens.surfaceUI.setFill()
                for band in stride(from: 0, to: Int(side), by: 18) {
                    cg.fill(CGRect(x: 0, y: CGFloat(band), width: side, height: 8))
                }
            case 1:
                cg.setStrokeColor(DesignTokens.surfaceUI.cgColor)
                cg.setLineWidth(6)
                for band in stride(from: 0, to: Int(side * 2), by: 28) {
                    cg.move(to: CGPoint(x: CGFloat(band) - side, y: 0))
                    cg.addLine(to: CGPoint(x: CGFloat(band), y: side))
                }
                cg.strokePath()
            case 2:
                DesignTokens.tiedUI.setFill()
                for row in stride(from: 20, to: Int(side), by: 48) {
                    for col in stride(from: 20, to: Int(side), by: 48) {
                        cg.fillEllipse(in: CGRect(x: col, y: row, width: 16, height: 16))
                    }
                }
            default:
                cg.setStrokeColor(DesignTokens.accentUI.cgColor)
                cg.setLineWidth(4)
                for ring in stride(from: 40, to: Int(side), by: 36) {
                    let inset = CGFloat(ring) / 2
                    cg.strokeEllipse(in: CGRect(x: inset, y: inset, width: side - CGFloat(ring), height: side - CGFloat(ring)))
                }
            }
            cg.setStrokeColor(DesignTokens.inkUI.cgColor)
            cg.setLineWidth(10)
            cg.setLineCap(.round)
            let sway = CGFloat((shift % 4) * 14) - 21
            cg.move(to: CGPoint(x: side / 2 + sway, y: 0))
            cg.addLine(to: CGPoint(x: side / 2, y: side))
            cg.strokePath()

            let diameter: CGFloat = 280
            let bead = CGRect(
                x: (side - diameter) / 2 + sway * 0.3,
                y: (side - diameter) / 2,
                width: diameter,
                height: diameter
            )
            cg.setFillColor(UIColor.black.withAlphaComponent(0.35).cgColor)
            cg.fillEllipse(in: bead.offsetBy(dx: 0, dy: 16))
            cg.saveGState()
            cg.addEllipse(in: bead)
            cg.clip()
            let colors = [
                DesignTokens.inkUI.cgColor,
                UIColor(red: 0.55, green: 0.64, blue: 0.57, alpha: 1).cgColor,
                DesignTokens.bgUI.cgColor
            ] as CFArray
            if let gradient = CGGradient(
                colorsSpace: CGColorSpaceCreateDeviceRGB(),
                colors: colors,
                locations: [0, 0.5, 1]
            ) {
                cg.drawLinearGradient(
                    gradient,
                    start: CGPoint(x: bead.minX, y: bead.minY),
                    end: CGPoint(x: bead.maxX, y: bead.maxY),
                    options: []
                )
            }
            cg.restoreGState()
            cg.setStrokeColor(DesignTokens.inkUI.cgColor)
            cg.setLineWidth(6)
            cg.strokeEllipse(in: bead.insetBy(dx: 3, dy: 3))
            let hole = CGRect(x: bead.midX - 22, y: bead.minY + 48, width: 44, height: 44)
            DesignTokens.bgUI.setFill()
            cg.fillEllipse(in: hole)
            cg.strokeEllipse(in: hole)
        }
        return image.jpegData(compressionQuality: 0.9) ?? Data()
    }
}
