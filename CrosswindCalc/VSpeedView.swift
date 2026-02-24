import SwiftUI

struct VSpeedView: View {
    // MARK: - Aircraft constants (RV-7)
    private let emptyWeight: Double = 1309
    private let pilotWeight: Double = 178
    private let maxGross: Double = 1800
    private let fuelCapacity: Double = 42    // gallons
    private let fuelWeight: Double = 6.0     // lbs per gallon
    private let smokeCapacity: Double = 3.5  // gallons
    private let smokeWeight: Double = 8.0    // lbs per gallon
    private let maxBaggage: Double = 100
    private let baggageCaution: Double = 70
    
    // MGW reference speeds (CAS)
    private let vaAtMGW: Double = 116
    private let vs1AtMGW: Double = 999  // TODO: placeholder
    private let vsoAtMGW: Double = 999  // TODO: placeholder
    private let bestGlideAtMGW: Double = 999  // TODO: placeholder
    private let vfeAtMGW: Double = 999  // TODO: placeholder
    
    // MARK: - State
    @AppStorage("vspeed_fuel") private var fuelGallons: Double = 42
    @AppStorage("vspeed_smoke") private var smokeGallons: Double = 3.5
    @AppStorage("vspeed_baggage") private var baggage: Double = 0
    @AppStorage("vspeed_pax") private var paxWeight: Double = 0
    
    @Environment(\.horizontalSizeClass) private var sizeClass
    private var isIPad: Bool { sizeClass == .regular }
    
    // MARK: - Calculations
    
    private var fuelLbs: Double { fuelGallons * fuelWeight }
    private var smokeLbs: Double { smokeGallons * smokeWeight }
    
    private var currentWeight: Double {
        emptyWeight + pilotWeight + fuelLbs + smokeLbs + paxWeight + baggage
    }
    
    private var weightRatio: Double {
        currentWeight / maxGross
    }
    
    private var sqrtWeightRatio: Double {
        sqrt(weightRatio)
    }
    
    // V-speeds scale with sqrt of weight ratio
    private var va: Double { vaAtMGW * sqrtWeightRatio }
    private var vs1: Double { vs1AtMGW * sqrtWeightRatio }
    private var vso: Double { vsoAtMGW * sqrtWeightRatio }
    private var bestGlide: Double { bestGlideAtMGW * sqrtWeightRatio }
    private var vfe: Double { vfeAtMGW * sqrtWeightRatio }
    
    private var isOverGross: Bool { currentWeight > maxGross }
    
    private var weightColor: Color {
        if isOverGross { return .red }
        if currentWeight > maxGross * 0.95 { return .orange }
        return .green
    }
    
    // MARK: - Colors
    private let amber = Color(red: 0.94, green: 0.75, blue: 0.25)
    private let cyan = Color(red: 0.22, green: 0.74, blue: 0.97)
    private let bgColor = Color(red: 0.04, green: 0.05, blue: 0.09)
    private let panelColor = Color(white: 0.08)
    
