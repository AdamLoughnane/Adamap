import SwiftUI
import AVKit

struct SyncedVideoView: UIViewRepresentable {
    let player: AVPlayer   // shared player
    
    func makeUIView(context: Context) -> UIView {
        let view = VideoPlayerUIView(player: player)
        return view
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {
        if let v = uiView as? VideoPlayerUIView {
            v.updatePlayer(player)
        }
    }
}

class VideoPlayerUIView: UIView {
    private var playerLayer = AVPlayerLayer()
    
    init(player: AVPlayer) {
        super.init(frame: .zero)
        backgroundColor = .black
        
        playerLayer.player = player
        playerLayer.videoGravity = .resizeAspectFill
        layer.addSublayer(playerLayer)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        playerLayer.frame = bounds
    }
    
    func updatePlayer(_ player: AVPlayer) {
        playerLayer.player = player
    }
}
