import SwiftUI

struct QuickTipView: View {
    @Binding var isPresented: Bool
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.6)
                .ignoresSafeArea()
                .onTapGesture { isPresented = false }
            
            VStack(spacing: 18) {
                Text("SHORTCUT")
                    .font(.system(size: 11, weight: .heavy, design: .monospaced))
                    .tracking(3)
                    .foregroundColor(Color(red: 0.94, green: 0.75, blue: 0.25))
                
                Image(systemName: "hand.draw.fill")
                    .font(.system(size: 56))
                    .foregroundColor(Color(red: 0.22, green: 0.74, blue: 0.97))
                
                Text("Swipe Two Digits")
                    .font(.system(size: 22, weight: .heavy))
                    .foregroundColor(.white)
                
                Text("On the keypad, press the first number, drag to the second, and release. Faster than two taps.")
                    .font(.system(size: 15, weight: .regular))
                    .foregroundColor(Color(white: 0.65))
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.horizontal, 8)
                
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
                .padding(.top, 4)
            }
            .padding(28)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color(red: 0.06, green: 0.07, blue: 0.11))
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(Color(white: 0.15), lineWidth: 1)
                    )
            )
            .padding(.horizontal, 32)
        }
    }
}
