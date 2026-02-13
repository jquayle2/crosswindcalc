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
    
    @State private var dragOffset: CGFloat = 0
    @State private var isDragging = false
    @GestureState private var dragState: CGFloat = 0
    
    private let itemWidth: CGFloat = 56
    private let visibleCount = 9
    
    private var effectiveMin: Int { minValue ?? range.lowerBound }
    
    private var allValues: [Int] {
        stride(from: effectiveMin, through: range.upperBound, by: step).map { $0 }
    }
    
    private var currentIndex: Int {
        allValues.firstIndex(of: value) ?? 0
    }
    
    var body: some View {
        VStack(spacing: 6) {
            Text(title)
                .font(.system(size: 10, weight: .semibold, design: .monospaced))
                .tracking(2.5)
                .foregroundColor(Color(white: 0.55))
            
            ZStack {
                // Outer bezel - knurled look
                RoundedRectangle(cornerRadius: 14)
                    .fill(
                        LinearGradient(
                            colors: [
                                Color(white: 0.18),
                                Color(white: 0.10),
                                Color(white: 0.14),
                                Color(white: 0.08)
                            ],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 14)
                            .stroke(Color(white: 0.22), lineWidth: 1)
                    )
                    .overlay(knurledTexture)
                
                // Inner dial face
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color(red: 0.03, green: 0.03, blue: 0.05))
                    .padding(6)
                
                // Center selection window
                RoundedRectangle(cornerRadius: 8)
                    .fill(accentColor.opacity(0.08))
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(accentColor.opacity(0.5), lineWidth: 1.5)
                    )
                    .frame(width: itemWidth + 10)
                    .padding(.vertical, 6)
                
                // Number strip
                HStack(spacing: 0) {
                    let half = visibleCount / 2
                    ForEach(-half...half, id: \.self) { offset in
                        let idx = currentIndex + offset
                        let isCenter = offset == 0
                        let dist = abs(offset)
                        
                        if idx >= 0 && idx < allValues.count {
                            let val = allValues[idx]
                            Text(isCenter ? displayFormat(val) : "\(val)")
                                .font(.system(
                                    size: isCenter ? 34 : 20,
                                    weight: isCenter ? .bold : .regular,
                                    design: .monospaced
                                ))
                                .foregroundColor(
                                    isCenter ? accentColor :
                                    Color(white: max(0.2, 0.65 - Double(dist) * 0.12))
                                )
                                .frame(width: itemWidth)
                                .scaleEffect(isCenter ? 1.0 : max(0.65, 1.0 - Double(dist) * 0.09))
                                .opacity(isCenter ? 1.0 : max(0.25, 0.9 - Double(dist) * 0.18))
                        } else {
                            Color.clear.frame(width: itemWidth)
                        }
                    }
                }
                
                // Suffix label
                if !suffix.isEmpty {
                    HStack {
                        Spacer()
                        Text(suffix)
                            .font(.system(size: 10, weight: .semibold, design: .monospaced))
                            .foregroundColor(accentColor.opacity(0.5))
                            .padding(.trailing, 16)
                    }
                }
            }
            .frame(height: 76)
            .contentShape(Rectangle())
            .gesture(
                DragGesture()
                    .onChanged { gesture in
                        isDragging = true
                        let shift = Int(round(-gesture.translation.width / itemWidth))
                        let newIndex = max(0, min(allValues.count - 1, currentIndex + shift))
                        if allValues[newIndex] != value {
                            value = allValues[newIndex]
                            let impactFeedback = UIImpactFeedbackGenerator(style: .light)
                            impactFeedback.impactOccurred()
                        }
                    }
                    .onEnded { _ in
                        isDragging = false
                    }
            )
        }
    }
    
    private var knurledTexture: some View {
        HStack(spacing: 2) {
            ForEach(0..<40, id: \.self) { i in
                Rectangle()
                    .fill(
                        i % 2 == 0 ?
                        Color(white: 0.16) :
                        Color(white: 0.11)
                    )
                    .frame(width: 1)
            }
        }
        .mask(
            RoundedRectangle(cornerRadius: 14)
                .frame(height: 76)
        )
        .opacity(0.3)
    }
}
