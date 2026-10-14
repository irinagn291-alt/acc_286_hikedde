import SwiftUI

/// Vertical thread. One tall open bead, then smaller beads at uneven gaps.
/// Each row takes its own height so Dynamic Type cannot paint into the next bead.
/// Edge to edge. The layout name is not a screen title.
struct ThreadLayout: Layout {
    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let width = proposal.width ?? 0
        let child = ProposedViewSize(width: width, height: nil)
        var height: CGFloat = 0
        for index in subviews.indices {
            height += subviews[index].sizeThatFits(child).height
            if index < subviews.count - 1 {
                height += gap(index)
            }
        }
        return CGSize(width: width, height: height)
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let childWidth = bounds.width
        var y = bounds.minY
        for index in subviews.indices {
            let measured = subviews[index].sizeThatFits(
                ProposedViewSize(width: childWidth, height: nil)
            )
            subviews[index].place(
                at: CGPoint(x: bounds.minX, y: y),
                anchor: .topLeading,
                proposal: ProposedViewSize(width: childWidth, height: measured.height)
            )
            y += measured.height
            if index < subviews.count - 1 {
                y += gap(index)
            }
        }
    }

    private func gap(_ index: Int) -> CGFloat {
        let steps = [BeadChrome.pad, BeadChrome.tight, BeadChrome.air, BeadChrome.stack]
        return steps[index % steps.count]
    }
}
