import SwiftUI

enum KeypadStep: Int, CaseIterable {
    case runway = 0
    case windDirection = 1
    case windSpeed = 2
    case gust = 3
    case result = 4
    
    var title: String {
        switch self {
        case .runway: return "RUNWAY"
        case .windDirection: return "WIND DIRECTION"
        case .windSpeed: return "WIND SPEED"
        case .gust: return "GUST SPEED"
        case .result: return "CROSSWIND"
        }
    }
    
    var subtitle: String {
        switch self {
        case .runway: return "Enter runway heading (01–36)"
        case .windDirection: return "Enter first two digits (01–36)"
        case .windSpeed: return "Enter wind speed in knots"
        case .gust: return "Enter gust speed or skip"
        case .result: return ""
        }
    }
    
    var maxDigits: Int {
        switch self {
        case .runway: return 2
        case .windDirection: return 2
        case .windSpeed: return 2
        case .gust: return 2
        case .result: return 0
        }
    }
    
    var color: Color {
        switch self {
        case .runway: return Color(red: 0.94, green: 0.75, blue: 0.25)
        case .windDirection: return Color(red: 0.22, green: 0.74, blue: 0.97)
        case .windSpeed: return Color(red: 0.22, green: 0.74, blue: 0.97)
        case .gust: return Color(red: 1.0, green: 0.58, blue: 0.0)
        case .result: return .green
        }
    }
    
    var suffix: String {
        switch self {
        case .runway: return ""
        case .windDirection: return "°"
        case .windSpeed: return " kt"
        case .gust: return " kt"
        case .result: return ""
        }
    }
}

struct KeypadView: View {
    @State private var currentStep: KeypadStep = .runway
    @State private var inputBuffer: String = ""
    @State private var runwayValue: Int = 0
    @State private var windDirValue: Int = 0
    @State private var windSpdValue: Int = 0
    @State private var gustValue: Int? = nil
    @State private var errorMessage: String? = nil
    @State private var shakeOffset: CGFloat = 0
    
    private var crosswind: Int {
        let angle = Double(windDirValue - runwayValue * 10) * .pi / 180
        return abs(Int(round(Double(windSpdValue) * sin(angle))))
    }
    
    private var gustCrosswind: Int? {
        guard let gust = gustValue, gust > windSpdValue else { return nil }
        let angle = Double(windDirValue - runwayValue * 10) * .pi / 180
        return abs(Int(round(Double(gust) * sin(angle))))
    }
    
    private var headwind: Int {
        let angle = Double(windDirValue - runwayValue * 10) * .pi / 180
        return Int(round(Double(windSpdValue) * cos(angle)))
    }
    
    private var side: String {
        let diff = ((windDirValue - runwayValue * 10) % 360 + 360) % 360
        if diff > 0 && diff < 180 { return "L" }
        if diff > 180 { return "R" }
        return ""
    }
    
    private var severityColor: Color {
        let xw = gustCrosswind ?? crosswind
        if xw >= 20 { return .red }
        if xw >= 15 { return .orange }
        return .green
    }
    
