import SwiftUI

struct CrosswindReadout: View {
    let crosswind: Int
    let gustCrosswind: Int?
    let headwind: Int
    let side: String
    let color: Color
    let runway: Int
    let windDirection: Int
    let windSpeed: Int
    let gustSpeed: Int?
    
    private var gustAddKts: Int? {
        guard let gust = gustSpeed, gust > windSpeed else { return nil }
        let add = (gust - windSpeed + 1) / 2
        return add > 0 ? add : nil
    }
    
    var body: some View {
        VStack(spacing: 6) {
            Text("CROSSWIND")
                .font(.system(size: 12, weight: .bold, design: .monospaced))
                .tracking(4)
                .foregroundColor(Color(white: 0.4))
            
            // Main crosswind number with arrows
            HStack(spacing: 6) {
                if side == "L" {
                    Image(systemName: "arrow.right")
                        .font(.system(size: 44, weight: .heavy))
                        .foregroundColor(color)
                }
                
                HStack(alignment: .firstTextBaseline, spacing: 2) {
                    Text("\(crosswind)")
                        .font(.system(size: 96, weight: .heavy, design: .rounded))
                        .foregroundColor(color)
                    
                    if let gust = gustCrosswind, gust > crosswind {
                        Text("G\(gust)")
                            .font(.system(size: 96, weight: .heavy, design: .rounded))
                            .foregroundColor(color)
                    }
                }
                
                if side == "R" {
                    Image(systemName: "arrow.left")
                        .font(.system(size: 44, weight: .heavy))
                        .foregroundColor(color)
                }
            }
            
            Text("kt")
                .font(.system(size: 18, weight: .medium, design: .monospaced))
                .foregroundColor(Color(white: 0.3))
            
            // Headwind line - big
            HStack(spacing: 6) {
                Text(headwind >= 0 ? "HEADWIND" : "TAILWIND")
                    .foregroundColor(Color(white: 0.45))
                Text("\(abs(headwind)) kt")
                    .foregroundColor(headwind >= 0 ? .green : .red)
            }
            .font(.system(size: 22, weight: .bold, design: .monospaced))
            
            // Winds line below
            HStack(spacing: 10) {
                Text("RWY \(String(format: "%02d", runway))")
                    .foregroundColor(Color(white: 0.35))
                Text("·").foregroundColor(Color(white: 0.2))
                Group {
                    let g = gustSpeed.map { "G\($0)" } ?? ""
                    Text("\(String(format: "%03d", windDirection))@\(windSpeed)\(g)")
                        .foregroundColor(Color(white: 0.35))
                }
            }
            .font(.system(size: 15, weight: .semibold, design: .monospaced))
            
            // Advisories
            VStack(spacing: 4) {
                if let addKts = gustAddKts {
                    HStack(spacing: 6) {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .foregroundColor(.orange)
                        Text("Increase Vref by \(addKts) kt")
                            .foregroundColor(.orange)
                    }
                    .font(.system(size: 15, weight: .semibold, design: .monospaced))
                }
                
                if crosswind > 10 {
                    HStack(spacing: 6) {
                        Image(systemName: "wind")
                            .foregroundColor(.yellow)
                        Text("Consider reducing flaps")
                            .foregroundColor(.yellow)
                    }
                    .font(.system(size: 15, weight: .semibold, design: .monospaced))
                }
            }
            .padding(.top, 2)
        }
        .padding(.vertical, 16)
        .padding(.horizontal, 12)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(white: 0.04))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(color.opacity(0.15), lineWidth: 1)
                )
        )
    }
}
