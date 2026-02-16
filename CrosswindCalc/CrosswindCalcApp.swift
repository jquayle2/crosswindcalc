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
            
            TabView(selection: $selectedTab) {
                RotaryView()
                    .tag(0)
                
                KeypadView()
                    .tag(1)
                
                FeedbackView(showOnboarding: $showOnboarding)
                    .tag(2)
            }
            .tabViewStyle(.page(indexDisplayMode: .always))
            .indexViewStyle(.page(backgroundDisplayMode: .always))
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
}
