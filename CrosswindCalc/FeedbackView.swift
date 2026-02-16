import SwiftUI

struct PracticeMETAR: Identifiable {
    let id: Int
    let runway: Int
    let windDir: Int
    let windSpd: Int
    let gust: Int?
    
    var metarString: String {
        let rwy = String(format: "%02d", runway)
        let dir = String(format: "%03d", windDir)
        if let g = gust {
            return "RWY \(rwy)  \(dir)/\(windSpd)G\(g)"
        }
        return "RWY \(rwy)  \(dir)/\(windSpd)"
    }
    
    var expectedCrosswind: Int {
        let angle = Double(windDir - runway * 10) * .pi / 180
        return abs(Int(round(Double(windSpd) * sin(angle))))
    }
}

enum FeedbackPhase {
    case practice
    case survey
    case submitted
}

struct FeedbackView: View {
    @Binding var showOnboarding: Bool
    @AppStorage("feedbackPhase") private var phaseRaw: String = "practice"
    @AppStorage("dialCompleted") private var dialCompleted: Int = 0
    @AppStorage("keypadCompleted") private var keypadCompleted: Int = 0
    @AppStorage("practiceIndex") private var practiceIndex: Int = 0
    @AppStorage("currentInputMethod") private var currentInputMethod: String = "dial"
    
    @AppStorage("surveyFavorite") private var surveyFavorite: String = ""
    @AppStorage("surveyKeepBoth") private var surveyKeepBoth: String = ""
    @AppStorage("surveyFaster") private var surveyFaster: String = ""
    @AppStorage("surveyTurbulence") private var surveyTurbulence: String = ""
    @AppStorage("surveyEasierRead") private var surveyEasierRead: String = ""
    @AppStorage("surveyChanges") private var surveyChanges: String = ""
    
    @State private var practiceAnswer: String = ""
    @State private var showResult: Bool = false
    @State private var isSubmitting: Bool = false
    @State private var submitError: String? = nil
    @FocusState private var textFieldFocused: Bool
    
    private let practiceItems: [PracticeMETAR] = [
        PracticeMETAR(id: 0, runway: 12, windDir: 170, windSpd: 9, gust: nil),
        PracticeMETAR(id: 1, runway: 24, windDir: 300, windSpd: 12, gust: 15),
        PracticeMETAR(id: 2, runway: 7, windDir: 270, windSpd: 3, gust: 5),
    ]
    
    private var phase: FeedbackPhase {
        get { FeedbackPhase(rawValue: phaseRaw) }
        set { phaseRaw = newValue.rawString }
    }
    
    private var currentPractice: PracticeMETAR? {
        guard practiceIndex < practiceItems.count else { return nil }
        return practiceItems[practiceIndex]
    }
    