    var body: some View {
        VStack(spacing: 0) {
            if currentStep == .result {
                resultView
            } else {
                inputView
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(red: 0.04, green: 0.05, blue: 0.09))
    }
    
    private var inputView: some View {
        VStack(spacing: 0) {
            Spacer().frame(height: 24)
            
            progressDots
                .padding(.bottom, 20)
            
            Text(currentStep.title)
                .font(.system(size: 28, weight: .heavy, design: .monospaced))
                .tracking(4)
                .foregroundColor(currentStep.color)
            
            Text(currentStep.subtitle)
                .font(.system(size: 17, weight: .medium))
                .foregroundColor(Color(white: 0.4))
                .padding(.top, 6)
            
            Spacer().frame(height: 24)
            
            displayField
                .offset(x: shakeOffset)
                .padding(.horizontal, 40)
            
            if let error = errorMessage {
                Text(error)
                    .font(.system(size: 13, weight: .semibold, design: .monospaced))
                    .foregroundColor(.red)
                    .padding(.top, 8)
                    .transition(.opacity)
            }
            
            Spacer().frame(height: 24)
            
            summaryBar
                .padding(.horizontal, 24)
                .padding(.bottom, 12)
            
            keypadGrid
                .padding(.horizontal, 24)
                .padding(.bottom, 16)
        }
        .animation(.easeInOut(duration: 0.15), value: currentStep)
        .animation(.easeInOut(duration: 0.15), value: errorMessage)
        .animation(.easeInOut(duration: 0.12), value: inputBuffer)
    }
    
    private var progressDots: some View {
        HStack(spacing: 8) {
            ForEach(0..<4) { index in
                Circle()
                    .fill(index < currentStep.rawValue ? Color.white :
                          index == currentStep.rawValue ? currentStep.color :
                          Color(white: 0.2))
                    .frame(width: index == currentStep.rawValue ? 10 : 8,
                           height: index == currentStep.rawValue ? 10 : 8)
                    .animation(.easeInOut(duration: 0.2), value: currentStep)
            }
        }
    }
    
    private var displayField: some View {
        HStack(spacing: 0) {
            let maxD = currentStep.maxDigits
            let chars = Array(inputBuffer)
            
            ForEach(0..<maxD, id: \.self) { i in
                ZStack {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color(white: 0.08))
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(
                                    i == chars.count ? currentStep.color.opacity(0.8) :
                                    i < chars.count ? currentStep.color.opacity(0.3) :
                                    Color(white: 0.15),
                                    lineWidth: i == chars.count ? 2 : 1
                                )
                        )
                    
                    if i < chars.count {
                        Text(String(chars[i]))
                            .font(.system(size: 48, weight: .heavy, design: .rounded))
                            .foregroundColor(.white)
                    } else if i == chars.count {
                        Rectangle()
                            .fill(currentStep.color)
                            .frame(width: 2, height: 36)
                            .opacity(cursorOpacity)
                    }
                }
                .frame(height: 80)
                
                if i < maxD - 1 {
                    Spacer().frame(width: 10)
                }
            }
            
            if currentStep == .windDirection {
                ZStack {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color(white: 0.06))
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color(white: 0.1), lineWidth: 1)
                        )
                    Text("0")
                        .font(.system(size: 48, weight: .heavy, design: .rounded))
                        .foregroundColor(Color(white: 0.25))
                }
                .frame(height: 80)
                .padding(.leading, 4)
                
                Text("°")
                    .font(.system(size: 28, weight: .bold, design: .monospaced))
                    .foregroundColor(currentStep.color.opacity(0.5))
                    .padding(.leading, 4)
            } else if !currentStep.suffix.isEmpty {
                Text(currentStep.suffix)
                    .font(.system(size: 28, weight: .bold, design: .monospaced))
                    .foregroundColor(currentStep.color.opacity(0.5))
                    .padding(.leading, 8)
            }
        }
    }
    
    @State private var cursorVisible = true
    
    private var cursorOpacity: Double {
        cursorVisible ? 1.0 : 0.0
    }
    
    private var summaryBar: some View {
        HStack(spacing: 12) {
            if runwayValue > 0 {
                summaryChip(label: "RWY", value: String(format: "%02d", runwayValue),
                           color: KeypadStep.runway.color)
            }
            if windDirValue > 0 {
                summaryChip(label: "WIND", value: String(format: "%03d°", windDirValue),
                           color: KeypadStep.windDirection.color)
            }
            if currentStep.rawValue > 2 {
                summaryChip(label: "SPD", value: "\(windSpdValue)kt",
                           color: KeypadStep.windSpeed.color)
            }
            Spacer()
        }
    }
    
    private func summaryChip(label: String, value: String, color: Color) -> some View {
        HStack(spacing: 4) {
            Text(label)
                .font(.system(size: 10, weight: .bold, design: .monospaced))
                .foregroundColor(color.opacity(0.6))
            Text(value)
                .font(.system(size: 13, weight: .heavy, design: .monospaced))
                .foregroundColor(color)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(
            RoundedRectangle(cornerRadius: 6)
                .fill(color.opacity(0.1))
        )
    }
    
    private var keypadGrid: some View {
        let buttons: [[KeypadButton]] = [
            [.digit("1"), .digit("2")],
            [.digit("3"), .digit("4")],
            [.digit("5"), .digit("6")],
            [.digit("7"), .digit("8")],
            [.digit("9"), .digit("0")],
            [bottomLeft, .backspace]
        ]
        
        return VStack(spacing: 8) {
            ForEach(0..<buttons.count, id: \.self) { row in
                HStack(spacing: 10) {
                    ForEach(0..<buttons[row].count, id: \.self) { col in
                        keypadButtonView(buttons[row][col])
                    }
                }
            }
        }
        .frame(maxHeight: .infinity)
    }
    
    private var bottomLeft: KeypadButton {
        if currentStep == .gust {
            return .skip
        }
        return .empty
    }
    
    private func keypadButtonView(_ button: KeypadButton) -> some View {
        Group {
            switch button {
            case .digit(let d):
                let enabled = isDigitEnabled(d)
                Button(action: { digitPressed(d) }) {
                    Text(d)
                        .font(.system(size: 40, weight: .bold, design: .rounded))
                        .foregroundColor(enabled ? .white : Color(white: 0.2))
                        .frame(maxWidth: .infinity)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(enabled ? Color(white: 0.12) : Color(white: 0.06))
                        )
                }
                .disabled(!enabled)
                
            case .backspace:
                Button(action: { backspacePressed() }) {
                    Image(systemName: "delete.left.fill")
                        .font(.system(size: 30, weight: .semibold))
                        .foregroundColor(inputBuffer.isEmpty ? Color(white: 0.25) : .white)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color(white: 0.08))
                        )
                }
                .disabled(inputBuffer.isEmpty)
                
            case .skip:
                Button(action: { skipPressed() }) {
                    Text("NONE")
                        .font(.system(size: 20, weight: .heavy, design: .monospaced))
                        .tracking(2)
                        .foregroundColor(Color(white: 0.5))
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color(white: 0.08))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(Color(white: 0.15), lineWidth: 1)
                                )
                        )
                }
                
            case .empty:
                Color.clear
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
    }
    
    private func isDigitEnabled(_ digit: String) -> Bool {
        guard let d = Int(digit) else { return false }
        
        switch currentStep {
        case .runway, .windDirection:
            if inputBuffer.isEmpty {
                if d == 0 { return false }
                return true
            }
            if inputBuffer.count == 1 {
                guard let first = Int(inputBuffer) else { return true }
                if first == 0 {
                    return d >= 1 && d <= 9
                }
                if first == 1 || first == 2 {
                    return d >= 0 && d <= 9
                }
                if first == 3 {
                    return d >= 0 && d <= 6
                }
                return true
            }
            return true
            
        case .windSpeed, .gust:
            return true
            
        case .result:
            return false
        }
    }
    
    private func digitPressed(_ digit: String) {
        errorMessage = nil
        
        guard inputBuffer.count < currentStep.maxDigits else { return }
        guard isDigitEnabled(digit) else { return }
        
        guard let d = Int(digit) else { return }
        
        if (currentStep == .runway || currentStep == .windDirection) && inputBuffer.isEmpty && d >= 4 && d <= 9 {
            inputBuffer = "0" + digit
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                validateAndAdvance()
            }
            return
        }
        
        inputBuffer += digit
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        
        if inputBuffer.count == currentStep.maxDigits {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                validateAndAdvance()
            }
        }
    }
    
    private func backspacePressed() {
        guard !inputBuffer.isEmpty else { return }
        inputBuffer.removeLast()
        errorMessage = nil
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
    }
    
    private func skipPressed() {
        gustValue = nil
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        withAnimation { currentStep = .result }
    }
    
    private func validateAndAdvance() {
        guard let val = Int(inputBuffer) else {
            showError("Invalid entry")
            return
        }
        
        switch currentStep {
        case .runway:
            if val < 1 || val > 36 {
                showError("Enter 01–36")
                return
            }
            runwayValue = val
            inputBuffer = ""
            withAnimation { currentStep = .windDirection }
            
        case .windDirection:
            if val < 1 || val > 36 {
                showError("Enter 01–36")
                return
            }
            windDirValue = val * 10
            inputBuffer = ""
            withAnimation { currentStep = .windSpeed }
            
        case .windSpeed:
            if val < 0 || val > 99 {
                showError("Enter 0–99")
                return
            }
            windSpdValue = val
            inputBuffer = ""
            withAnimation { currentStep = .gust }
            
        case .gust:
            if val < windSpdValue {
                showError("Must be ≥ \(windSpdValue) kt")
                return
            }
            gustValue = val > windSpdValue ? val : nil
            inputBuffer = ""
            withAnimation { currentStep = .result }
            
        case .result:
            break
        }
    }
    
    private func showError(_ message: String) {
        errorMessage = message
        inputBuffer = ""
        withAnimation(.default) {
            shakeOffset = 12
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.08) {
            withAnimation(.default) { shakeOffset = -10 }
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.16) {
            withAnimation(.default) { shakeOffset = 6 }
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.24) {
            withAnimation(.default) { shakeOffset = 0 }
        }
        UINotificationFeedbackGenerator().notificationOccurred(.error)
    }
    
    private var resultView: some View {
        VStack(spacing: 16) {
            Spacer().frame(height: 20)
            
            CrosswindReadout(
                crosswind: crosswind,
                gustCrosswind: gustCrosswind,
                headwind: headwind,
                side: side,
                color: severityColor,
                runway: runwayValue,
                windDirection: windDirValue,
                windSpeed: windSpdValue,
                gustSpeed: gustValue
            )
            .padding(.horizontal, 16)
            
            Spacer()
            
            Button(action: { resetAll() }) {
                HStack(spacing: 8) {
                    Image(systemName: "arrow.counterclockwise")
                        .font(.system(size: 18, weight: .bold))
                    Text("NEW CALCULATION")
                        .font(.system(size: 15, weight: .heavy, design: .monospaced))
                        .tracking(2)
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 56)
                .background(
                    RoundedRectangle(cornerRadius: 14)
                        .fill(Color(white: 0.12))
                        .overlay(
                            RoundedRectangle(cornerRadius: 14)
                                .stroke(Color(white: 0.2), lineWidth: 1)
                        )
                )
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 40)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private func resetAll() {
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        withAnimation {
            currentStep = .runway
            inputBuffer = ""
            runwayValue = 0
            windDirValue = 0
            windSpdValue = 0
            gustValue = nil
            errorMessage = nil
        }
    }
}

enum KeypadButton {
    case digit(String)
    case backspace
    case skip
    case empty
}
