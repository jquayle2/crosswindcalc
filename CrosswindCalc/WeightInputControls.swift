import SwiftUI

struct WeightInputControls: View {
    @ObservedObject var weight: SharedWeight
    let cyan: Color
    
    var body: some View {
        VStack(spacing: 20) {
            fuelSlider
            buttonRow(label: "PAX", value: Binding(
                get: { weight.paxWeight },
                set: { weight.paxWeight = $0 }
            ), options: weight.paxOptions, color: cyan)
            buttonRow(label: "BAGGAGE", value: Binding(
                get: { weight.baggage },
                set: { weight.baggage = $0 }
            ), options: weight.baggageOptions, color: cyan)
        }
    }
    
    private var fuelSlider: some View {
        VStack(spacing: 6) {
            HStack {
                Text("FUEL")
                    .font(.system(size: 12, weight: .bold, design: .monospaced))
                    .foregroundColor(cyan)
                
                Spacer()
                
                Text("\(String(format: "%.1f", weight.fuelGallons)) gal  (\(Int(weight.fuelLbs)) lbs)")
                    .font(.system(size: 14, weight: .semibold, design: .monospaced))
                    .foregroundColor(.white)
            }
            
            Slider(value: Binding(
                get: { weight.fuelGallons },
                set: { weight.fuelGallons = $0 }
            ), in: 0...weight.fuelCapacity)
                .tint(cyan)
        }
    }
    
    private func buttonRow(label: String, value: Binding<Double>, options: [Double], color: Color) -> some View {
        VStack(spacing: 8) {
            Text(label)
                .font(.system(size: 12, weight: .bold, design: .monospaced))
                .foregroundColor(color)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            HStack(spacing: 8) {
                ForEach(options, id: \.self) { option in
                    Button(action: {
                        withAnimation(.easeInOut(duration: 0.15)) {
                            value.wrappedValue = value.wrappedValue == option ? 0 : option
                        }
                    }) {
                        Text("\(Int(option))")
                            .font(.system(size: 16, weight: .bold, design: .monospaced))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(value.wrappedValue == option ? color.opacity(0.25) : Color(white: 0.06))
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(value.wrappedValue == option ? color : Color(white: 0.15), lineWidth: value.wrappedValue == option ? 2 : 1)
                            )
                            .foregroundColor(value.wrappedValue == option ? color : Color(white: 0.4))
                    }
                }
            }
        }
    }
}
