import SwiftUI

struct PerfView: View {
    // MARK: - Aircraft constants (RV-7)
    private let emptyWeight: Double = 1096
    private let pilotWeight: Double = 178
    private let maxGross: Double = 1800
    private let fuelCapacity: Double = 42
    private let fuelWeight: Double = 6.0
    private let paxOptions: [Double] = [100, 130, 160, 200]
    private let baggageOptions: [Double] = [25, 50, 75, 100]
    
    // Sea level / standard day / MGW baseline distances (ft)
    private let toDistBaseline: Double = 575
    private let ldgDistBaseline: Double = 500
    
    // DA options
    private let daOptions: [Int] = [0, 1000, 2000, 3000, 4000, 5000]
    
    // MARK: - State
    @AppStorage("perf_fuel") private var fuelGallons: Double = 42
    @AppStorage("perf_baggage") private var baggage: Double = 0
    @AppStorage("perf_pax") private var paxWeight: Double = 0
    @AppStorage("perf_da") private var densityAltitude: Int = 0
    
    @Environment(\.horizontalSizeClass) private var sizeClass
    private var isIPad: Bool { sizeClass == .regular }
    
    // MARK: - Calculations
    
    private var fuelLbs: Double { fuelGallons * fuelWeight }
    
    private var currentWeight: Double {
        emptyWeight + pilotWeight + fuelLbs + paxWeight + baggage
    }
    
    private var weightRatio: Double { currentWeight / maxGross }
    
    // DA adjustment: ~1% per 100ft DA (conservative Koch chart approximation)
    private var daFactor: Double { 1.0 + (Double(densityAltitude) / 100.0 * 0.01) }
    
    // Weight adjustment: distance scales roughly with weight ratio
    private var weightFactor: Double { weightRatio }
    
    // Combined adjusted distances
    private var toDistance: Int { Int(round(toDistBaseline * weightFactor * daFactor)) }
    private var ldgDistance: Int { Int(round(ldgDistBaseline * weightFactor * daFactor)) }
    
    // Percentage change from baseline
    private var toPctChange: Double { (Double(toDistance) / toDistBaseline - 1.0) * 100.0 }
    private var ldgPctChange: Double { (Double(ldgDistance) / ldgDistBaseline - 1.0) * 100.0 }
    
    private var isOverGross: Bool { currentWeight > maxGross }
    
    // MARK: - Colors
    private let amber = Color(red: 0.94, green: 0.75, blue: 0.25)
    private let cyan = Color(red: 0.22, green: 0.74, blue: 0.97)
    private let bgColor = Color(red: 0.04, green: 0.05, blue: 0.09)
    private let panelColor = Color(white: 0.08)
    
    // MARK: - Body
    
    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                distancesPanel
                daPanel
                weightInputsPanel
            }
            .padding(.horizontal, 16)
            .padding(.top, 8)
            .padding(.bottom, 24)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(bgColor)
    }
    
    // MARK: - Distances Panel
    
    private var distancesPanel: some View {
        VStack(spacing: 16) {
            Text("PERFORMANCE")
                .font(.system(size: 12, weight: .bold, design: .monospaced))
                .tracking(4)
                .foregroundColor(amber.opacity(0.6))
            
            HStack(spacing: 16) {
                distanceBlock(label: "TAKEOFF", distance: toDistance, pctChange: toPctChange)
                distanceBlock(label: "LANDING", distance: ldgDistance, pctChange: ldgPctChange)
            }
            
            if isOverGross {
                Text("⚠ OVER GROSS BY \(Int(currentWeight - maxGross)) LBS")
                    .font(.system(size: 14, weight: .heavy, design: .monospaced))
                    .foregroundColor(.red)
            }
            
            HStack(spacing: 4) {
                Text("\(Int(currentWeight)) lbs")
                    .foregroundColor(.white)
                Text("  DA \(densityAltitude) ft")
                    .foregroundColor(Color(white: 0.4))
            }
            .font(.system(size: 12, weight: .medium, design: .monospaced))
        }
        .padding(16)
        .frame(maxWidth: .infinity)
        .background(panelColor.cornerRadius(12))
    }
    
    private func distanceBlock(label: String, distance: Int, pctChange: Double) -> some View {
        VStack(spacing: 6) {
            Text(label)
                .font(.system(size: 11, weight: .bold, design: .monospaced))
                .tracking(2)
                .foregroundColor(amber.opacity(0.6))
            
            Text("\(distance)")
                .font(.system(size: 48, weight: .heavy, design: .rounded))
                .foregroundColor(.white)
            
            Text("ft")
                .font(.system(size: 14, weight: .medium, design: .monospaced))
                .foregroundColor(Color(white: 0.4))
            
            if abs(pctChange) >= 1 {
                Text(pctChange > 0 ? "+\(Int(round(pctChange)))%" : "\(Int(round(pctChange)))%")
                    .font(.system(size: 16, weight: .bold, design: .monospaced))
                    .foregroundColor(pctChange > 0 ? .orange : .green)
            }
        }
        .frame(maxWidth: .infinity)
    }
    
    // MARK: - DA Panel
    
    private var daPanel: some View {
        VStack(spacing: 8) {
            Text("DENSITY ALTITUDE")
                .font(.system(size: 12, weight: .bold, design: .monospaced))
                .foregroundColor(cyan)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            HStack(spacing: 6) {
                ForEach(daOptions, id: \.self) { da in
                    Button(action: {
                        withAnimation(.easeInOut(duration: 0.15)) {
                            densityAltitude = da
                        }
                    }) {
                        Text(da == 0 ? "SL" : "\(da / 1000)k")
                            .font(.system(size: 14, weight: .bold, design: .monospaced))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(densityAltitude == da ? cyan.opacity(0.25) : Color(white: 0.06))
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(densityAltitude == da ? cyan : Color(white: 0.15), lineWidth: densityAltitude == da ? 2 : 1)
                            )
                            .foregroundColor(densityAltitude == da ? cyan : Color(white: 0.4))
                    }
                }
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity)
        .background(panelColor.cornerRadius(12))
    }
    
    // MARK: - Weight Inputs
    
    private var weightInputsPanel: some View {
        VStack(spacing: 20) {
            Text("WEIGHT")
                .font(.system(size: 11, weight: .bold, design: .monospaced))
                .tracking(3)
                .foregroundColor(cyan.opacity(0.6))
            
            fuelSlider
            buttonRow(label: "PAX", value: $paxWeight, options: paxOptions, color: cyan)
            buttonRow(label: "BAGGAGE", value: $baggage, options: baggageOptions, color: cyan)
        }
        .padding(16)
        .frame(maxWidth: .infinity)
        .background(panelColor.cornerRadius(12))
    }
    
    private var fuelSlider: some View {
        VStack(spacing: 6) {
            HStack {
                Text("FUEL")
                    .font(.system(size: 12, weight: .bold, design: .monospaced))
                    .foregroundColor(cyan)
                
                Spacer()
                
                Text("\(String(format: "%.1f", fuelGallons)) gal  (\(Int(fuelLbs)) lbs)")
                    .font(.system(size: 14, weight: .semibold, design: .monospaced))
                    .foregroundColor(.white)
            }
            
            Slider(value: $fuelGallons, in: 0...fuelCapacity)
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
