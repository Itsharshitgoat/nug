import SwiftUI

struct AsymmetricalWindowShape: Shape {
    var radius: CGFloat = 28.0

    func path(in rect: CGRect) -> Path {
        var path = Path()

        let width = rect.size.width
        let height = rect.size.height

        // Start at top-left corner (sharp)
        path.move(to: CGPoint(x: 0, y: 0))

        // Line to top-right corner, then arc
        path.addLine(to: CGPoint(x: width - radius, y: 0))
        path.addArc(center: CGPoint(x: width - radius, y: radius),
                    radius: radius,
                    startAngle: Angle(degrees: -90),
                    endAngle: Angle(degrees: 0),
                    clockwise: false)

        // Line to bottom-right corner, then arc
        path.addLine(to: CGPoint(x: width, y: height - radius))
        path.addArc(center: CGPoint(x: width - radius, y: height - radius),
                    radius: radius,
                    startAngle: Angle(degrees: 0),
                    endAngle: Angle(degrees: 90),
                    clockwise: false)

        // Line to bottom-left corner, then arc
        path.addLine(to: CGPoint(x: radius, y: height))
        path.addArc(center: CGPoint(x: radius, y: height - radius),
                    radius: radius,
                    startAngle: Angle(degrees: 90),
                    endAngle: Angle(degrees: 180),
                    clockwise: false)

        // Line back to the top-left (sharp)
        path.addLine(to: CGPoint(x: 0, y: 0))

        path.closeSubpath()
        return path
    }
}
