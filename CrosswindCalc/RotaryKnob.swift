import SwiftUI

struct RotaryKnob: View {
    let label: String
    @Binding var value: Int
    let range: ClosedRange<Int>
    let step: Int
    let wraps: Bool
    let displayFormat: (Int) -> String
    let color: Color
    let knobID: KnobID
    @Binding var activeKnob: KnobID?
    var suffix: String = ""
    var minValue: Int? = nil
    var dialLabels: [(String, CGFloat)]? = nil
    
    @State private var lastAngle: CGFloat? = nil
    @State private var accumulatedAngle: CGFloat = 0
    @State private var isDragging: Bool = false
    
    private var isActive: Bool { activeKnob == knobID }
    
    private var effectiveMin: Int { minValue ?? range.lowerBound }
    
    private var allValues: [Int] {
        stride(from: effectiveMin, through: range.upperBound, by: step)
            .map { $0 }
    }
    
    private var currentIndex: Int {
        allValues.firstIndex(of: value) ?? 0
    }
    
    private let degreesPerStep: CGFloat = 12
    
    private func advanceBy(_ steps: Int) {
        if wraps {
            let count = allValues.count
            let newIdx = ((currentIndex + steps) % count + count) % count
            if allValues[newIdx] != value {
                value = allValues[newIdx]
                UIImpactFeedbackGenerator(style: .light).impactOccurred()
            }
        } else {
            let newIdx = max(0, min(allValues.count - 1, currentIndex + steps))
            if allValues[newIdx] != value {
                value = allValues[newIdx]
                UIImpactFeedbackGenerator(style: .light).impactOccurred()
            }
        }
    }
    
    private func jumpToAngle(_ angle: CGFloat, size: CGFloat) {
        let normalizedAngle = ((angle + 90).truncatingRemainder(dividingBy: 360) + 360)
            .truncatingRemainder(dividingBy: 360)
        let fraction = normalizedAngle / 360.0
        
        let fullRange = stride(from: range.lowerBound, through: range.upperBound, by: step).map { $0 }
        let fullCount = fullRange.count
        
        let fullIndex: Int
        if wraps {
            let raw = Int(round(fraction * CGFloat(fullCount)))
            fullIndex = raw >= fullCount ? 0 : raw
        } else {
            fullIndex = min(fullCount - 1, max(0, Int(round(fraction * CGFloat(fullCount - 1)))))
        }
        
        let targetValue = fullRange[fullIndex]
        let clampedValue = max(effectiveMin, min(range.upperBound, targetValue))
        
        if let closest = allValues.min(by: { abs($0 - clampedValue) < abs($1 - clampedValue) }), closest != value {
            value = closest
            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        }
    }
    
    var body: some View {
        VStack(spacing: 4) {
            Text(label)
                .font(.system(size: 16, weight: .heavy, design: .monospaced))
                .tracking(3)
                .foregroundColor(color)
            
            GeometryReader { geo in
                let size = min(geo.size.width, geo.size.height)
                let center = CGPoint(x: geo.size.width / 2,
                                      y: geo.size.height / 2)
                
                ZStack {
                    knobBody(size: size)
                    dialNumbersRing(size: size)
                    knobCenter(size: size)
                    indicatorDot(size: size)
                }
                .frame(width: size, height: size)
                .position(center)
                .overlay(
                    Circle()
                        .stroke(color, lineWidth: 2)
                        .frame(width: size + 4, height: size + 4)
                        .shadow(color: color.opacity(0.7), radius: 8)
                        .shadow(color: color.opacity(0.4), radius: 16)
                        .opacity(isActive ? 1 : 0)
                        .position(center)
                )
                .animation(.easeInOut(duration: 0.15), value: isActive)
                .gesture(
                    DragGesture(minimumDistance: 0)
                        .onChanged { gesture in
                            activeKnob = knobID
                            
                            let loc = gesture.location
                            let dx = loc.x - size / 2
                            let dy = loc.y - size / 2
                            let angle = atan2(dy, dx) * 180 / .pi
                            
                            if !isDragging {
                                isDragging = true
                                jumpToAngle(angle, size: size)
                                lastAngle = angle
                                accumulatedAngle = 0
                            } else if let last = lastAngle {
                                var delta = angle - last
                                if delta > 180 { delta -= 360 }
                                if delta < -180 { delta += 360 }
                                
                                accumulatedAngle += delta
                                
                                let steps = Int(accumulatedAngle / degreesPerStep)
                                if steps != 0 {
                                    accumulatedAngle -= CGFloat(steps) * degreesPerStep
                                    advanceBy(steps)
                                }
                                lastAngle = angle
                            }
                        }
                        .onEnded { _ in
                            lastAngle = nil
                            accumulatedAngle = 0
                            isDragging = false
                            activeKnob = nil
                        }
                )
            }
            .aspectRatio(1, contentMode: .fit)
        }
    }
    
