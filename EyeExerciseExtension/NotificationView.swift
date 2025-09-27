import SwiftUI
import AVFoundation

struct NotificationView: View {
    @State private var remaining = 30
    @State private var timer: Timer?

    var body: some View {
        VStack(spacing: 2) { // tighter spacing
            Text("Eye Exercise")
                .font(.headline)

            Text("\(remaining)")
                .font(.system(size: 42, weight: .bold, design: .monospaced))

            Text("seconds left")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .padding(.vertical, 4) // just a little breathing room
        .frame(maxHeight: .infinity, alignment: .center) // center vertically, shrink
        .onAppear { startCountdown() }
        .onDisappear { timer?.invalidate() }
    }

    private func startCountdown() {
        remaining = 30
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { t in
            if remaining > 0 {
                remaining -= 1
            } else {
                t.invalidate()
                playDing()
            }
        }
    }

    private func playDing() {
        // System "ding"
        AudioServicesPlaySystemSound(1005)

        // OR use your own ding.wav if added to Resources:
        /*
        if let url = Bundle.main.url(forResource: "ding", withExtension: "wav") {
            var soundID: SystemSoundID = 0
            AudioServicesCreateSystemSoundID(url as CFURL, &soundID)
            AudioServicesPlaySystemSound(soundID)
        }
        */
    }
}
