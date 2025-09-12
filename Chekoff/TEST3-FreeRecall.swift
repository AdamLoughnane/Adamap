import SwiftUI

struct FreeRecallTestView: View {
    enum Phase {
        case input, study, delay, recall, results
    }
    
    @AppStorage("freeRecallWords") private var savedWords: Data = Data()
    @AppStorage("freeRecallDefs") private var savedDefs: Data = Data()
    
    @State private var inputWords: [String] = Array(repeating: "", count: 20)
    @State private var inputDefs: [String] = Array(repeating: "", count: 20)   // NEW
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
                            HStack {
                                TextField("Word \(i+1)", text: $inputWords[i])
                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                                
                                TextField("Definition", text: $inputDefs[i])   // NEW
                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                            }
                            .padding(.horizontal)
                        }
                    }
                }
                
                HStack {
                    Button("Clear All") {
                        inputWords = Array(repeating: "", count: 20)
                        inputDefs = Array(repeating: "", count: 20)
                        saveWords()
                    }
                    .buttonStyle(.bordered)
                    
                    Button("Start Test") {
                        studyList = inputWords
                            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
                            .filter { !$0.isEmpty }
                        saveWords()
                        startStudyPhase()
                    }
                    .buttonStyle(.borderedProminent)
                }
                .padding()
                
            case .study:
                VStack {
                    Text("Study these words")
                        .font(.title2)
                        .padding()
                    
                    ScrollView {
                        VStack(spacing: 8) {
                            ForEach(Array(inputWords.enumerated()), id: \.offset) { idx, word in
                                if !word.isEmpty {
                                    HStack {
                                        Text(word).font(.headline)
                                        if !inputDefs[idx].isEmpty {
                                            Text("– \(inputDefs[idx])")
                                                .foregroundColor(.secondary)
                                        }
                                    }
                                }
                            }
                        }
                        .padding()
                    }
                    
                    Text("Time remaining: \(timeRemaining) sec")
                        .font(.headline)
                        .padding()
                    
                    Button("Skip ▶︎") {
                        timer?.invalidate()
                        startDelayPhase()
                    }
                    .buttonStyle(.bordered)
                    .padding(.top, 10)
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
                    
                    Button("Skip ▶︎") {
                        timer?.invalidate()
                        phase = .recall
                    }
                    .buttonStyle(.bordered)
                    .padding(.top, 10)
                }
                
            case .recall:
                VStack {
                    Text("Type all words you recall (space or comma separated):")
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
                VStack {
                    Text("Results")
                        .font(.title2)
                        .padding()
                    
                    ScrollView {
                        VStack(alignment: .leading, spacing: 8) {
                            let recalledSet = Set(
                                recalledWords
                                    .lowercased()
                                    .components(separatedBy: CharacterSet(charactersIn: " ,\n"))
                                    .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
                                    .filter { !$0.isEmpty }
                            )
                            
                            ForEach(studyList, id: \.self) { word in
                                Text(word)
                                    .foregroundColor(recalledSet.contains(word.lowercased()) ? .red : .primary)
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
    }
    
    // MARK: - Persistence
    private func saveWords() {
        if let data = try? JSONEncoder().encode(inputWords) {
            savedWords = data
        }
        if let defsData = try? JSONEncoder().encode(inputDefs) {
            savedDefs = defsData
        }
    }
    
    private func loadWords() {
        if let words = try? JSONDecoder().decode([String].self, from: savedWords) {
            inputWords = words
        }
        if let defs = try? JSONDecoder().decode([String].self, from: savedDefs) {
            inputDefs = defs
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
        studyList = []
        recalledWords = ""
        phase = .input
        timeRemaining = 0
        timer?.invalidate()
    }
}
