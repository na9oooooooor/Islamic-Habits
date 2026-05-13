import SwiftUI

struct IslamicPattern: View {
    var body: some View {
        GeometryReader { geo in
            Canvas { context, size in
                let color = GraphicsContext.Shading.color(
                    Color.white.opacity(0.04)
                )
                let spacing: CGFloat = 60
                let cols = Int(size.width / spacing) + 2
                let rows = Int(size.height / spacing) + 2
                
                for row in 0..<rows {
                    for col in 0..<cols {
                        let x = CGFloat(col) * spacing + (row % 2 == 0 ? 0 : spacing / 2)
                        let y = CGFloat(row) * spacing
                        
                        var star = Path()
                        let points = 8
                        let outerR: CGFloat = 12
                        let innerR: CGFloat = 5
                        
                        for i in 0..<points * 2 {
                            let angle = CGFloat(i) * .pi / CGFloat(points) - .pi / 2
                            let r = i % 2 == 0 ? outerR : innerR
                            let px = x + cos(angle) * r
                            let py = y + sin(angle) * r
                            if i == 0 {
                                star.move(to: CGPoint(x: px, y: py))
                            } else {
                                star.addLine(to: CGPoint(x: px, y: py))
                            }
                        }
                        star.closeSubpath()
                        context.stroke(star, with: color, lineWidth: 0.5)
                    }
                }
            }
        }
        .allowsHitTesting(false)
    }
}
