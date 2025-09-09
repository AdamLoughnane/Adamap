import SwiftUI

struct FreeRecallTestView: View {
    enum Phase {
        case input, study, delay, recall, results
    }
    
    @AppStorage("freeRecallWords") private var savedWords: Data = Data()
    
    @State private var inputWords: [String] = Array(repeating: "", count: 20)
    @State private var studyList: [String] = []
    @State private var recalledWords: String = ""
    @State private var phase: Phase = .input
    
    @State private var timeRemaining: Int = 0
    @State private var timer: Timer? = nil
    
    var body: some View {
        VStack {
            Text("Free Recall Test")
                .font(.largeTitle)
                .padding()
            
            switch phase {
            case .input:
                ScrollView {
                    VStack(spacing: 10) {
                        ForEach(0..<20, id: \.self) { i in
                            TextField("Word \(i+1)", text: $inputWords[i])
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .padding(.horizontal)
                        }
                    }
                }
                
                HStack {
                    Button("Clear") {
                        inputWords = Array(repeating: "", count: 20)
                        savedWords = Data()   // clear from AppStorage
                    }
                    .padding()
                    .buttonStyle(.bordered)

                    Button("Start Test") {
                        studyList = inputWords
                            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
                            .filter { !$0.isEmpty }
                        saveWords()
                        startStudyPhase()
                    }
                    .padding()
                    .buttonStyle(.borderedProminent)
                }
                
            case .study:
                VStack {
                    Text("Study these words")
                        .font(.title2)
                        .padding()
                    
                    ScrollView {
                        VStack(spacing: 8) {
                            ForEach(studyList, id: \.self) { word in
                                Text(word)
                                    .font(.headline)
                            }
                        }
                        .padding()
                    }
                    
                    Text("Time remaining: \(timeRemaining) sec")
                        .font(.headline)
                        .padding()

                    Button("Skip") {
                        timer?.invalidate()
                        startDelayPhase()
                    }
                    .padding()
                    .buttonStyle(.bordered)
                    
                }
                
            case .delay:
                VStack {
                    Text("Wait…")
                        .font(.title2)
                        .padding()
                    
                    Text("Recall phase begins in:")
                        .padding(.top)
                    
                    Text("\(timeRemaining) sec")
                        .font(.largeTitle)
                        .bold()
                        .padding()

                    Button("Skip") {
                        timer?.invalidate()
                        phase = .recall
                    }
                    .padding()
                    .buttonStyle(.bordered)
                }
                
            case .recall:
                VStack {
                    Text("Type all words you recall (space/comma/semicolon separated):")
                        .multilineTextAlignment(.center)
                        .padding()
                    
                    TextEditor(text: $recalledWords)
                        .frame(height: 150)
                        .border(Color.gray, width: 1)
                        .padding()
                    
                    Button("Check") {
                        phase = .results
                    }
                    .padding()
                    .buttonStyle(.borderedProminent)
                }
                
            case .results:
                // Build normalized sets once for scoring and display
                let separators = CharacterSet(charactersIn: ",，;； \n\t")
                let recalledSet: Set<String> = Set(
                    recalledWords
                        .components(separatedBy: separators)
                        .map(normalize)
                        .filter { !$0.isEmpty }
                )
                let normalizedStudy = studyList.map(normalize)
                let correctCount = normalizedStudy.filter { recalledSet.contains($0) }.count
                
                VStack {
                    Text("Results")
                        .font(.title2)
                        .padding(.top)
                    
                    Text("Correct: \(correctCount) / \(studyList.count)")
                        .font(.headline)
                        .padding(.bottom, 4)
                    
                    ScrollView {
                        VStack(alignment: .leading, spacing: 8) {
                            // Use indices so duplicates are handled per-position
                            ForEach(Array(studyList.enumerated()), id: \.offset) { idx, original in
                                let isHit = recalledSet.contains(normalizedStudy[idx])
                                Text(original)
                                    .foregroundColor(isHit ? .red : .primary)
                                    .font(.headline)
                            }
                        }
                        .padding()
                    }
                    
                    Button("Restart") {
                        resetTest()
                    }
                    .padding()
                    .buttonStyle(.bordered)
                }
            }
            
            Spacer()
        }
        .onAppear {
            loadWords()
        }
        .onDisappear {
            timer?.invalidate()
        }
    }
    
    // MARK: - Utilities
    private func normalize(_ s: String) -> String {
        s.trimmingCharacters(in: .whitespacesAndNewlines)
         .folding(options: [.diacriticInsensitive, .caseInsensitive], locale: .current)
    }
    
    // MARK: - Persistence
    private func saveWords() {
        if let data = try? JSONEncoder().encode(inputWords) {
            savedWords = data
        }
    }
    
    private func loadWords() {
        if let words = try? JSONDecoder().decode([String].self, from: savedWords) {
            inputWords = words
        }
    }
    
    // MARK: - Flow
    private func startStudyPhase() {
        phase = .study
        timeRemaining = 120 // 2 min
        startTimer {
            startDelayPhase()
        }
    }
    
    private func startDelayPhase() {
        phase = .delay
        timeRemaining = 180 // 3 min
        startTimer {
            phase = .recall
        }
    }
    
    private func startTimer(onFinish: @escaping () -> Void) {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { t in
            if timeRemaining > 0 {
                timeRemaining -= 1
            } else {
                t.invalidate()
                onFinish()
            }
        }
    }
    
    private func resetTest() {
        // keep words so you can reuse list
        studyList = []
        recalledWords = ""
        phase = .input
        timeRemaining = 0
        timer?.invalidate()
    }
}
