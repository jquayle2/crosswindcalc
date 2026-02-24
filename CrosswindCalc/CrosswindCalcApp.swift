import SwiftUI

@main
struct CrosswindCalcApp: App {
    var body: some Scene {
        WindowGroup {
            MainTabView()
                .preferredColorScheme(.dark)
        }
    }
}

struct MainTabView: View {
    @AppStorage("lastTab") private var selectedTab: Int = 0
    @AppStorage("hasSeenOnboarding") private var hasSeenOnboarding: Bool = false
    @State private var showOnboarding: Bool = false
    
    var body: some View {
        ZStack {
            Color(red: 0.04, green: 0.05, blue: 0.09)
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                ZStack {
                    if selectedTab == 0 {
                        RotaryView()
                            .transition(.opacity)
                    } else if selectedTab == 1 {
                        KeypadView()
                            .transition(.opacity)
                    } else if selectedTab == 2 {
                        VSpeedView()
                            .transition(.opacity)
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .animation(.easeInOut(duration: 0.2), value: selectedTab)
                
                tabBar
            }
        }
        .onAppear {
            if !hasSeenOnboarding {
                showOnboarding = true
            }
        }
        .fullScreenCover(isPresented: $showOnboarding) {
            OnboardingView(isPresented: $showOnboarding)
        }
    }
    
    private var tabBar: some View {
        HStack(spacing: 0) {
            tabButton(icon: "dial.medium.fill", label: "Dials", index: 0)
            tabButton(icon: "number.square.fill", label: "Keypad", index: 1)
            if FeatureFlags.showVSpeedPage {
                tabButton(icon: "gauge.with.needle.fill", label: "V-Speed", index: 2)
            }
        }
        .padding(.horizontal, 40)
        .padding(.vertical, 8)
        .background(Color(red: 0.04, green: 0.05, blue: 0.09))
    }
    
    private func tabButton(icon: String, label: String, index: Int) -> some View {
        let isSelected = selectedTab == index
        return Button(action: { selectedTab = index }) {
            VStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.system(size: 22, weight: .semibold))
                Text(label)
                    .font(.system(size: 11, weight: .semibold, design: .monospaced))
            }
            .foregroundColor(isSelected ? Color(red: 0.94, green: 0.75, blue: 0.25) : Color(white: 0.3))
            .frame(maxWidth: .infinity)
            .frame(height: 48)
        }
    }
}
