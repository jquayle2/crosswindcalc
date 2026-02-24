import SwiftUI

struct AppTheme {
    let colorScheme: ColorScheme
    
    // MARK: - Backgrounds
    var mainBackground: Color {
        colorScheme == .dark
            ? Color(red: 0.04, green: 0.05, blue: 0.09)
            : Color(red: 0.92, green: 0.93, blue: 0.95)
    }
    
    var panelBackground: Color {
        colorScheme == .dark
            ? Color(white: 0.04)
            : Color.white
    }
    
    var keypadBackground: Color {
        colorScheme == .dark
            ? Color(red: 0.06, green: 0.07, blue: 0.11)
            : Color(red: 0.88, green: 0.89, blue: 0.91)
    }
    
    var cardBackground: Color {
        colorScheme == .dark
            ? Color(white: 0.06)
            : Color(white: 0.95)
    }
    
    var inputBackground: Color {
        colorScheme == .dark
            ? Color(white: 0.08)
            : Color(white: 0.92)
    }
    
    var activeBoxBackground: Color {
        colorScheme == .dark
            ? Color(white: 0.1)
            : Color(white: 0.88)
    }
    
    var boxBackground: Color {
        colorScheme == .dark
            ? Color(white: 0.06)
            : Color(white: 0.94)
    }
    
    // MARK: - Text
    var primaryText: Color {
        colorScheme == .dark ? .white : .black
    }
    
    var secondaryText: Color {
        colorScheme == .dark
            ? Color(white: 0.45)
            : Color(white: 0.4)
    }
    
    var tertiaryText: Color {
        colorScheme == .dark
            ? Color(white: 0.35)
            : Color(white: 0.5)
    }
    
    var dimText: Color {
        colorScheme == .dark
            ? Color(white: 0.4)
            : Color(white: 0.45)
    }
    
    var disabledText: Color {
        colorScheme == .dark
            ? Color(white: 0.2)
            : Color(white: 0.65)
    }
    
    // MARK: - Borders & Separators
    var border: Color {
        colorScheme == .dark
            ? Color(white: 0.12)
            : Color(white: 0.78)
    }
    
    var subtleBorder: Color {
        colorScheme == .dark
            ? Color(white: 0.15)
            : Color(white: 0.75)
    }
    
    var inactiveDot: Color {
        colorScheme == .dark
            ? Color(white: 0.3)
            : Color(white: 0.6)
    }
    
    var navArrowDisabled: Color {
        colorScheme == .dark
            ? Color(white: 0.2)
            : Color(white: 0.7)
    }
    
    // MARK: - Buttons
    var digitButtonBackground: Color {
        colorScheme == .dark
            ? Color(white: 0.12)
            : Color(white: 0.98)
    }
    
    var digitDisabledBackground: Color {
        colorScheme == .dark
            ? Color(white: 0.06)
            : Color(white: 0.88)
    }
    
    var actionButtonBackground: Color {
        colorScheme == .dark
            ? Color(white: 0.08)
            : Color(white: 0.9)
    }
    
    // MARK: - Knob (Rotary)
    var knobFaceBackground: Color {
        colorScheme == .dark ? .black : Color(white: 0.15)
    }
    
    var knobShadow: Color {
        colorScheme == .dark
            ? Color.black.opacity(0.4)
            : Color.black.opacity(0.15)
    }
    
    var knobGradientColors: [Color] {
        colorScheme == .dark
            ? [Color(white: 0.22), Color(white: 0.15), Color(white: 0.10), Color(white: 0.13)]
            : [Color(white: 0.78), Color(white: 0.70), Color(white: 0.64), Color(white: 0.68)]
    }
    
    var knobStrokeTop: Color {
        colorScheme == .dark ? Color(white: 0.32) : Color(white: 0.88)
    }
    
    var knobStrokeBottom: Color {
        colorScheme == .dark ? Color(white: 0.06) : Color(white: 0.50)
    }
    
    var knobFaceSheen: Color {
        colorScheme == .dark
            ? Color.white.opacity(0.04)
            : Color.white.opacity(0.15)
    }
    
    var tickOpacity: Double {
        colorScheme == .dark ? 0.18 : 0.35
    }
    
    var minorTickOpacity: Double {
        colorScheme == .dark ? 0.1 : 0.2
    }
    
    var knobCenterValueColor: Color {
        colorScheme == .dark ? .white : .white
    }
    
    // MARK: - Readout
    var panelStrokeOpacity: Double {
        colorScheme == .dark ? 0.15 : 0.25
    }
    
    var tailwindBackgroundOpacity: Double {
        colorScheme == .dark ? 0.12 : 0.08
    }
    
    var tailwindStrokeOpacity: Double {
        colorScheme == .dark ? 0.4 : 0.3
    }
    
    // MARK: - Survey / Feedback
    var surveyOptionUnselected: Color {
        colorScheme == .dark
            ? Color(white: 0.25)
            : Color(white: 0.65)
    }
    
    var surveyOptionText: Color {
        colorScheme == .dark
            ? Color(white: 0.5)
            : Color(white: 0.4)
    }
    
    var textEditorBorder: Color {
        colorScheme == .dark
            ? Color(white: 0.2)
            : Color(white: 0.75)
    }
    
    var disabledButtonFill: Color {
        colorScheme == .dark
            ? Color(white: 0.2)
            : Color(white: 0.7)
    }
    
    // MARK: - OK button text (for active state)
    var okButtonText: Color {
        .black
    }
    
    var enterInactiveText: Color {
        colorScheme == .dark
            ? Color(white: 0.5)
            : Color(white: 0.4)
    }
}

// MARK: - Environment Key
private struct AppThemeKey: EnvironmentKey {
    static let defaultValue = AppTheme(colorScheme: .dark)
}

extension EnvironmentValues {
    var appTheme: AppTheme {
        get { self[AppThemeKey.self] }
        set { self[AppThemeKey.self] = newValue }
    }
}

// MARK: - View modifier to inject theme
struct ThemeModifier: ViewModifier {
    @Environment(\.colorScheme) private var colorScheme
    
    func body(content: Content) -> some View {
        content
            .environment(\.appTheme, AppTheme(colorScheme: colorScheme))
    }
}

extension View {
    func withAppTheme() -> some View {
        modifier(ThemeModifier())
    }
}
