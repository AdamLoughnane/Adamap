
import SwiftUI
import AVFoundation

struct BreathView: View {
    enum Phase { case idle, breathing, retention, recovery }

    @State private var phase: Phase = .idle

    // Audio + Video state
    @State private var breathAudio: AVAudioPlayer?
    @State private var audioDelegate = AudioDelegate()
    @State private var retentionSeconds = 0
    @State private var recoverySeconds = 15
    @State private var timer: Timer?
    @State private var breathAudioPlayer: AVAudioPlayer?
    @State private var videoPlayer: AVPlayer?

    var body: some View {
        ZStack {
            Color.white.ignoresSafeArea()   // always white background

            VStack(spacing: 24) {
                Text("Breathwork")
                    .font(.largeTitle)
                    .foregroundColor(.black)
                    .padding(.top, 40)

                Spacer()

                // Main phase switch
                switch phase {
                case .idle:
                    Text("Ready to begin?")
                        .font(.title2)
                        .foregroundColor(.black)

                case .breathing:
                    VStack(spacing: 16) {
                        if let videoPlayer = videoPlayer {
                            SyncedVideoView(player: videoPlayer)
                                .aspectRatio(contentMode: .fit)   // keep natural size
                                .frame(maxWidth: 350, maxHeight: 350)
                        }

                        Text("Breathing Phase\nListen to the guide")
                            .multilineTextAlignment(.center)
                            .font(.title2)
                            .foregroundColor(.black)
                            
                    }

                case .retention:
                    VStack {
                        Text("Retention")
                            .font(.title2)
                            .foregroundColor(.black)

                        Text("\(retentionSeconds) sec")
                            .font(.system(size: 50, weight: .bold))
                            .foregroundColor(.black)

                        Text("Tap to stop retention")
                            .foregroundColor(.gray)
                            .font(.footnote)
                    }
                    .onTapGesture {
                        stopTimer()
                        startRecovery()
                    }

                case .recovery:
                    VStack {
                        Text("Recovery")
                            .font(.title2)
                            .foregroundColor(.black)

                        Text("\(recoverySeconds) sec")
                            .font(.system(size: 50, weight: .bold))
                            .foregroundColor(.black)
                    }
                }

                Spacer()

                // Buttons
                HStack(spacing: 16) {
                    Button("Start") { startBreathing() }
                        .buttonStyle(.borderedProminent)
                        .tint(.blue)
                        .disabled(phase == .breathing)

                    Button("Stop") { stopAll() }
                        .buttonStyle(.bordered)
                        .tint(.red)
                        .disabled(phase == .idle)
                }

                // Debug button
                Button("Test Play (debug)") { breathAudio?.play() }
                    .font(.footnote)
                    .foregroundColor(.gray)

                Spacer(minLength: 20)
            }
        }
        .preferredColorScheme(.light)   // lock this screen to Light Mode
        .onAppear {
            setupAudioSession()
            loadAudio()
        }
        .onDisappear {
            stopAll()
            try? AVAudioSession.sharedInstance().setActive(false)
        }
    }

    // MARK: - Audio

    private func setupAudioSession() {
        do {
            let session = AVAudioSession.sharedInstance()
            try session.setCategory(.playback, mode: .default, options: [])
            try session.setActive(true)
            print("✅ Audio session ready")
        } catch {
            print("⚠️ Audio session error: \(error)")
        }
    }

    private func loadAudio() {
        if let url = Bundle.main.url(forResource: "breath30", withExtension: "mp3") {
            print("✅ Found breath30.mp3 at: \(url.lastPathComponent)")
            do {
                let player = try AVAudioPlayer(contentsOf: url)
                player.numberOfLoops = 0
                player.prepareToPlay()
                player.volume = 1.0

                audioDelegate.onFinish = {
                    self.startRetention()
                }
                player.delegate = audioDelegate

                breathAudio = player
            } catch {
                print("❌ AVAudioPlayer init failed: \(error)")
            }
        } else {
            print("❌ breath30.mp3 not found in app bundle")
        }
    }

    // MARK: - Flow

    private func startBreathing() {
        phase = .breathing

        if let audioURL = Bundle.main.url(forResource: "breath30", withExtension: "mp3"),
           let videoURL = Bundle.main.url(forResource: "breath30", withExtension: "mov") {
            do {
                // Audio
                breathAudioPlayer = try AVAudioPlayer(contentsOf: audioURL)
                breathAudioPlayer?.prepareToPlay()

                // Video (persistent player)
                if videoPlayer == nil {
                    videoPlayer = AVPlayer(url: videoURL)
                } else {
                    videoPlayer?.seek(to: .zero)
                }

                // Sync start
                breathAudioPlayer?.play()
                videoPlayer?.play()

                // Detect when audio finishes
                audioDelegate.onFinish = {
                    self.startRetention()
                }
                breathAudioPlayer?.delegate = audioDelegate
            } catch {
                print("❌ Failed to play audio: \(error)")
            }
        } else {
            print("❌ Could not find breath30 audio or video")
        }
    }

    private func startRetention() {
        phase = .retention
        print("⏱️ enter Retention")
        retentionSeconds = 0
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            retentionSeconds += 1
        }
    }

    private func startRecovery() {
        phase = .recovery
        print("⏳ enter Recovery (15s)")
        recoverySeconds = 15
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { t in
            if recoverySeconds > 0 {
                recoverySeconds -= 1
            } else {
                t.invalidate()
                startBreathing() // loop back
            }
        }
    }

    private func stopAll() {
        stopTimer()
        breathAudio?.stop()
        phase = .idle
        print("⏹️ stopAll()")
    }

    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
}

// MARK: - Delegate
final class AudioDelegate: NSObject, AVAudioPlayerDelegate {
    var onFinish: (() -> Void)?
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        onFinish?()
    }
}
