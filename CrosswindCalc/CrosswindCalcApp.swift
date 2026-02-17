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
    private let pageCount = 3
    
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
                    } else {
                        FeedbackView(showOnboarding: $showOnboarding)
                            .transition(.opacity)
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .animation(.easeInOut(duration: 0.2), value: selectedTab)
                
                pageNavigationBar
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
    
    private var pageNavigationBar: some View {
        HStack {
            Button(action: {
                if selectedTab > 0 {
                    selectedTab -= 1
                }
            }) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(selectedTab > 0 ? .white : Color(white: 0.2))
                    .frame(width: 44, height: 44)
            }
            .disabled(selectedTab == 0)
            
            Spacer()
            
            HStack(spacing: 8) {
                ForEach(0..<pageCount, id: \.self) { index in
                    Circle()
                        .fill(index == selectedTab ? Color.white : Color(white: 0.3))
                        .frame(width: index == selectedTab ? 8 : 6,
                               height: index == selectedTab ? 8 : 6)
                        .onTapGesture { selectedTab = index }
                        .animation(.easeInOut(duration: 0.2), value: selectedTab)
                }
            }
            
            Spacer()
            
            Button(action: {
                if selectedTab < pageCount - 1 {
                    selectedTab += 1
                }
            }) {
                Image(systemName: "chevron.right")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(selectedTab < pageCount - 1 ? .white : Color(white: 0.2))
                    .frame(width: 44, height: 44)
            }
            .disabled(selectedTab >= pageCount - 1)
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 8)
        .background(Color(red: 0.04, green: 0.05, blue: 0.09))
    }
}
