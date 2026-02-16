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
    @State private var selectedTab = 0
    
    var body: some View {
        ZStack {
            Color(red: 0.04, green: 0.05, blue: 0.09)
                .ignoresSafeArea()
            
            TabView(selection: $selectedTab) {
                RotaryView()
                    .tag(0)
                
                KeypadView()
                    .tag(1)
            }
            .tabViewStyle(.page(indexDisplayMode: .always))
            .indexViewStyle(.page(backgroundDisplayMode: .always))
        }
    }
}
