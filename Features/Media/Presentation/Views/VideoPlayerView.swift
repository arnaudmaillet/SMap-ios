//
//  VideoPlayerView.swift
//  SocialMap
//
//  Created by Arnaud Maillet on 16/10/2025.
//

import UIKit
import AVFoundation

extension MediaFeature.UI.Views {
    final class VideoPlayerView: UIView {
        private var player: AVPlayer? {
            didSet {
                (layer as? AVPlayerLayer)?.player = player
            }
        }

        override class var layerClass: AnyClass {
            AVPlayerLayer.self
        }

        override init(frame: CGRect) {
            super.init(frame: frame)
            backgroundColor = .black
            (layer as? AVPlayerLayer)?.videoGravity = .resizeAspectFill
        }

        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }

        func attachPlayer(_ player: AVPlayer?) {
            self.player = player
        }

        func play() {
            player?.play()
        }

        func pause() {
            player?.pause()
        }

        func stop() {
            player?.pause()
            player?.seek(to: .zero)
            self.player = nil
        }
    }
}
