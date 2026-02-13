import SwiftUI

struct InstrumentDial: View {
    let title: String
    @Binding var value: Int
    let range: ClosedRange<Int>
    let step: Int
    let displayFormat: (Int) -> String
    let accentColor: Color
    var snap: Bool = false
    var wraps: Bool = false
    var suffix: String = ""
    var minValue: Int? = nil
    
    @State private var accumulatedDrag: CGFloat = 0
    @State private var lastDragValue: CGFloat = 0
    
    private let itemWidth: CGFloat = 58
    private let dialHeight: CGFloat = 88
    private let bezelWidth: CGFloat = 8
    
    private var effectiveMin: Int { minValue ?? range.lowerBound }
    
    private var allValues: [Int] {
        stride(from: effectiveMin, through: range.upperBound, by: step).map { $0 }
    }
    
    private var currentIndex: Int {
        allValues.firstIndex(of: value) ?? 0
    }
    
    var body: some View {
        VStack(spacing: 5) {
            Text(title)
                .font(.system(size: 11, weight: .heavy, design: .monospaced))
                .tracking(3)
                .foregroundColor(Color(white: 0.5))
            
            ZStack {
                // Outer bezel ring - thick knurled metal
                RoundedRectangle(cornerRadius: 14)
                    .fill(
                        LinearGradient(
                            stops: [
                                .init(color: Color(white: 0.28), location: 0.0),
                                .init(color: Color(white: 0.18), location: 0.15),
                                .init(color: Color(white: 0.13), location: 0.5),
                                .init(color: Color(white: 0.08), location: 0.85),
                                .init(color: Color(white: 0.15), location: 1.0),
                            ],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .shadow(color: .black.opacity(0.5), radius: 4, y: 2)
                    .overlay(
                        RoundedRectangle(cornerRadius: 14)
                            .strokeBorder(
                                LinearGradient(
                                    colors: [Color(white: 0.35), Color(white: 0.08)],
                                    startPoint: .top,
                                    endPoint: .bottom
                                ),
                                lineWidth: 0.5
                            )
                    )
                
                // Knurled texture overlay
                Canvas { context, size in
                    for i in 0..<Int(size.width / 3) {
                        let x = CGFloat(i) * 3 + 1.5
                        var path = Path()
                        path.move(to: CGPoint(x: x, y: 0))
                        path.addLine(to: CGPoint(x: x, y: size.height))
                        context.stroke(
                            path,
                            with: .color(.white.opacity(i % 2 == 0 ? 0.10 : 0.0)),
                            lineWidth: 1.5
                        )
                        if i % 2 == 0 {
                            var shadow = Path()
                            shadow.move(to: CGPoint(x: x + 1.5, y: 0))
                            shadow.addLine(to: CGPoint(x: x + 1.5, y: size.height))
                            context.stroke(
                                shadow,
                                with: .color(.black.opacity(0.15)),
                                lineWidth: 1
                            )
                        }
                    }
                }
                .clipShape(RoundedRectangle(cornerRadius: 14))
                .allowsHitTesting(false)
                
                // Inner black face with inset shadow
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.black)
                    .padding(bezelWidth)
                    .shadow(color: .black.opacity(0.8), radius: 3, y: 1)
                
                // Glass highlight on inner face
                RoundedRectangle(cornerRadius: 8)
                    .fill(
                        LinearGradient(
                            colors: [Color.white.opacity(0.03), Color.clear],
                            startPoint: .top,
                            endPoint: .center
                        )
                    )
                    .padding(bezelWidth)
                
                // Selection indicator - white triangle at top
                VStack {
                    Triangle()
                        .fill(Color.white)
                        .frame(width: 10, height: 6)
                        .offset(y: bezelWidth - 1)
                    Spacer()
                }
                
                // Number strip
                HStack(spacing: 0) {
                    ForEach(-3...3, id: \.self) { offset in
                        let idx = currentIndex + offset
                        let isCenter = offset == 0
                        let dist = abs(offset)
                        
                        Group {
                            if idx >= 0 && idx < allValues.count {
                                VStack(spacing: 2) {
                                    // Tick mark
                                    Rectangle()
                                        .fill(isCenter ? accentColor : Color.white.opacity(0.4))
                                        .frame(width: isCenter ? 2 : 1, height: isCenter ? 8 : 5)
                                    
                                    Text(displayFormat(allValues[idx]))
                                        .font(.system(
                                            size: isCenter ? 32 : 18,
                                            weight: isCenter ? .heavy : .medium,
                                            design: .monospaced
                                        ))
                                        .foregroundColor(
                                            isCenter ? .white :
                                                Color(white: max(0.2, 0.55 - Double(dist) * 0.12))
                                        )
                                        .minimumScaleFactor(0.6)
                                        .lineLimit(1)
                                }
                            }
                        }
                        .frame(width: itemWidth)
                        .opacity(isCenter ? 1.0 : max(0.15, 0.7 - Double(dist) * 0.2))
                    }
                }
                .padding(.top, 4)
                
                // Suffix label bottom-right
                if !suffix.isEmpty {
                    VStack {
                        Spacer()
                        HStack {
                            Spacer()
                            Text(suffix)
                                .font(.system(size: 10, weight: .bold, design: .monospaced))
                                .foregroundColor(accentColor.opacity(0.5))
                                .padding(.trailing, bezelWidth + 8)
                                .padding(.bottom, bezelWidth + 4)
                        }
                    }
                }
            }
            .frame(height: dialHeight)
            .clipped()
            .contentShape(Rectangle())
            .gesture(dragGesture)
        }
    }
    
    // MARK: - Drag gesture
    
    private var dragGesture: some Gesture {
        DragGesture()
            .onChanged { gesture in
                let delta = gesture.translation.width - lastDragValue
                accumulatedDrag += delta
                lastDragValue = gesture.translation.width
                
                let steps = Int(accumulatedDrag / itemWidth)
                if steps != 0 {
                    accumulatedDrag -= CGFloat(steps) * itemWidth
                    let newIndex = max(0, min(allValues.count - 1, currentIndex - steps))
                    if allValues[newIndex] != value {
                        value = allValues[newIndex]
                        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                    }
                }
            }
            .onEnded { _ in
                accumulatedDrag = 0
                lastDragValue = 0
            }
    }
}

// MARK: - Triangle shape for indicator

struct Triangle: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.midX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.minY))
        path.closeSubpath()
        return path
    }
}