    // MARK: - Body
    
    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                weightHeader
                speedsPanel
                inputsPanel
                densityAltitudeStub
            }
            .padding(.horizontal, 16)
            .padding(.top, 8)
            .padding(.bottom, 24)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(bgColor)
    }
    
    // MARK: - Weight Header
    
    private var weightHeader: some View {
        VStack(spacing: 8) {
            Text("CURRENT WEIGHT")
                .font(.system(size: 12, weight: .bold, design: .monospaced))
                .tracking(4)
                .foregroundColor(weightColor.opacity(0.6))
            
            Text("\(Int(currentWeight))")
                .font(.system(size: 72, weight: .heavy, design: .rounded))
                .foregroundColor(weightColor)
            
            Text("lbs  /  \(Int(maxGross)) MGW")
                .font(.system(size: 14, weight: .medium, design: .monospaced))
                .foregroundColor(Color(white: 0.4))
            
            if isOverGross {
                Text("⚠ OVER GROSS BY \(Int(currentWeight - maxGross)) LBS")
                    .font(.system(size: 14, weight: .heavy, design: .monospaced))
                    .foregroundColor(.red)
                    .padding(.top, 4)
            }
        }
        .padding(.vertical, 20)
        .frame(maxWidth: .infinity)
        .background(panelColor.cornerRadius(12))
    }
    
    // MARK: - Speeds Panel
    
    private var speedsPanel: some View {
        VStack(spacing: 12) {
            Text("V-SPEEDS AT WEIGHT")
                .font(.system(size: 11, weight: .bold, design: .monospaced))
                .tracking(3)
                .foregroundColor(amber.opacity(0.6))
            
            speedRow(label: "Va", value: va, unit: "KCAS", highlight: true)
            speedRow(label: "Vs1", value: vs1, unit: "KCAS")
            speedRow(label: "Vso", value: vso, unit: "KCAS")
            speedRow(label: "Vfe", value: vfe, unit: "KCAS")
            speedRow(label: "GLIDE", value: bestGlide, unit: "KCAS")
        }
        .padding(16)
        .frame(maxWidth: .infinity)
        .background(panelColor.cornerRadius(12))
    }
    
    private func speedRow(label: String, value: Double, unit: String, highlight: Bool = false) -> some View {
        HStack {
            Text(label)
                .font(.system(size: 16, weight: .bold, design: .monospaced))
                .foregroundColor(highlight ? amber : Color(white: 0.5))
                .frame(width: 60, alignment: .leading)
            
            Spacer()
            
            Text("\(Int(round(value)))")
                .font(.system(size: highlight ? 36 : 28, weight: .heavy, design: .rounded))
                .foregroundColor(highlight ? amber : .white)
            
            Text(unit)
                .font(.system(size: 10, weight: .medium, design: .monospaced))
                .foregroundColor(Color(white: 0.3))
                .frame(width: 40, alignment: .leading)
        }
        .padding(.vertical, highlight ? 4 : 0)
    }
    
    // MARK: - Inputs Panel
    
    private var inputsPanel: some View {
        VStack(spacing: 20) {
            Text("WEIGHT INPUTS")
                .font(.system(size: 11, weight: .bold, design: .monospaced))
                .tracking(3)
                .foregroundColor(cyan.opacity(0.6))
            
            sliderInput(
                label: "FUEL",
                value: $fuelGallons,
                range: 0...fuelCapacity,
                displayValue: "\(String(format: "%.1f", fuelGallons)) gal  (\(Int(fuelLbs)) lbs)",
                color: cyan
            )
            
            sliderInput(
                label: "SMOKE OIL",
                value: $smokeGallons,
                range: 0...smokeCapacity,
                displayValue: "\(String(format: "%.1f", smokeGallons)) gal  (\(Int(smokeLbs)) lbs)",
                color: cyan
            )
            
            sliderInput(
                label: "PAX",
                value: $paxWeight,
                range: 0...250,
                displayValue: "\(Int(paxWeight)) lbs",
                color: cyan
            )
            
            sliderInput(
                label: "BAGGAGE",
                value: $baggage,
                range: 0...maxBaggage,
                displayValue: "\(Int(baggage)) lbs",
                color: baggage > baggageCaution ? .orange : cyan,
                warning: baggage > baggageCaution ? "CAUTION" : nil
            )
        }
        .padding(16)
        .frame(maxWidth: .infinity)
        .background(panelColor.cornerRadius(12))
    }
    
    private func sliderInput(
        label: String,
        value: Binding<Double>,
        range: ClosedRange<Double>,
        displayValue: String,
        color: Color,
        warning: String? = nil
    ) -> some View {
        VStack(spacing: 6) {
            HStack {
                Text(label)
                    .font(.system(size: 12, weight: .bold, design: .monospaced))
                    .foregroundColor(color)
                
                Spacer()
                
                if let warning = warning {
                    Text(warning)
                        .font(.system(size: 10, weight: .heavy, design: .monospaced))
                        .foregroundColor(.orange)
                }
                
                Text(displayValue)
                    .font(.system(size: 14, weight: .semibold, design: .monospaced))
                    .foregroundColor(.white)
            }
            
            Slider(value: value, in: range)
                .tint(color)
        }
    }
    
    // MARK: - DA Stub
    
    private var densityAltitudeStub: some View {
        VStack(spacing: 8) {
            Text("DENSITY ALTITUDE & PERFORMANCE")
                .font(.system(size: 11, weight: .bold, design: .monospaced))
                .tracking(2)
                .foregroundColor(Color(white: 0.3))
            
            Text("Coming soon — weather & location services")
                .font(.system(size: 12, weight: .medium, design: .monospaced))
                .foregroundColor(Color(white: 0.2))
        }
        .padding(16)
        .frame(maxWidth: .infinity)
        .background(panelColor.cornerRadius(12))
    }
}
