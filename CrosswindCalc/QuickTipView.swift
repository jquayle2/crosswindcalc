import SwiftUI

struct QuickTipView: View {
    @Binding var isPresented: Bool
    let currentTab: Int
    
    @State private var animPhase: CGFloat = 0
    
    private var isKeypad: Bool { currentTab == 1 }
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.7)
                .ignoresSafeArea()
                .onTapGesture { isPresented = false }
            
            VStack(spacing: 20) {
                Text("SHORTCUTS")
                    .font(.system(size: 11, weight: .heavy, design: .monospaced))
                    .tracking(3)
                    .foregroundColor(Color(red: 0.94, green: 0.75, blue: 0.25))
                
                if isKeypad {
                    keypadDemo
                } else {
                    dialDemo
                }
                
                Divider()
                    .background(Color(white: 0.2))
                    .padding(.vertical, 4)
                
                flipRunwayTip
                
                Button(action: { isPresented = false }) {
                    Text("GOT IT")
                        .font(.system(size: 15, weight: .heavy, design: .monospaced))
                        .tracking(2)
                        .foregroundColor(.black)
                        .frame(maxWidth: .infinity)
                        .frame(height: 48)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color(red: 0.94, green: 0.75, blue: 0.25))
                        )
                }
                .padding(.top, 8)
            }
            .padding(24)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color(red: 0.06, green: 0.07, blue: 0.11))
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(Color(white: 0.15), lineWidth: 1)
                    )
            )
            .padding(.horizontal, 24)
        }
        .onAppear { startAnimation() }
    }
    
    private func startAnimation() {
        animPhase = 0
        withAnimation(.easeInOut(duration: 1.4).repeatForever(autoreverses: false)) {
            animPhase = 1
        }
    }
}

extension QuickTipView {
    
    private var keypadDemo: some View {
        VStack(spacing: 12) {
            Text("Swipe Two Digits")
                .font(.system(size: 18, weight: .heavy))
                .foregroundColor(.white)
            
            Text("Press a digit, drag to another, release.")
                .font(.system(size: 13))
                .foregroundColor(Color(white: 0.6))
                .multilineTextAlignment(.center)
            
            ZStack {
                VStack(spacing: 6) {
                    HStack(spacing: 6) {
                        miniKey("1", highlight: false)
                        miniKey("2", highlight: animPhase < 0.15 || animPhase > 0.85)
                        miniKey("3", highlight: false)
                    }
                    HStack(spacing: 6) {
                        miniKey("4", highlight: false)
                        miniKey("5", highlight: animPhase > 0.55 && animPhase < 0.85)
                        miniKey("6", highlight: false)
                    }
                }
                
                Circle()
                    .fill(Color(red: 0.94, green: 0.75, blue: 0.25).opacity(0.6))
                    .frame(width: 22, height: 22)
                    .overlay(
                        Circle().stroke(Color.white, lineWidth: 2)
                    )
                    .offset(
                        x: -38 + (76 * animPhase),
                        y: -19 + (38 * animPhase)
                    )
                    .opacity(animPhase < 0.95 ? 1 : 0)
            }
            .frame(width: 160, height: 110)
            .padding(8)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color(white: 0.04))
            )
        }
    }
    
    private func miniKey(_ digit: String, highlight: Bool) -> some View {
        Text(digit)
            .font(.system(size: 18, weight: .bold, design: .rounded))
            .foregroundColor(.white)
            .frame(width: 42, height: 42)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(highlight ? Color(red: 0.22, green: 0.74, blue: 0.97).opacity(0.4) : Color(white: 0.12))
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(highlight ? Color(red: 0.22, green: 0.74, blue: 0.97) : Color.clear, lineWidth: 2)
                    )
            )
    }
}

extension QuickTipView {
    
    private var dialDemo: some View {
        VStack(spacing: 12) {
            Text("Tap, Don't Spin")
                .font(.system(size: 18, weight: .heavy))
                .foregroundColor(.white)
            
            Text("Touch the dial directly on the value you want — then drag to fine-tune.")
                .font(.system(size: 13))
                .foregroundColor(Color(white: 0.6))
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
            
            ZStack {
                Circle()
                    .stroke(Color(white: 0.18), lineWidth: 4)
                    .frame(width: 100, height: 100)
                
                ForEach(0..<12) { i in
                    Rectangle()
                        .fill(Color(white: 0.3))
                        .frame(width: 2, height: 6)
                        .offset(y: -46)
                        .rotationEffect(.degrees(Double(i) * 30))
                }
                
                Circle()
                    .fill(Color(red: 0.94, green: 0.75, blue: 0.25))
                    .frame(width: 10, height: 10)
                    .offset(y: -46)
                    .rotationEffect(.degrees(animPhase < 0.5 ? 60 : 210))
                    .animation(.easeInOut(duration: 0.6), value: animPhase < 0.5)
                
                Circle()
                    .fill(Color(red: 0.94, green: 0.75, blue: 0.25).opacity(0.6))
                    .frame(width: 22, height: 22)
                    .overlay(Circle().stroke(Color.white, lineWidth: 2))
                    .offset(y: -46)
                    .rotationEffect(.degrees(animPhase < 0.5 ? 60 : 210))
                    .animation(.easeInOut(duration: 0.6), value: animPhase < 0.5)
                    .opacity(animPhase < 0.45 || animPhase > 0.55 ? 1 : 0.3)
            }
            .frame(width: 140, height: 130)
            .padding(8)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color(white: 0.04))
            )
        }
    }
    
    private var flipRunwayTip: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: "arrow.left.arrow.right")
                .font(.system(size: 22, weight: .semibold))
                .foregroundColor(Color(red: 0.94, green: 0.75, blue: 0.25))
                .frame(width: 30)
            
            VStack(alignment: .leading, spacing: 2) {
                Text("Flip Runway")
                    .font(.system(size: 15, weight: .bold))
                    .foregroundColor(.white)
                Text("Tap the runway number in the readout to switch to the opposite end.")
                    .font(.system(size: 12))
                    .foregroundColor(Color(white: 0.55))
                    .fixedSize(horizontal: false, vertical: true)
            }
            
            Spacer(minLength: 0)
        }
    }
}
