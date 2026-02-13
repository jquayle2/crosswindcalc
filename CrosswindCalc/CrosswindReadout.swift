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
        VStack(spacing: 8) {
            Text("CROSSWIND")
                .font(.system(size: 12, weight: .bold, design: .monospaced))
                .tracking(4)
                .foregroundColor(Color(white: 0.4))
            
            // Main crosswind number with arrows
            HStack(spacing: 10) {
                if side == "L" {
                    Image(systemName: "arrow.right")
                        .font(.system(size: 44, weight: .heavy))
                        .foregroundColor(color)
                }
                
                HStack(alignment: .firstTextBaseline, spacing: 4) {
                    Text("\(crosswind)")
                        .font(.system(size: 96, weight: .heavy, design: .rounded))
                        .foregroundColor(color)
                    
                    if let gust = gustCrosswind, gust > crosswind {
                        Text("G\(gust)")
                            .font(.system(size: 52, weight: .heavy, design: .rounded))
                            .foregroundColor(color.opacity(0.7))
                    }
                    
                    Text("kt")
                        .font(.system(size: 22, weight: .medium, design: .monospaced))
                        .foregroundColor(Color(white: 0.25))
                }
                
                if side == "R" {
                    Image(systemName: "arrow.left")
                        .font(.system(size: 44, weight: .heavy))
                        .foregroundColor(color)
                }
            }
            .frame(minHeight: 90)
            
            // Info line - bigger
            HStack(spacing: 14) {
                HStack(spacing: 4) {
                    Text(headwind >= 0 ? "HEAD" : "TAIL")
                        .foregroundColor(Color(white: 0.4))
                    Text("\(abs(headwind))kt")
                        .foregroundColor(headwind >= 0 ? .green : .red)
                }
                
                Text("·").foregroundColor(Color(white: 0.25))
                
                Text("RWY \(String(format: "%02d", runway))")
                    .foregroundColor(Color(white: 0.4))
                
                Text("·").foregroundColor(Color(white: 0.25))
                
                Group {
                    let g = gustSpeed.map { "G\($0)" } ?? ""
                    Text("\(String(format: "%03d", windDirection))@\(windSpeed)\(g)")
                        .foregroundColor(Color(white: 0.4))
                }
            }
            .font(.system(size: 18, weight: .semibold, design: .monospaced))
            
            // Advisory callouts
            VStack(spacing: 6) {
                if let addKts = gustAddKts {
                    HStack(spacing: 6) {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .foregroundColor(.orange)
                            .font(.system(size: 14))
                        Text("Increase Vref by \(addKts) kt")
                            .font(.system(size: 16, weight: .semibold, design: .monospaced))
                            .foregroundColor(.orange)
                    }
                }
                
                if crosswind > 10 {
                    HStack(spacing: 6) {
                        Image(systemName: "wind")
                            .foregroundColor(.yellow)
                            .font(.system(size: 14))
                        Text("Consider reducing flaps")
                            .font(.system(size: 16, weight: .semibold, design: .monospaced))
                            .foregroundColor(.yellow)
                    }
                }
            }
            .padding(.top, 4)
        }
        .padding(.vertical, 20)
        .padding(.horizontal, 16)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(white: 0.04))
                .shadow(color: color.opacity(0.08), radius: 20)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(color.opacity(0.15), lineWidth: 1)
                )
        )
    }
}
