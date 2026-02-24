import SwiftUI

struct PerfView: View {
    @EnvironmentObject var weight: SharedWeight
    @StateObject private var metarService = MetarService()
    
    // Sea level / standard day / MGW baseline distances (ft)
    private let toDistBaseline: Double = 575
    private let ldgDistBaseline: Double = 500
    
    // Manual DA options
    private let daOptions: [Int] = [4000, 6000, 8000, 10000, 12000]
    @State private var manualDA: Int? = nil
    @State private var useAutoDA: Bool = false
    
    @Environment(\.horizontalSizeClass) private var sizeClass
    private var isIPad: Bool { sizeClass == .regular }
    
    // MARK: - Calculations
    
    private var activeDensityAltitude: Int {
        if useAutoDA, let autoDA = metarService.densityAltitude {
            return autoDA
        }
        return manualDA ?? 0
    }
    
    // DA adjustment: ~1% per 100ft DA
    private var daFactor: Double { 1.0 + (Double(activeDensityAltitude) / 100.0 * 0.01) }
    private var weightFactor: Double { weight.weightRatio }
    
    private var toDistance: Int { Int(round(toDistBaseline * weightFactor * daFactor)) }
    private var ldgDistance: Int { Int(round(ldgDistBaseline * weightFactor * daFactor)) }
    
    private var toPctChange: Double { (Double(toDistance) / toDistBaseline - 1.0) * 100.0 }
    private var ldgPctChange: Double { (Double(ldgDistance) / ldgDistBaseline - 1.0) * 100.0 }
    
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
                weightPanel
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
            
            if weight.isOverGross {
                Text("OVER GROSS BY \(Int(weight.currentWeight - weight.maxGross)) LBS")
                    .font(.system(size: 14, weight: .heavy, design: .monospaced))
                    .foregroundColor(.red)
            }
            
            HStack(spacing: 4) {
                Text("\(Int(weight.currentWeight)) lbs")
                    .foregroundColor(.white)
                Text("  DA \(activeDensityAltitude) ft")
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
        VStack(spacing: 12) {
            Text("DENSITY ALTITUDE")
                .font(.system(size: 11, weight: .bold, design: .monospaced))
                .tracking(3)
                .foregroundColor(cyan.opacity(0.6))
            
            // Auto METAR button
            metarButton
            
            // Manual DA buttons
            HStack(spacing: 6) {
                ForEach(daOptions, id: \.self) { da in
                    Button(action: {
                        withAnimation(.easeInOut(duration: 0.15)) {
                            useAutoDA = false
                            manualDA = manualDA == da ? nil : da
                        }
                    }) {
                        Text("\(da / 1000)k")
                            .font(.system(size: 14, weight: .bold, design: .monospaced))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(!useAutoDA && manualDA == da ? cyan.opacity(0.25) : Color(white: 0.06))
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(!useAutoDA && manualDA == da ? cyan : Color(white: 0.15), lineWidth: !useAutoDA && manualDA == da ? 2 : 1)
                            )
                            .foregroundColor(!useAutoDA && manualDA == da ? cyan : Color(white: 0.4))
                    }
                }
            }
            
            // METAR info display
            if useAutoDA, let metar = metarService.metar {
                VStack(spacing: 4) {
                    Text(metar.stationId)
                        .font(.system(size: 14, weight: .bold, design: .monospaced))
                        .foregroundColor(.white)
                    
                    HStack(spacing: 12) {
                        Text("\(Int(round(metar.tempC)))°C")
                        Text("\(String(format: "%.2f", metar.altimeterInHg))\"")
                        Text("\(Int(round(metar.elevation)))ft elev")
                    }
                    .font(.system(size: 11, weight: .medium, design: .monospaced))
                    .foregroundColor(Color(white: 0.4))
                    
                    Text(metar.raw)
                        .font(.system(size: 9, weight: .regular, design: .monospaced))
                        .foregroundColor(Color(white: 0.25))
                        .lineLimit(2)
                        .multilineTextAlignment(.center)
                }
                .padding(.top, 4)
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity)
        .background(panelColor.cornerRadius(12))
    }
    
    private var metarButton: some View {
        Button(action: {
            withAnimation(.easeInOut(duration: 0.15)) {
                useAutoDA = true
                manualDA = nil
            }
            metarService.requestLocation()
        }) {
            HStack(spacing: 8) {
                if metarService.isLoading {
                    ProgressView()
                        .tint(cyan)
                        .scaleEffect(0.8)
                } else {
                    Image(systemName: "location.fill")
                        .font(.system(size: 14))
                }
                
                if let da = metarService.densityAltitude, useAutoDA {
                    Text("DA \(da) ft")
                        .font(.system(size: 14, weight: .bold, design: .monospaced))
                } else if let error = metarService.errorMessage {
                    Text(error)
                        .font(.system(size: 12, weight: .medium, design: .monospaced))
                } else {
                    Text("FETCH METAR")
                        .font(.system(size: 14, weight: .bold, design: .monospaced))
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(useAutoDA ? cyan.opacity(0.25) : Color(white: 0.06))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(useAutoDA ? cyan : Color(white: 0.15), lineWidth: useAutoDA ? 2 : 1)
            )
            .foregroundColor(useAutoDA ? cyan : Color(white: 0.4))
        }
    }
    
    // MARK: - Weight Panel
    
    private var weightPanel: some View {
        VStack(spacing: 20) {
            Text("WEIGHT")
                .font(.system(size: 11, weight: .bold, design: .monospaced))
                .tracking(3)
                .foregroundColor(cyan.opacity(0.6))
            
            WeightInputControls(weight: weight, cyan: cyan)
        }
        .padding(16)
        .frame(maxWidth: .infinity)
        .background(panelColor.cornerRadius(12))
    }
}
