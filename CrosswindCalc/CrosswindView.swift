import SwiftUI

struct CrosswindView: View {
    @State private var runway: Int = 18
    @State private var windDirection: Int = 210
    @State private var windSpeed: Int = 15
    @State private var gustSpeed: Int = 15
    
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
    
    private var gustHeadwind: Int {
        let angle = Double(windDirection - runway * 10) * .pi / 180
        return Int(round(Double(gustSpeed) * cos(angle)))
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
    
    var body: some View {
        VStack(spacing: 0) {
            // Crosswind readout
            CrosswindReadout(
                crosswind: crosswind,
                gustCrosswind: gustSpeed > windSpeed ? gustCrosswind : nil,
                headwind: headwind,
                gustHeadwind: gustSpeed > windSpeed ? gustHeadwind : nil,
                side: side,
                color: severityColor,
                runway: runway,
                windDirection: windDirection,
                windSpeed: windSpeed,
                gustSpeed: gustSpeed > windSpeed ? gustSpeed : nil
            )
            .padding(.top, 16)
            .padding(.bottom, 20)
            
            // Runway dial
            InstrumentDial(
                title: "RUNWAY",
                value: $runway,
                range: 1...36,
                step: 1,
                displayFormat: { String(format: "%02d", $0) },
                accentColor: Color(red: 0.94, green: 0.75, blue: 0.25),
                snap: true
            )
            .padding(.bottom, 12)
            
            // Wind direction dial
            InstrumentDial(
                title: "WIND",
                value: $windDirection,
                range: 0...360,
                step: 10,
                displayFormat: { "\($0)°" },
                accentColor: Color(red: 0.22, green: 0.74, blue: 0.97),
                snap: true,
                wraps: true
            )
            .padding(.bottom, 12)
            
            // Wind speed dial
            InstrumentDial(
                title: "SPEED",
                value: $windSpeed,
                range: 0...60,
                step: 1,
                displayFormat: { "\($0)" },
                accentColor: Color(red: 0.22, green: 0.74, blue: 0.97),
                suffix: "KT"
            )
            .padding(.bottom, 12)
            
            // Gust dial
            InstrumentDial(
                title: "GUST",
                value: $gustSpeed,
                range: 0...60,
                step: 1,
                displayFormat: { "\($0)" },
                accentColor: Color(red: 1.0, green: 0.58, blue: 0.0),
                suffix: "KT",
                minValue: windSpeed
            )
            
            Spacer()
        }
        .padding(.horizontal, 16)
        .background(Color(red: 0.04, green: 0.06, blue: 0.10))
        .onChange(of: windSpeed) { _, newValue in
            if gustSpeed < newValue {
                gustSpeed = newValue
            }
        }
    }
}

#Preview {
    CrosswindView()
        .preferredColorScheme(.dark)
}
