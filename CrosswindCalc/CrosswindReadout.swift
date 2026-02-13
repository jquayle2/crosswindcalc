import SwiftUI

struct CrosswindReadout: View {
    let crosswind: Int
    let gustCrosswind: Int?
    let headwind: Int
    let gustHeadwind: Int?
    let side: String
    let color: Color
    let runway: Int
    let windDirection: Int
    let windSpeed: Int
    let gustSpeed: Int?
    
    var body: some View {
        VStack(spacing: 6) {
            Text("CROSSWIND COMPONENT")
                .font(.system(size: 9, weight: .medium, design: .monospaced))
                .tracking(2.5)
                .foregroundColor(Color(white: 0.35))
            
            // Main crosswind display with arrows
            HStack(spacing: 6) {
                if side == "L" {
                    Image(systemName: "arrow.right")
                        .font(.system(size: 30, weight: .bold))
                        .foregroundColor(color.opacity(0.85))
                }
                
                HStack(alignment: .firstTextBaseline, spacing: 2) {
                    Text("\(crosswind)")
                        .font(.system(size: 56, weight: .bold, design: .rounded))
                        .foregroundColor(color)
                    
                    if let gust = gustCrosswind, gust > crosswind {
                        Text("G\(gust)")
                            .font(.system(size: 28, weight: .bold, design: .rounded))
                            .foregroundColor(color.opacity(0.45))
                    }
                    
                    Text("kt")
                        .font(.system(size: 15, weight: .regular, design: .monospaced))
                        .foregroundColor(Color(white: 0.3))
                }
                
                if side == "R" {
                    Image(systemName: "arrow.left")
                        .font(.system(size: 30, weight: .bold))
                        .foregroundColor(color.opacity(0.85))
                }
            }
            
            // Info line
            HStack(spacing: 10) {
                Text("\(headwind >= 0 ? "HEAD" : "TAIL") ")
                    .foregroundColor(Color(white: 0.3)) +
                Text("\(abs(headwind))kt")
                    .foregroundColor(headwind >= 0 ? .green : .red)
                
                Text("|").foregroundColor(Color(white: 0.12))
                
                Text("RWY \(String(format: "%02d", runway))")
                    .foregroundColor(Color(white: 0.3))
                
                Text("|").foregroundColor(Color(white: 0.12))
                
                Group {
                    let g = gustSpeed.map { "G\($0)" } ?? ""
                    Text("\(String(format: "%03d", windDirection))@\(windSpeed)\(g)")
                        .foregroundColor(Color(white: 0.3))
                }
            }
            .font(.system(size: 11, weight: .medium, design: .monospaced))
        }
        .padding(.vertical, 14)
        .padding(.horizontal, 12)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(white: 0.05))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(color.opacity(0.12), lineWidth: 1)
                )
        )
    }
}
