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
    
    private let itemWidth: CGFloat = 52
    
    private var effectiveMin: Int { minValue ?? range.lowerBound }
    
    private var allValues: [Int] {
        stride(from: effectiveMin, through: range.upperBound, by: step).map { $0 }
    }
    
    private var currentIndex: Int {
        allValues.firstIndex(of: value) ?? 0
    }
    
    var body: some View {
        VStack(spacing: 4) {
            // Title
            Text(title)
                .font(.system(size: 9, weight: .bold, design: .monospaced))
                .tracking(2)
                .foregroundColor(Color(white: 0.45))
            
            // Dial body
            ZStack {
                dialBezel
                dialFace
                selectionWindow
                numberStrip
                
                if !suffix.isEmpty {
                    suffixLabel
                }
            }
            .frame(height: 64)
            .clipped()
            .contentShape(Rectangle())
            .gesture(dragGesture)
        }
    }
    
    // MARK: - Gesture
    
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
                        UIImpactFeedbackGenerator(style: .light).impactOccurred()
                    }
                }
            }
            .onEnded { _ in
                accumulatedDrag = 0
                lastDragValue = 0
            }
    }
    
    // MARK: - Bezel (knurled metal rim)
    
    private var dialBezel: some View {
        RoundedRectangle(cornerRadius: 12)
            .fill(
                LinearGradient(
                    colors: [
                        Color(white: 0.20),
                        Color(white: 0.12),
                        Color(white: 0.16),
                        Color(white: 0.10),
                        Color(white: 0.14)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .strokeBorder(
                        LinearGradient(
                            colors: [Color(white: 0.30), Color(white: 0.12)],
                            startPoint: .top,
                            endPoint: .bottom
                        ),
                        lineWidth: 1
                    )
            )
            .overlay(knurling)
    }
    
    // MARK: - Knurling texture
    
    private var knurling: some View {
        Canvas { context, size in
            let spacing: CGFloat = 4
            let count = Int(size.width / spacing)
            for i in 0..<count {
                let x = CGFloat(i) * spacing + spacing / 2
                var path = Path()
                path.move(to: CGPoint(x: x, y: 2))
                path.addLine(to: CGPoint(x: x, y: size.height - 2))
                context.stroke(
                    path,
                    with: .color(Color.white.opacity(i % 2 == 0 ? 0.06 : 0.02)),
                    lineWidth: 1
                )
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .allowsHitTesting(false)
    }
    
    // MARK: - Black instrument face
    
    private var dialFace: some View {
        RoundedRectangle(cornerRadius: 8)
            .fill(Color(red: 0.02, green: 0.02, blue: 0.04))
            .padding(5)
    }
    
    // MARK: - Selection window
    
    private var selectionWindow: some View {
        RoundedRectangle(cornerRadius: 6)
            .fill(accentColor.opacity(0.06))
            .overlay(
                RoundedRectangle(cornerRadius: 6)
                    .strokeBorder(accentColor.opacity(0.5), lineWidth: 1.5)
            )
            .frame(width: itemWidth + 8, height: 52)
    }
    
    // MARK: - Number strip
    
    private var numberStrip: some View {
        HStack(spacing: 0) {
            ForEach(-4...4, id: \.self) { offset in
                let idx = currentIndex + offset
                let isCenter = offset == 0
                let dist = abs(offset)
                
                Group {
                    if idx >= 0 && idx < allValues.count {
                        Text(displayFormat(allValues[idx]))
                            .font(.system(
                                size: isCenter ? 28 : 17,
                                weight: isCenter ? .bold : .medium,
                                design: .monospaced
                            ))
                            .foregroundColor(
                                isCenter ? accentColor :
                                    Color(white: max(0.25, 0.6 - Double(dist) * 0.1))
                            )
                            .minimumScaleFactor(0.7)
                            .lineLimit(1)
                    } else {
                        Text("")
                    }
                }
                .frame(width: itemWidth)
                .scaleEffect(isCenter ? 1.0 : max(0.7, 1.0 - Double(dist) * 0.08))
                .opacity(isCenter ? 1.0 : max(0.2, 0.8 - Double(dist) * 0.17))
            }
        }
    }
    
    // MARK: - Suffix
    
    private var suffixLabel: some View {
        HStack {
            Spacer()
            Text(suffix)
                .font(.system(size: 9, weight: .bold, design: .monospaced))
                .foregroundColor(accentColor.opacity(0.4))
                .padding(.trailing, 14)
        }
    }
}
