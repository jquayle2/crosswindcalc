import SwiftUI

enum KnobID: String {
    case runway, wind, speed, gust
}

struct RotaryView: View {
    @AppStorage("runway") private var runway: Int = 18
    @AppStorage("windDirection") private var windDirection: Int = 210
    @AppStorage("windSpeed") private var windSpeed: Int = 15
    @AppStorage("gustSpeed") private var gustSpeed: Int = 15
    
    @State private var activeKnob: KnobID? = nil
    @Environment(\.horizontalSizeClass) private var sizeClass
    
    private var windDeg: Int { windDirection % 360 }
    
    private var crosswind: Int {
        let angle = Double(windDeg - runway * 10) * .pi / 180
        return abs(Int(round(Double(windSpeed) * sin(angle))))
    }
    
    private var gustCrosswind: Int {
        guard gustSpeed > windSpeed else { return crosswind }
        let angle = Double(windDeg - runway * 10) * .pi / 180
        return abs(Int(round(Double(gustSpeed) * sin(angle))))
    }
    
    private var headwind: Int {
        let angle = Double(windDeg - runway * 10) * .pi / 180
        return Int(round(Double(windSpeed) * cos(angle)))
    }
    
    private var side: String {
        let diff = ((windDeg - runway * 10) % 360 + 360) % 360
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
    
    private var isIPad: Bool { sizeClass == .regular }
    
    // MARK: - Readout panel
    
    private var readoutPanel: some View {
        ZStack {
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
            
            VStack(spacing: 6) {
                Text(activeDisplayLabel)
                    .font(.system(size: isIPad ? 16 : 12, weight: .bold, design: .monospaced))
                    .tracking(4)
                    .foregroundColor(activeColor.opacity(0.6))
                
                Text(activeDisplayText)
                    .font(.system(size: isIPad ? 120 : 96, weight: .heavy, design: .rounded))
                    .foregroundColor(activeColor)
                    .minimumScaleFactor(0.7)
                    .lineLimit(1)
            }
            .padding(.vertical, 20)
            .frame(maxWidth: .infinity)
            .opacity(activeKnob != nil ? 1 : 0)
        }
        .frame(height: isIPad ? 400 : 280)
        .clipped()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(white: 0.04))
        )
        .animation(.easeInOut(duration: 0.15), value: activeKnob)
    }
    
    // MARK: - Knob grid
    
    private var knobGrid: some View {
        VStack(spacing: isIPad ? 24 : 16) {
            HStack(spacing: isIPad ? 24 : 16) {
                RotaryKnob(
                    label: "RWY",
                    value: $runway,
                    range: 1...36,
                    step: 1,
                    wraps: true,
                    displayFormat: { String(format: "%02d", $0) },
                    color: Color(red: 0.94, green: 0.75, blue: 0.25),
                    knobID: .runway,
                    activeKnob: $activeKnob,
                    dialLabels: [("36", 0), ("09", 90), ("18", 180), ("27", 270)]
                )
                
                RotaryKnob(
                    label: "WIND",
                    value: $windDirection,
                    range: 10...360,
                    step: 10,
                    wraps: true,
                    displayFormat: { "\($0)°" },
                    color: Color(red: 0.22, green: 0.74, blue: 0.97),
                    knobID: .wind,
                    activeKnob: $activeKnob,
                    dialLabels: [("360", 0), ("90", 90), ("180", 180), ("270", 270)]
                )
            }
            
            HStack(spacing: isIPad ? 24 : 16) {
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
                    suffix: "kt",
                    dialLabels: [("0", 0), ("10", 60), ("20", 120), ("30", 180), ("40", 240), ("50", 300)]
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
                    minValue: windSpeed,
                    dialLabels: [("0", 0), ("10", 60), ("20", 120), ("30", 180), ("40", 240), ("50", 300)]
                )
            }
        }
    }
    
    // MARK: - Body
    
    var body: some View {
        Group {
            if isIPad {
                VStack(spacing: 20) {
                    readoutPanel
                        .frame(maxWidth: 800)
                        .padding(.top, 16)
                    
                    knobGrid
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .padding(.horizontal, 40)
                }
                .padding(.horizontal, 24)
            } else {
                VStack(spacing: 12) {
                    readoutPanel
                        .padding(.top, 8)
                    
                    Spacer().frame(height: 8)
                    
                    knobGrid
                    
                    Spacer()
                }
                .padding(.horizontal, 16)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(red: 0.04, green: 0.05, blue: 0.09))
        .onChange(of: windSpeed) { _, newValue in
            if gustSpeed < newValue { gustSpeed = newValue }
        }
    }
}