    // MARK: - Dial numbers inside the knob ring
    
    private func dialNumbersRing(size: CGFloat) -> some View {
        let radius = size / 2 - 18
        return ZStack {
            if let labels = dialLabels {
                ForEach(Array(labels.enumerated()), id: \.offset) { _, item in
                    let (text, angleDeg) = item
                    let angleRad = (angleDeg - 90) * .pi / 180
                    Text(text)
                        .font(.system(size: 17, weight: .heavy, design: .monospaced))
                        .foregroundColor(color.opacity(0.7))
                        .offset(
                            x: cos(angleRad) * radius,
                            y: sin(angleRad) * radius
                        )
                }
            }
        }
        .frame(width: size, height: size)
        .allowsHitTesting(false)
    }
    
    // MARK: - Knob body (outer ring with knurling)
    
    private func knobBody(size: CGFloat) -> some View {
        ZStack {
            Circle()
                .fill(Color.black.opacity(0.4))
                .frame(width: size, height: size)
                .blur(radius: 6)
                .offset(y: 3)
            
            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            Color(white: 0.22),
                            Color(white: 0.15),
                            Color(white: 0.10),
                            Color(white: 0.13)
                        ],
                        center: .init(x: 0.4, y: 0.35),
                        startRadius: 0,
                        endRadius: size / 2
                    )
                )
                .frame(width: size, height: size)
                .overlay(
                    Circle()
                        .strokeBorder(
                            LinearGradient(
                                colors: [Color(white: 0.32), Color(white: 0.06)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1.5
                        )
                )
            
            Canvas { context, canvasSize in
                let c = CGPoint(x: canvasSize.width / 2,
                                y: canvasSize.height / 2)
                let r = size / 2 - 2
                let grooveCount = 60
                
                for i in 0..<grooveCount {
                    let a = CGFloat(i) / CGFloat(grooveCount) * .pi * 2
                    let inner = r - 8
                    var path = Path()
                    path.move(to: CGPoint(
                        x: c.x + cos(a) * inner,
                        y: c.y + sin(a) * inner))
                    path.addLine(to: CGPoint(
                        x: c.x + cos(a) * r,
                        y: c.y + sin(a) * r))
                    
                    context.stroke(path,
                        with: .color(.white.opacity(
                            i % 2 == 0 ? 0.12 : 0.0)),
                        lineWidth: 1.5)
                }
            }
            .frame(width: size, height: size)
            .allowsHitTesting(false)
        }
    }
    
    // MARK: - Center face with value
    
    private func knobCenter(size: CGFloat) -> some View {
        let innerSize = size * 0.48
        return ZStack {
            Circle()
                .fill(Color.black)
                .frame(width: innerSize, height: innerSize)
                .shadow(color: .black.opacity(0.6), radius: 4, y: 2)
            
            Circle()
                .fill(
                    LinearGradient(
                        colors: [Color.white.opacity(0.04), Color.clear],
                        startPoint: .top,
                        endPoint: .center
                    )
                )
                .frame(width: innerSize, height: innerSize)
            
            VStack(spacing: 0) {
                Text(displayFormat(value))
                    .font(.system(size: innerSize * 0.35,
                                  weight: .heavy, design: .monospaced))
                    .foregroundColor(.white)
                    .minimumScaleFactor(0.5)
                    .lineLimit(1)
                
                if !suffix.isEmpty {
                    Text(suffix)
                        .font(.system(size: 10, weight: .medium,
                                      design: .monospaced))
                        .foregroundColor(color.opacity(0.5))
                }
            }
        }
    }
    
    // MARK: - Position indicator dot
    
    private func indicatorDot(size: CGFloat) -> some View {
        let dotRadius = size / 2 - 14
        let normalizedPosition: CGFloat
        if allValues.count > 1 {
            normalizedPosition = CGFloat(currentIndex) / CGFloat(allValues.count - (wraps ? 0 : 1))
        } else {
            normalizedPosition = 0
        }
        let angle = normalizedPosition * .pi * 2 - .pi / 2
        
        return Circle()
            .fill(color)
            .frame(width: 8, height: 8)
            .shadow(color: color.opacity(0.6), radius: 4)
            .offset(
                x: cos(angle) * dotRadius,
                y: sin(angle) * dotRadius
            )
    }
}
