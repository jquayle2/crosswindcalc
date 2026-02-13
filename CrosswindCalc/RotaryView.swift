import SwiftUI

enum KnobID: String {
    case runway, wind, speed, gust
}

struct RotaryView: View {
    @State private var runway: Int = 18
    @State private var windDirection: Int = 210
    @State private var windSpeed: Int = 15
    @State private var gustSpeed: Int = 15
    
    @State private var activeKnob: KnobID? = nil
    
    private var crosswind: Int {
        let angle = Double(windDirection - runway * 10) * .pi / 180
        return abs(Int(round(Double(windSpeed) * sin(angle))))
    }
    
    private var gustCrosswind: Int {
        guard gustSpeed > windSpeed else { return crosswind }
        let angle = Double(windDirection - runway * 10) * .pi / 180
        return abs(Int(round(Double(gustSpeed) * sin(angle))))
    }
    
    private var headwind: Int {
        let angle = Double(windDirection - runway * 10) * .pi / 180
        return Int(round(Double(windSpeed) * cos(angle)))
    }
    
    private var side: String {
        let diff = ((windDirection - runway * 10) % 360 + 360) % 360
        if diff > 0 && diff < 180 { return "L" }
        if diff > 180 { return "R" }
        return ""
    }
    
    private var severityColor: Color {
        let xw = gustSpeed > windSpeed ? gustCrosswind : crosswind
        if xw >= 20 { return .red }
        if xw >= 15 { return .orange }
        return .green
    }
    
    private var activeDisplayText: String {
        switch activeKnob {
        case .runway: return String(format: "%02d", runway)
        case .wind: return "\(windDirection)°"
        case .speed: return "\(windSpeed) kt"
        case .gust: return "\(gustSpeed) kt"
        case nil: return ""
        }
    }
    
    private var activeDisplayLabel: String {
        switch activeKnob {
        case .runway: return "RUNWAY"
        case .wind: return "WIND"
        case .speed: return "SPEED"
        case .gust: return "GUST"
        case nil: return ""
        }
    }
    
    private var activeColor: Color {
        switch activeKnob {
        case .runway: return Color(red: 0.94, green: 0.75, blue: 0.25)
        case .wind: return Color(red: 0.22, green: 0.74, blue: 0.97)
        case .speed: return Color(red: 0.22, green: 0.74, blue: 0.97)
        case .gust: return Color(red: 1.0, green: 0.58, blue: 0.0)
        case nil: return .white
        }
    }
    
    var body: some View {
        VStack(spacing: 12) {
            // Top readout - switches between crosswind and active knob
            ZStack {
                // Crosswind display (shown when no knob active)
                CrosswindReadout(
                    crosswind: crosswind,
                    gustCrosswind: gustSpeed > windSpeed ? gustCrosswind : nil,
                    headwind: headwind,
                    side: side,
                    color: severityColor,
                    runway: runway,
                    windDirection: windDirection,
                    windSpeed: windSpeed,
                    gustSpeed: gustSpeed > windSpeed ? gustSpeed : nil
                )
                .opacity(activeKnob == nil ? 1 : 0)
                
                // Active knob value (shown while adjusting)
                VStack(spacing: 6) {
                    Text(activeDisplayLabel)
                        .font(.system(size: 12, weight: .bold, design: .monospaced))
                        .tracking(4)
                        .foregroundColor(activeColor.opacity(0.6))
                    
                    Text(activeDisplayText)
                        .font(.system(size: 96, weight: .heavy, design: .rounded))
                        .foregroundColor(activeColor)
                        .minimumScaleFactor(0.7)
                        .lineLimit(1)
                }
                .padding(.vertical, 20)
                .frame(maxWidth: .infinity)
                .opacity(activeKnob != nil ? 1 : 0)
            }
            .frame(height: 280)
            .clipped()
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color(white: 0.04))
            )
            .animation(.easeInOut(duration: 0.15), value: activeKnob)
            .padding(.top, 8)
            
            Spacer().frame(height: 8)
            
            // 2x2 knob grid
            HStack(spacing: 16) {
                RotaryKnob(
                    label: "RWY",
                    value: $runway,
                    range: 1...36,
                    step: 1,
                    wraps: true,
                    displayFormat: { String(format: "%02d", $0) },
                    color: Color(red: 0.94, green: 0.75, blue: 0.25),
                    knobID: .runway,
                    activeKnob: $activeKnob
                )
                
                RotaryKnob(
                    label: "WIND",
                    value: $windDirection,
                    range: 0...350,
                    step: 10,
                    wraps: true,
                    displayFormat: { "\($0)°" },
                    color: Color(red: 0.22, green: 0.74, blue: 0.97),
                    knobID: .wind,
                    activeKnob: $activeKnob
                )
            }
            
            HStack(spacing: 16) {
                RotaryKnob(
                    label: "SPEED",
                    value: $windSpeed,
                    range: 0...60,
                    step: 1,
                    wraps: false,
                    displayFormat: { "\($0)" },
                    color: Color(red: 0.22, green: 0.74, blue: 0.97),
                    knobID: .speed,
                    activeKnob: $activeKnob,
                    suffix: "kt"
                )
                
                RotaryKnob(
                    label: "GUST",
                    value: $gustSpeed,
                    range: 0...60,
                    step: 1,
                    wraps: false,
                    displayFormat: { "\($0)" },
                    color: Color(red: 1.0, green: 0.58, blue: 0.0),
                    knobID: .gust,
                    activeKnob: $activeKnob,
                    suffix: "kt",
                    minValue: windSpeed
                )
            }
            
            Spacer()
        }
        .padding(.horizontal, 16)
        .background(Color(red: 0.04, green: 0.05, blue: 0.09))
        .onChange(of: windSpeed) { _, newValue in
            if gustSpeed < newValue { gustSpeed = newValue }
        }
    }
}
