import SwiftUI

enum FeedbackPhase {
    case survey
    case submitted
}

struct FeedbackView: View {
    @Binding var showOnboarding: Bool
    @AppStorage("feedbackPhase") private var phaseRaw: String = "survey"
    
    @AppStorage("surveyFavorite") private var surveyFavorite: String = ""
    @AppStorage("surveyKeepBoth") private var surveyKeepBoth: String = ""
    @AppStorage("surveyFaster") private var surveyFaster: String = ""
    @AppStorage("surveyTurbulence") private var surveyTurbulence: String = ""
    @AppStorage("surveyEasierRead") private var surveyEasierRead: String = ""
    @AppStorage("surveyChanges") private var surveyChanges: String = ""
    
    @State private var isSubmitting: Bool = false
    @State private var submitError: String? = nil
    @FocusState private var textFieldFocused: Bool
    
    private var phase: FeedbackPhase {
        get { FeedbackPhase(rawValue: phaseRaw) }
        set { phaseRaw = newValue.rawString }
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                switch phase {
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
    
    private var surveyView: some View {
        VStack(spacing: 20) {
            Text("FEEDBACK")
                .font(.system(size: 28, weight: .heavy, design: .monospaced))
                .tracking(4)
                .foregroundColor(Color(red: 0.94, green: 0.75, blue: 0.25))
            
            Text("Try both input methods then\nhelp us decide what to keep")
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(Color(white: 0.45))
                .multilineTextAlignment(.center)
            
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
                    .focused($textFieldFocused)
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
        }
    }
    
    private func submitSurvey() {
        isSubmitting = true
        submitError = nil
        
        let formBase = "https://docs.google.com/forms/d/e/1FAIpQLScc3biOfKOiD595NLw-zYvJ_gXf3fNZ3ERVTX9TRV61KBdB1Q/formResponse"
        
        guard let url = URL(string: formBase) else {
            submitError = "Invalid form URL"
            isSubmitting = false
            return
        }
        
        var components = URLComponents()
        components.queryItems = [
            URLQueryItem(name: "entry.91727898", value: surveyFavorite),
            URLQueryItem(name: "entry.1117191226", value: surveyKeepBoth),
            URLQueryItem(name: "entry.767028705", value: surveyFaster),
            URLQueryItem(name: "entry.23646484", value: surveyTurbulence),
            URLQueryItem(name: "entry.2043755986", value: surveyEasierRead),
            URLQueryItem(name: "entry.93003604", value: surveyChanges),
        ]
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.httpBody = components.percentEncodedQuery?.data(using: .utf8)
        
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
        case "submitted": self = .submitted
        default: self = .survey
        }
    }
    
    var rawString: String {
        switch self {
        case .survey: return "survey"
        case .submitted: return "submitted"
        }
    }
}
