import SwiftUI

@main
struct CrosswindCalcApp: App {
    var body: some Scene {
        WindowGroup {
            RotaryView()
                .preferredColorScheme(.dark)
        }
    }
}
