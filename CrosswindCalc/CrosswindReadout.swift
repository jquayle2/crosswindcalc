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
        VStack(spacing: 8) {
            Text("CROSSWIND COMPONENT")
                .font(.system(size: 10, weight: .medium, design: .monospaced))
                .tracking(3)
                .foregroundColor(Color(white: 0.4))
            
            HStack(spacing: 8) {
                if side == "L" {
                    windArrow(pointingRight: true)
                }
                
                HStack(alignment: .firstTextBaseline, spacing: 2) {
                    Text("\(crosswind)")
                        .font(.system(size: 80, weight: .bold, design: .rounded))
                        .foregroundColor(color)
                    
                    if let gust = gustCrosswind, gust > crosswind {
                        Text("G\(gust)")
                            .font(.system(size: 38, weight: .bold, design: .rounded))
                            .foregroundColor(color.opacity(0.5))
                    }
                    
                    Text("kt")
                        .font(.system(size: 18, weight: .regular, design: .monospaced))
                        .foregroundColor(Color(white: 0.35))
                }
                
                if side == "R" {
                    windArrow(pointingRight: false)
                }
                
                if side.isEmpty {
                    Color.clear.frame(width: 40)
                }
            }
            
            HStack(spacing: 12) {
                Text("\(headwind >= 0 ? "HEAD" : "TAIL") ")
                    .foregroundColor(Color(white: 0.35))
                +
                Text("\(abs(headwind))kt")
                    .foregroundColor(headwind >= 0 ? .green : .red)
                
                Text("|").foregroundColor(Color(white: 0.15))
                
                Text("RWY \(String(format: "%02d", runway))")
                    .foregroundColor(Color(white: 0.35))
                
                Text("|").foregroundColor(Color(white: 0.15))
                
                let gustText = gustSpeed.map { "G\($0)" } ?? ""
                Text("\(String(format: "%03d", windDirection))@\(windSpeed)\(gustText)")
                    .foregroundColor(Color(white: 0.35))
            }
            .font(.system(size: 13, weight: .medium, design: .monospaced))
        }
        .padding(.vertical, 20)
        .padding(.horizontal, 16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(white: 0.06))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(color.opacity(0.15), lineWidth: 1)
                )
        )
    }
    
    @ViewBuilder
    private func windArrow(pointingRight: Bool) -> some View {
        Image(systemName: pointingRight ? "arrow.right" : "arrow.left")
            .font(.system(size: 36, weight: .bold))
            .foregroundColor(color.opacity(0.85))
            .shadow(color: color.opacity(0.3), radius: 8)
    }
}
