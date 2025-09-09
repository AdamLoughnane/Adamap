import SwiftUI

struct LetterSpanTestView: View {
    enum Phase {
        case showing    // showing sequence
        case inputting  // user entering
        case feedback   // waiting for retry or auto-advance
    }
    
    @State private var sequence: [String] = []
    @State private var currentIndex: Int = -1
    @State private var userInput: [String] = []
    @State private var phase: Phase = .showing
    @State private var feedback: String? = nil
    @State private var currentLength = 4
    @State private var maxScore = 0
    
    @State private var isLetterVisible: Bool = false
    @State private var showGetReady = true
    
    @State private var displayTask: Task<Void, Never>? = nil
    
    // Consonants only (vowels removed: A, E, I, O, U, sometimes Y)
    let letters = Array("BCDFGHJKLMNPQRSTVWXYZ").map { String($0) }
    
    var body: some View {
        VStack {
            Text("Letter Span Test")
                .font(.largeTitle)
                .padding(.top, 20)
            
            Spacer()
            
            Group {
                switch phase {
                case .showing:
                    if currentIndex >= 0 && currentIndex < sequence.count && isLetterVisible {
                        Text(sequence[currentIndex])
                            .id(currentIndex) // fixes flicker
                            .font(.system(size: 60, weight: .bold))
                            .transition(.opacity)
                    } else if showGetReady {
                        Text("Get ready…")
                            .font(.title2)
                            .foregroundColor(.secondary)
                    }
                    
                case .inputting:
                    VStack {
                        Text("Enter the letters:")
                        HStack {
                            ForEach(userInput.indices, id: \.self) { i in
                                Text(userInput[i])
                                    .font(.title2)
                                    .padding(5)
                            }
                        }
                        .frame(height: 40)
                        
                        Spacer()
                        
                        // Keypad of consonants
                        LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 4), count: 6), spacing: 4) {
                            ForEach(letters, id: \.self) { letter in
                                Button { userInput.append(letter) } label: {
                                    Text(letter)
                                        .font(.title2)
                                        .frame(width: 50, height: 50)
                                        .background(Color.gray.opacity(0.2))
                                        .cornerRadius(8)
                                }
                            }
                        }
                        .padding(.bottom, 10)
                        
                        // Clear / OK
                        HStack(spacing: 20) {
                            Button("Clear") {
                                userInput.removeAll()
                            }
                            .font(.title3)
                            .frame(width: 100, height: 50)
                            .background(Color.gray.opacity(0.2))
                            .cornerRadius(8)
                            
                            Button("OK") {
                                checkAnswer()
                            }
                            .font(.title3)
                            .frame(width: 100, height: 50)
                            .background(Color.gray.opacity(0.2))
                            .cornerRadius(8)
                        }
                    }
                    
                case .feedback:
                    if let feedback = feedback {
                        if feedback == "Correct!" {
                            Text(feedback)
                                .font(.title3)
                                .foregroundColor(.green)
                        } else {
                            Button(action: { startNewRound() }) {
                                Text(feedback)
                                    .font(.title3)
                                    .foregroundColor(.red)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
            }
            .frame(maxHeight: .infinity)
            
            Spacer()
            
            // Sequence length controls
            HStack {
                Button {
                    let newLen = max(2, currentLength - 1)
                    startNewRound(setLength: newLen)
                } label: {
                    Image(systemName: "minus.circle.fill")
                        .font(.title2)
                        .foregroundColor(.red)
                }
                
                Text("Sequence Length: \(currentLength)")
                    .font(.headline)
                    .padding(.horizontal)
                
                Button {
                    let newLen = currentLength + 1
                    startNewRound(setLength: newLen)
                } label: {
                    Image(systemName: "plus.circle.fill")
                        .font(.title2)
                        .foregroundColor(.green)
                }
            }
            .padding(.bottom, 10)
            
            Text("Max Score: \(maxScore)")
                .padding(.bottom, 20)
        }
        .padding()
        .onAppear {
            startNewRound()
        }
        .onDisappear {
            displayTask?.cancel()
        }
    }
    
    // MARK: - Logic
    
    private func startNewRound(setLength: Int? = nil) {
        displayTask?.cancel()
        
        if let setLength { currentLength = setLength }
        let len = currentLength
        
        sequence = (0..<len).map { _ in letters.randomElement()! }
        userInput.removeAll()
        feedback = nil
        currentIndex = -1
        isLetterVisible = false
        phase = .showing
        showGetReady = true
        
        let showTime: Double = 0.8
        let hideTime: Double = 0.4
        
        displayTask = Task { @MainActor in
            do {
                try await Task.sleep(for: .seconds(1.0))
                try Task.checkCancellation()
                
                withAnimation { self.showGetReady = false }
                
                for i in 0..<sequence.count {
                    try Task.checkCancellation()
                    
                    try await Task.sleep(for: .seconds(hideTime))
                    
                    self.currentIndex = i
                    withAnimation { self.isLetterVisible = true }
                    
                    try await Task.sleep(for: .seconds(showTime))
                    
                    withAnimation { self.isLetterVisible = false }
                }
                
                try await Task.sleep(for: .seconds(hideTime))
                try Task.checkCancellation()
                
                withAnimation { self.phase = .inputting }
            } catch {
                // cancelled
            }
        }
    }
    
    private func checkAnswer() {
        if userInput.count < sequence.count {
            feedback = "Not enough letters"
            phase = .feedback
            return
        }
        
        if userInput == sequence {
            feedback = "Correct!"
            maxScore = max(maxScore, currentLength)
            phase = .feedback
            
            displayTask?.cancel()
            displayTask = Task { @MainActor in
                try? await Task.sleep(for: .seconds(1.5))
                startNewRound()
            }
        } else {
            feedback = "Try again"
            phase = .feedback
        }
    }
}
