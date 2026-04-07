import SwiftUI

struct OnboardingView: View {
    @Binding var isPresented: Bool
    @AppStorage("hasSeenOnboarding_v2") private var hasSeenOnboarding: Bool = false
    @State private var currentPage = 0
    @State private var animPhase: CGFloat = 0
    
    var body: some View {
        ZStack {
            Color(red: 0.04, green: 0.05, blue: 0.09)
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                TabView(selection: $currentPage) {
                    dialPage.tag(0)
                    keypadPage.tag(1)
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                
                pageDots
                    .padding(.bottom, 12)
                
                Button(action: {
                    if currentPage == 0 {
                        withAnimation { currentPage = 1 }
                    } else {
                        hasSeenOnboarding = true
                        isPresented = false
                    }
                }) {
                    Text(currentPage == 0 ? "NEXT" : "GET STARTED")
                        .font(.system(size: 17, weight: .heavy, design: .monospaced))
                        .tracking(2)
                        .foregroundColor(.black)
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .background(
                            RoundedRectangle(cornerRadius: 14)
                                .fill(Color(red: 0.94, green: 0.75, blue: 0.25))
                        )
                }
                .padding(.horizontal, 32)
                
                if currentPage == 0 {
                    Button(action: {
                        hasSeenOnboarding = true
                        isPresented = false
                    }) {
                        Text("Skip")
                            .font(.system(size: 15, weight: .medium))
                            .foregroundColor(Color(white: 0.4))
                    }
                    .padding(.top, 12)
                } else {
                    Spacer().frame(height: 32)
                }
                
                Spacer().frame(height: 20)
            }
        }
        .onAppear {
            animPhase = 0
            withAnimation(.easeInOut(duration: 1.4).repeatForever(autoreverses: false)) {
                animPhase = 1
            }
        }
    }
    
    private var pageDots: some View {
        HStack(spacing: 8) {
            ForEach(0..<2) { i in
                Circle()
                    .fill(i == currentPage ? Color(red: 0.94, green: 0.75, blue: 0.25) : Color(white: 0.25))
                    .frame(width: i == currentPage ? 10 : 8, height: i == currentPage ? 10 : 8)
            }
        }
    }
    
    private var dialPage: some View {
        VStack(spacing: 20) {
            Spacer()
            
            Image(systemName: "dial.medium.fill")
                .font(.system(size: 72))
                .foregroundColor(Color(red: 0.94, green: 0.75, blue: 0.25))
                .padding(.bottom, 8)
            
            Text("ROTARY DIALS")
                .font(.system(size: 28, weight: .heavy, design: .monospaced))
                .tracking(3)
                .foregroundColor(.white)
            
            VStack(alignment: .leading, spacing: 16) {
                featureRow(
                    icon: "hand.tap.fill",
                    color: Color(red: 0.94, green: 0.75, blue: 0.25),
                    title: "Tap to Select",
                    detail: "Touch any dial directly on the number you want"
                )
                
                featureRow(
                    icon: "hand.draw.fill",
                    color: Color(red: 0.22, green: 0.74, blue: 0.97),
                    title: "Drag to Adjust",
                    detail: "Drag your finger around the dial to fine-tune"
                )
                
                featureRow(
                    icon: "bolt.fill",
                    color: .green,
                    title: "Just 3–4 Touches",
                    detail: "Set runway, wind, and speed — instant crosswind"
                )
            }
            .padding(.horizontal, 32)
            .padding(.top, 8)
            
            Spacer()
            Spacer()
        }
    }
    
    private var keypadPage: some View {
        VStack(spacing: 20) {
            Spacer()
            
            animatedKeypadDemo
                .padding(.bottom, 8)
            
            Text("KEYPAD ENTRY")
                .font(.system(size: 28, weight: .heavy, design: .monospaced))
                .tracking(3)
                .foregroundColor(.white)
            
            VStack(alignment: .leading, spacing: 16) {
                featureRow(
                    icon: "keyboard",
                    color: Color(red: 0.22, green: 0.74, blue: 0.97),
                    title: "Tap Any Value",
                    detail: "Tap a box to edit, tap another to change it"
                )
                
                featureRow(
                    icon: "hand.draw.fill",
                    color: Color(red: 1.0, green: 0.58, blue: 0.0),
                    title: "Swipe Two Digits",
                    detail: "Press the first number, drag to the second, and release"
                )
                
                featureRow(
                    icon: "arrow.right.circle.fill",
                    color: .green,
                    title: "Auto-Advance",
                    detail: "Jumps to the next field after each entry"
                )
            }
            .padding(.horizontal, 32)
            .padding(.top, 8)
            
            Text("Swipe to page 2 anytime to use keypad entry")
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(Color(white: 0.35))
                .multilineTextAlignment(.center)
                .padding(.top, 8)
            
            Spacer()
            Spacer()
        }
    }
    
    private var animatedKeypadDemo: some View {
        ZStack {
            VStack(spacing: 8) {
                HStack(spacing: 8) {
                    bigKey("1", highlight: false)
                    bigKey("2", highlight: animPhase < 0.15 || animPhase > 0.85)
                    bigKey("3", highlight: false)
                }
                HStack(spacing: 8) {
                    bigKey("4", highlight: false)
                    bigKey("5", highlight: animPhase > 0.55 && animPhase < 0.85)
                    bigKey("6", highlight: false)
                }
            }
            
            Circle()
                .fill(Color(red: 0.94, green: 0.75, blue: 0.25).opacity(0.6))
                .frame(width: 32, height: 32)
                .overlay(Circle().stroke(Color.white, lineWidth: 2.5))
                .offset(
                    x: -56 + (112 * animPhase),
                    y: -28 + (56 * animPhase)
                )
                .opacity(animPhase < 0.95 ? 1 : 0)
        }
        .frame(width: 220, height: 150)
    }
    
    private func bigKey(_ digit: String, highlight: Bool) -> some View {
        Text(digit)
            .font(.system(size: 26, weight: .bold, design: .rounded))
            .foregroundColor(.white)
            .frame(width: 60, height: 60)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(highlight ? Color(red: 0.22, green: 0.74, blue: 0.97).opacity(0.4) : Color(white: 0.12))
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(highlight ? Color(red: 0.22, green: 0.74, blue: 0.97) : Color.clear, lineWidth: 2)
                    )
            )
    }
    
    private func featureRow(icon: String, color: Color, title: String, detail: String) -> some View {        HStack(alignment: .top, spacing: 14) {
            Image(systemName: icon)
                .font(.system(size: 24, weight: .semibold))
                .foregroundColor(color)
                .frame(width: 36)
            
            VStack(alignment: .leading, spacing: 3) {
                Text(title)
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.white)
                Text(detail)
                    .font(.system(size: 15, weight: .regular))
                    .foregroundColor(Color(white: 0.5))
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }
}
