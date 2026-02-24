import SwiftUI

struct VSpeedView: View {
    @EnvironmentObject var weight: SharedWeight
    
    // MGW reference speeds (KIAS at 1800 lbs)
    private let vaAtMGW: Double = 123
    private let vs1AtMGW: Double = 55
    private let vsoAtMGW: Double = 51
    private let bestGlideAtMGW: Double = 97
    private let vfeFullAtMGW: Double = 96
    private let vfePartialAtMGW: Double = 86
    
    @Environment(\.horizontalSizeClass) private var sizeClass
    private var isIPad: Bool { sizeClass == .regular }
    
    // V-speeds scale with sqrt of weight ratio
    private var va: Double { vaAtMGW * weight.sqrtWeightRatio }
    private var vs1: Double { vs1AtMGW * weight.sqrtWeightRatio }
    private var vso: Double { vsoAtMGW * weight.sqrtWeightRatio }
    private var bestGlide: Double { bestGlideAtMGW * weight.sqrtWeightRatio }
    private var vfeFull: Double { vfeFullAtMGW * weight.sqrtWeightRatio }
    private var vfePartial: Double { vfePartialAtMGW * weight.sqrtWeightRatio }
    
    private var weightColor: Color {
        if weight.isOverGross { return .red }
        if weight.currentWeight > weight.maxGross * 0.95 { return .orange }
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
            
            Text("\(Int(weight.currentWeight))")
                .font(.system(size: 72, weight: .heavy, design: .rounded))
                .foregroundColor(weightColor)
            
            Text("lbs  /  \(Int(weight.maxGross)) MGW")
                .font(.system(size: 14, weight: .medium, design: .monospaced))
                .foregroundColor(Color(white: 0.4))
            
            if weight.isOverGross {
                Text("OVER GROSS BY \(Int(weight.currentWeight - weight.maxGross)) LBS")
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
            
            speedRow(label: "Va", value: va, unit: "KIAS", highlight: true)
            speedRow(label: "Vs1", value: vs1, unit: "KIAS")
            speedRow(label: "Vso", value: vso, unit: "KIAS")
            vfeRow()
            speedRow(label: "GLIDE", value: bestGlide, unit: "KIAS")
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
    
    private func vfeRow() -> some View {
        HStack {
            Text("Vfe")
                .font(.system(size: 16, weight: .bold, design: .monospaced))
                .foregroundColor(Color(white: 0.5))
                .frame(width: 60, alignment: .leading)
            
            Spacer()
            
            HStack(spacing: 4) {
                Text("\(Int(round(vfePartial)))")
                    .font(.system(size: 28, weight: .heavy, design: .rounded))
                    .foregroundColor(.white)
                Text("/")
                    .font(.system(size: 20, weight: .medium, design: .rounded))
                    .foregroundColor(Color(white: 0.3))
                Text("\(Int(round(vfeFull)))")
                    .font(.system(size: 28, weight: .heavy, design: .rounded))
                    .foregroundColor(.white)
            }
            
            Text("KIAS")
                .font(.system(size: 10, weight: .medium, design: .monospaced))
                .foregroundColor(Color(white: 0.3))
                .frame(width: 40, alignment: .leading)
        }
    }
    
    // MARK: - Inputs Panel
    
    private var inputsPanel: some View {
        VStack(spacing: 20) {
            Text("WEIGHT INPUTS")
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
