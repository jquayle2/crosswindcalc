import SwiftUI

struct ContentView: View {
    @State private var runway: Int = 18
    @State private var windDirection: Int = 210
    @State private var windSpeed: Int = 15
    @State private var gustSpeed: Int = 15
    @State private var selectedTab: Int = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            RotaryView(
                runway: $runway,
                windDirection: $windDirection,
                windSpeed: $windSpeed,
                gustSpeed: $gustSpeed
            )
            .tag(0)
            
            CrosswindView(
                runway: $runway,
                windDirection: $windDirection,
                windSpeed: $windSpeed,
                gustSpeed: $gustSpeed
            )
            .tag(1)
        }
        .tabViewStyle(.page(indexDisplayMode: .always))
        .indexViewStyle(.page(backgroundDisplayMode: .always))
        .background(Color(red: 0.04, green: 0.05, blue: 0.09))
        .ignoresSafeArea(edges: .bottom)
        .preferredColorScheme(.dark)
    }
}

@main
struct CrosswindCalcApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
