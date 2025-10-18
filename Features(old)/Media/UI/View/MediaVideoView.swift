//
//  MediaVideoView.swift
//  SocialMap
//
//  Created by Arnaud Maillet on 07/10/2025.
//

import UIKit
import AVFoundation

extension MediaFeature.UI.View {
    public final class MediaVideoView: UIView {
        typealias MediaContent = MediaFeature.Domain.Model.MediaContent
        
        private var player: AVPlayer?
        private var playerLayer: AVPlayerLayer?
        
        public init(media: MediaContent) {
            super.init(frame: .zero)
            clipsToBounds = true
            loadVideo(for: media)
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        private func loadVideo(for media: MediaContent) {
            guard case .url(let url) = media.source else { return }
            let player = AVPlayer(url: url)
            self.player = player
            
            let layer = AVPlayerLayer(player: player)
            layer.videoGravity = .resizeAspectFill
            self.layer.addSublayer(layer)
            self.playerLayer = layer
            
            player.play()
        }
        
        public override func layoutSubviews() {
            super.layoutSubviews()
            playerLayer?.frame = bounds
        }
    }
}