    private var allPracticeComplete: Bool {
        dialCompleted >= 3 && keypadCompleted >= 3
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                switch phase {
                case .practice:
                    practiceView
                case .survey:
                    surveyView
                case .submitted:
                    submittedView
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 20)
            .padding(.bottom, 40)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(red: 0.04, green: 0.05, blue: 0.09))
        .onTapGesture { textFieldFocused = false }
    }
    
    private var practiceView: some View {
        VStack(spacing: 20) {
            Text("PRACTICE")
                .font(.system(size: 28, weight: .heavy, design: .monospaced))
                .tracking(4)
                .foregroundColor(Color(red: 0.94, green: 0.75, blue: 0.25))
            
            Text("Try each METAR on both input methods")
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(Color(white: 0.45))
                .multilineTextAlignment(.center)
            
            inputMethodToggle
                .padding(.top, 4)
            
            if let metar = currentPractice {
                metarCard(metar)
                    .padding(.top, 8)
                
                Text("Use the \(currentInputMethod == "dial" ? "rotary dials" : "keypad") on page \(currentInputMethod == "dial" ? "1" : "2") to calculate this crosswind, then enter your answer below.")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(Color(white: 0.4))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 8)
                
                answerField(expected: metar.expectedCrosswind)
            }
            
            Spacer().frame(height: 12)
            
            progressGrid
            
            if allPracticeComplete {
                Button(action: {
                    withAnimation { phaseRaw = "survey" }
                }) {
                    Text("CONTINUE TO SURVEY")
                        .font(.system(size: 16, weight: .heavy, design: .monospaced))
                        .tracking(2)
                        .foregroundColor(.black)
                        .frame(maxWidth: .infinity)
                        .frame(height: 52)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color(red: 0.94, green: 0.75, blue: 0.25))
                        )
                }
                .padding(.top, 8)
            }
        }
    }
    
    private var inputMethodToggle: some View {
        HStack(spacing: 0) {
            Button(action: { currentInputMethod = "dial" }) {
                HStack(spacing: 6) {
                    Image(systemName: "dial.medium.fill")
                        .font(.system(size: 14))
                    Text("DIAL")
                        .font(.system(size: 13, weight: .heavy, design: .monospaced))
                }
                .foregroundColor(currentInputMethod == "dial" ? .black : Color(white: 0.5))
                .frame(maxWidth: .infinity)
                .frame(height: 40)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(currentInputMethod == "dial" ?
                              Color(red: 0.94, green: 0.75, blue: 0.25) :
                              Color(white: 0.1))
                )
            }
            
            Spacer().frame(width: 8)
            
            Button(action: { currentInputMethod = "keypad" }) {
                HStack(spacing: 6) {
                    Image(systemName: "number.square.fill")
                        .font(.system(size: 14))
                    Text("KEYPAD")
                        .font(.system(size: 13, weight: .heavy, design: .monospaced))
                }
                .foregroundColor(currentInputMethod == "keypad" ? .black : Color(white: 0.5))
                .frame(maxWidth: .infinity)
                .frame(height: 40)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(currentInputMethod == "keypad" ?
                              Color(red: 0.22, green: 0.74, blue: 0.97) :
                              Color(white: 0.1))
                )
            }
        }
    }
    
    private func metarCard(_ metar: PracticeMETAR) -> some View {
        VStack(spacing: 8) {
            Text("METAR \(metar.id + 1) of 3")
                .font(.system(size: 12, weight: .bold, design: .monospaced))
                .foregroundColor(Color(white: 0.4))
            
            Text(metar.metarString)
                .font(.system(size: 28, weight: .heavy, design: .monospaced))
                .foregroundColor(.white)
                .minimumScaleFactor(0.7)
                .lineLimit(1)
        }
        .padding(.vertical, 20)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(Color(white: 0.07))
                .overlay(
                    RoundedRectangle(cornerRadius: 14)
                        .stroke(Color(white: 0.15), lineWidth: 1)
                )
        )
    }
    
    private func answerField(expected: Int) -> some View {
        VStack(spacing: 10) {
            HStack(spacing: 12) {
                TextField("Crosswind?", text: $practiceAnswer)
                    .font(.system(size: 24, weight: .bold, design: .monospaced))
                    .foregroundColor(.white)
                    .keyboardType(.numberPad)
                    .multilineTextAlignment(.center)
                    .focused($textFieldFocused)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color(white: 0.08))
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(Color(white: 0.2), lineWidth: 1)
                            )
                    )
                
                Button(action: { checkAnswer(expected: expected) }) {
                    Text("CHECK")
                        .font(.system(size: 14, weight: .heavy, design: .monospaced))
                        .foregroundColor(.black)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 14)
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .fill(Color.green)
                        )
                }
                .disabled(practiceAnswer.isEmpty)
            }
            
            if showResult {
                if let answer = Int(practiceAnswer), abs(answer - expected) <= 1 {
                    HStack(spacing: 6) {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.green)
                        Text("Correct! Crosswind is \(expected) kt")
                            .foregroundColor(.green)
                    }
                    .font(.system(size: 15, weight: .bold, design: .monospaced))
                    .onAppear {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                            advancePractice()
                        }
                    }
                } else {
                    HStack(spacing: 6) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.red)
                        Text("Try again — check your inputs")
                            .foregroundColor(.red)
                    }
                    .font(.system(size: 15, weight: .bold, design: .monospaced))
                    .onAppear {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                            showResult = false
                            practiceAnswer = ""
                        }
                    }
                }
            }
        }
    }
    
    private func checkAnswer(expected: Int) {
        textFieldFocused = false
        showResult = true
    }
    
    private func advancePractice() {
        if currentInputMethod == "dial" {
            dialCompleted = min(dialCompleted + 1, 3)
        } else {
            keypadCompleted = min(keypadCompleted + 1, 3)
        }
        
        showResult = false
        practiceAnswer = ""
        
        let dialDone = currentInputMethod == "dial" ? dialCompleted : dialCompleted
        let keyDone = currentInputMethod == "keypad" ? keypadCompleted : keypadCompleted
        
        if currentInputMethod == "dial" && dialCompleted >= 3 && keypadCompleted < 3 {
            currentInputMethod = "keypad"
            practiceIndex = keypadCompleted
        } else if currentInputMethod == "keypad" && keypadCompleted >= 3 && dialCompleted < 3 {
            currentInputMethod = "dial"
            practiceIndex = dialCompleted
        } else if dialDone >= 3 && keyDone >= 3 {
            practiceIndex = 0
        } else {
            let current = currentInputMethod == "dial" ? dialCompleted : keypadCompleted
            practiceIndex = min(current, 2)
        }
    }
    
    private var progressGrid: some View {
        VStack(spacing: 10) {
            HStack(spacing: 0) {
                Text("")
                    .frame(width: 70)
                ForEach(0..<3) { i in
                    Text("#\(i + 1)")
                        .font(.system(size: 12, weight: .bold, design: .monospaced))
                        .foregroundColor(Color(white: 0.4))
                        .frame(maxWidth: .infinity)
                }
            }
            
            progressRow(label: "Dial", completed: dialCompleted,
                        color: Color(red: 0.94, green: 0.75, blue: 0.25))
            progressRow(label: "Keypad", completed: keypadCompleted,
                        color: Color(red: 0.22, green: 0.74, blue: 0.97))
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(white: 0.06))
        )
    }
    
    private func progressRow(label: String, completed: Int, color: Color) -> some View {
        HStack(spacing: 0) {
            Text(label)
                .font(.system(size: 13, weight: .heavy, design: .monospaced))
                .foregroundColor(color)
                .frame(width: 70, alignment: .leading)
            
            ForEach(0..<3) { i in
                Image(systemName: i < completed ? "checkmark.circle.fill" : "circle")
                    .font(.system(size: 20))
                    .foregroundColor(i < completed ? color : Color(white: 0.2))
                    .frame(maxWidth: .infinity)
            }
        }
    }
    
    private var surveyView: some View {
        VStack(spacing: 20) {
            Text("FEEDBACK")
                .font(.system(size: 28, weight: .heavy, design: .monospaced))
                .tracking(4)
                .foregroundColor(Color(red: 0.94, green: 0.75, blue: 0.25))
            
            Text("Help us make CrosswindCalc better")
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(Color(white: 0.45))
            
            surveyQuestion(
                title: "Which input method was your favorite?",
                options: ["Rotary Dials", "Keypad", "No preference"],
                selection: $surveyFavorite
            )
            
            surveyQuestion(
                title: "Should both options remain in the app?",
                options: ["Keep both", "Dials only", "Keypad only"],
                selection: $surveyKeepBoth
            )
            
            surveyQuestion(
                title: "Which felt faster?",
                options: ["Rotary Dials", "Keypad", "About the same"],
                selection: $surveyFaster
            )
            
            surveyQuestion(
                title: "Which would be easier in turbulence?",
                options: ["Rotary Dials", "Keypad", "About the same"],
                selection: $surveyTurbulence
            )
            
            surveyQuestion(
                title: "Was one easier to read?",
                options: ["Rotary Dials", "Keypad", "Both were clear"],
                selection: $surveyEasierRead
            )
            
            VStack(alignment: .leading, spacing: 8) {
                Text("Anything you'd change or like to see added?")
                    .font(.system(size: 15, weight: .bold))
                    .foregroundColor(.white)
                
                TextEditor(text: $surveyChanges)
                    .font(.system(size: 15))
                    .foregroundColor(.white)
                    .scrollContentBackground(.hidden)
                    .frame(minHeight: 80)
                    .padding(10)
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color(white: 0.08))
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(Color(white: 0.2), lineWidth: 1)
                            )
                    )
            }
            
            if let error = submitError {
                Text(error)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(.red)
            }
            
            Button(action: { submitSurvey() }) {
                HStack {
                    if isSubmitting {
                        ProgressView()
                            .tint(.black)
                    } else {
                        Text("SUBMIT FEEDBACK")
                            .font(.system(size: 16, weight: .heavy, design: .monospaced))
                            .tracking(2)
                    }
                }
                .foregroundColor(.black)
                .frame(maxWidth: .infinity)
                .frame(height: 52)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(surveyComplete ?
                              Color(red: 0.94, green: 0.75, blue: 0.25) :
                              Color(white: 0.2))
                )
            }
            .disabled(!surveyComplete || isSubmitting)
        }
    }
    
    private var surveyComplete: Bool {
        !surveyFavorite.isEmpty &&
        !surveyKeepBoth.isEmpty &&
        !surveyFaster.isEmpty &&
        !surveyTurbulence.isEmpty &&
        !surveyEasierRead.isEmpty
    }
    
    private func surveyQuestion(title: String, options: [String], selection: Binding<String>) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.system(size: 15, weight: .bold))
                .foregroundColor(.white)
            
            ForEach(options, id: \.self) { option in
                Button(action: { selection.wrappedValue = option }) {
                    HStack(spacing: 10) {
                        Image(systemName: selection.wrappedValue == option ?
                              "largecircle.fill.circle" : "circle")
                            .font(.system(size: 20))
                            .foregroundColor(selection.wrappedValue == option ?
                                Color(red: 0.94, green: 0.75, blue: 0.25) :
                                Color(white: 0.25))
                        
                        Text(option)
                            .font(.system(size: 15, weight: .medium))
                            .foregroundColor(selection.wrappedValue == option ?
                                .white : Color(white: 0.5))
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.vertical, 4)
                }
            }
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(Color(white: 0.06))
        )
    }
    
    private var submittedView: some View {
        VStack(spacing: 20) {
            Spacer().frame(height: 40)
            
            Image(systemName: "checkmark.seal.fill")
                .font(.system(size: 72))
                .foregroundColor(.green)
            
            Text("THANK YOU!")
                .font(.system(size: 28, weight: .heavy, design: .monospaced))
                .tracking(4)
                .foregroundColor(.white)
            
            Text("Your feedback helps make\nCrosswindCalc better for all pilots")
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(Color(white: 0.5))
                .multilineTextAlignment(.center)
            
            Spacer().frame(height: 40)
            
            Button(action: {
                withAnimation { phaseRaw = "survey" }
            }) {
                HStack(spacing: 8) {
                    Image(systemName: "arrow.counterclockwise")
                        .font(.system(size: 16, weight: .bold))
                    Text("CHANGE MY VOTE")
                        .font(.system(size: 14, weight: .heavy, design: .monospaced))
                        .tracking(1)
                }
                .foregroundColor(Color(white: 0.5))
                .frame(maxWidth: .infinity)
                .frame(height: 48)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color(white: 0.08))
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color(white: 0.15), lineWidth: 1)
                        )
                )
            }
            
            Button(action: {
                showOnboarding = true
            }) {
                HStack(spacing: 8) {
                    Image(systemName: "book.fill")
                        .font(.system(size: 16, weight: .bold))
                    Text("VIEW ONBOARDING")
                        .font(.system(size: 14, weight: .heavy, design: .monospaced))
                        .tracking(1)
                }
                .foregroundColor(Color(white: 0.5))
                .frame(maxWidth: .infinity)
                .frame(height: 48)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color(white: 0.08))
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color(white: 0.15), lineWidth: 1)
                        )
                )
            }
            
            Button(action: { resetAll() }) {
                HStack(spacing: 8) {
                    Image(systemName: "arrow.triangle.2.circlepath")
                        .font(.system(size: 16, weight: .bold))
                    Text("REDO PRACTICE")
                        .font(.system(size: 14, weight: .heavy, design: .monospaced))
                        .tracking(1)
                }
                .foregroundColor(Color(white: 0.5))
                .frame(maxWidth: .infinity)
                .frame(height: 48)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color(white: 0.08))
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color(white: 0.15), lineWidth: 1)
                        )
                )
            }
        }
    }
    
    private func resetAll() {
        dialCompleted = 0
        keypadCompleted = 0
        practiceIndex = 0
        currentInputMethod = "dial"
        practiceAnswer = ""
        showResult = false
        surveyFavorite = ""
        surveyKeepBoth = ""
        surveyFaster = ""
        surveyTurbulence = ""
        surveyEasierRead = ""
        surveyChanges = ""
        withAnimation { phaseRaw = "practice" }
    }
    
    private func submitSurvey() {
        isSubmitting = true
        submitError = nil
        
        let formURL = "GOOGLE_FORM_URL_HERE"
        
        guard let url = URL(string: formURL) else {
            submitError = "Invalid form URL"
            isSubmitting = false
            return
        }
        
        var components = URLComponents(url: url, resolvingAgainstBaseURL: false)
        components?.queryItems = [
            URLQueryItem(name: "entry.FIELD1", value: surveyFavorite),
            URLQueryItem(name: "entry.FIELD2", value: surveyKeepBoth),
            URLQueryItem(name: "entry.FIELD3", value: surveyFaster),
            URLQueryItem(name: "entry.FIELD4", value: surveyTurbulence),
            URLQueryItem(name: "entry.FIELD5", value: surveyEasierRead),
            URLQueryItem(name: "entry.FIELD6", value: surveyChanges),
        ]
        
        guard let submitURL = components?.url else {
            submitError = "Could not build URL"
            isSubmitting = false
            return
        }
        
        var request = URLRequest(url: submitURL)
        request.httpMethod = "GET"
        
        URLSession.shared.dataTask(with: request) { _, response, error in
            DispatchQueue.main.async {
                isSubmitting = false
                if let error = error {
                    submitError = "Failed to submit: \(error.localizedDescription)"
                } else {
                    withAnimation { phaseRaw = "submitted" }
                }
            }
        }.resume()
    }
}

extension FeedbackPhase {
    init(rawValue: String) {
        switch rawValue {
        case "survey": self = .survey
        case "submitted": self = .submitted
        default: self = .practice
        }
    }
    
    var rawString: String {
        switch self {
        case .practice: return "practice"
        case .survey: return "survey"
        case .submitted: return "submitted"
        }
    }
}
