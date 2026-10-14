import SwiftUI
import UIKit

/// Solid bead drawn in UIKit so the first frame shows a bead, not an empty well.
/// Loose draws an open loop, Tied a knotted hitch, Strung a faceted bead.
final class BeadCanvasView: UIView {
    var showsThread = true
    var phase: Knot.Phase = .tied

    override init(frame: CGRect) {
        super.init(frame: frame)
        isOpaque = true
        backgroundColor = DesignTokens.surfaceUI
        contentMode = .redraw
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func draw(_ rect: CGRect) {
        guard let ctx = UIGraphicsGetCurrentContext() else { return }
        DesignTokens.surfaceUI.setFill()
        ctx.fill(rect)

        let midX = rect.midX
        let pigment = DesignTokens.phaseUI(phase)
        if showsThread {
            ctx.setStrokeColor(pigment.withAlphaComponent(0.9).cgColor)
            ctx.setLineWidth(phase == .loose ? 3 : 5)
            ctx.setLineCap(.round)
            ctx.move(to: CGPoint(x: midX, y: rect.minY))
            ctx.addLine(to: CGPoint(x: midX, y: rect.maxY))
            ctx.strokePath()
        }

        let diameter = min(rect.width * 0.62, rect.height * 0.78)
        let bead = CGRect(
            x: midX - diameter / 2,
            y: rect.midY - diameter / 2,
            width: diameter,
            height: diameter
        )
        switch phase {
        case .loose:
            drawLoop(ctx, in: bead, pigment: pigment)
        case .tied:
            drawKnot(ctx, in: bead, pigment: pigment)
        case .strung:
            drawFacet(ctx, in: bead, pigment: pigment)
        }
    }

    private func drawLoop(_ ctx: CGContext, in bead: CGRect, pigment: UIColor) {
        ctx.setStrokeColor(pigment.cgColor)
        ctx.setLineWidth(4)
        ctx.setLineCap(.round)
        let loop = UIBezierPath()
        loop.move(to: CGPoint(x: bead.midX, y: bead.maxY))
        loop.addCurve(
            to: CGPoint(x: bead.midX, y: bead.minY + bead.height * 0.18),
            controlPoint1: CGPoint(x: bead.minX, y: bead.midY),
            controlPoint2: CGPoint(x: bead.maxX, y: bead.minY)
        )
        ctx.addPath(loop.cgPath)
        ctx.strokePath()
    }

    private func drawKnot(_ ctx: CGContext, in bead: CGRect, pigment: UIColor) {
        ctx.setFillColor(UIColor.black.withAlphaComponent(0.28).cgColor)
        ctx.fillEllipse(in: bead.offsetBy(dx: 0, dy: bead.height * 0.06))
        fillGradient(ctx, in: bead, light: DesignTokens.inkUI, mid: pigment, dark: DesignTokens.bgUI)
        ctx.setStrokeColor(pigment.cgColor)
        ctx.setLineWidth(3)
        ctx.strokeEllipse(in: bead.insetBy(dx: 1.5, dy: 1.5))
        ctx.setLineWidth(2)
        let ticks = 6
        for index in 0..<ticks {
            let angle = CGFloat(index) / CGFloat(ticks) * .pi
            let inner = bead.width * 0.28
            let outer = bead.width * 0.42
            let cx = bead.midX
            let cy = bead.midY
            ctx.move(to: CGPoint(x: cx + cos(angle) * inner, y: cy + sin(angle) * inner))
            ctx.addLine(to: CGPoint(x: cx + cos(angle) * outer, y: cy + sin(angle) * outer))
        }
        ctx.strokePath()
    }

    private func drawFacet(_ ctx: CGContext, in bead: CGRect, pigment: UIColor) {
        ctx.setFillColor(UIColor.black.withAlphaComponent(0.28).cgColor)
        ctx.fillEllipse(in: bead.offsetBy(dx: 0, dy: bead.height * 0.06))
        fillGradient(ctx, in: bead, light: DesignTokens.inkUI, mid: pigment, dark: DesignTokens.bgUI)
        ctx.setStrokeColor(DesignTokens.inkUI.cgColor)
        ctx.setLineWidth(3)
        ctx.strokeEllipse(in: bead.insetBy(dx: 1.5, dy: 1.5))
        ctx.setStrokeColor(pigment.cgColor)
        ctx.setLineWidth(2)
        let facet = bead.insetBy(dx: bead.width * 0.22, dy: bead.height * 0.22)
        ctx.strokeEllipse(in: facet)
        ctx.setStrokeColor(DesignTokens.inkUI.cgColor)
        ctx.setLineWidth(3)
        ctx.move(to: CGPoint(x: bead.midX, y: bead.minY))
        ctx.addLine(to: CGPoint(x: bead.midX, y: bead.maxY))
        ctx.strokePath()
        let hole = bead.width * 0.16
        let eye = CGRect(
            x: bead.midX - hole / 2,
            y: bead.minY + bead.height * 0.18,
            width: hole,
            height: hole
        )
        ctx.setFillColor(DesignTokens.bgUI.cgColor)
        ctx.fillEllipse(in: eye)
        ctx.strokeEllipse(in: eye)
    }

    private func fillGradient(_ ctx: CGContext, in bead: CGRect, light: UIColor, mid: UIColor, dark: UIColor) {
        ctx.saveGState()
        ctx.addEllipse(in: bead)
        ctx.clip()
        let colors = [light.cgColor, mid.cgColor, dark.cgColor] as CFArray
        if let gradient = CGGradient(colorsSpace: CGColorSpaceCreateDeviceRGB(), colors: colors, locations: [0, 0.55, 1]) {
            ctx.drawLinearGradient(
                gradient,
                start: CGPoint(x: bead.minX, y: bead.minY),
                end: CGPoint(x: bead.maxX, y: bead.maxY),
                options: []
            )
        }
        ctx.restoreGState()
    }
}

struct BeadCanvas: UIViewRepresentable {
    var showsThread = true
    var phase: Knot.Phase = .tied

    func makeUIView(context: Context) -> BeadCanvasView {
        let view = BeadCanvasView()
        view.showsThread = showsThread
        view.phase = phase
        return view
    }

    func updateUIView(_ uiView: BeadCanvasView, context: Context) {
        uiView.showsThread = showsThread
        uiView.phase = phase
        uiView.setNeedsDisplay()
    }
}

/// Photo well. Loads on the view so the capture shows the file, not a placeholder.
final class BeadPhotoView: UIView {
    let imageView = UIImageView()

    override init(frame: CGRect) {
        super.init(frame: frame)
        clipsToBounds = true
        backgroundColor = DesignTokens.surfaceUI
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(imageView)
        NSLayoutConstraint.activate([
            imageView.leadingAnchor.constraint(equalTo: leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: trailingAnchor),
            imageView.topAnchor.constraint(equalTo: topAnchor),
            imageView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

struct BeadPhoto: UIViewRepresentable {
    var image: UIImage

    func makeUIView(context: Context) -> BeadPhotoView {
        let view = BeadPhotoView()
        view.imageView.image = image
        return view
    }

    func updateUIView(_ uiView: BeadPhotoView, context: Context) {
        uiView.imageView.image = image
    }
}
