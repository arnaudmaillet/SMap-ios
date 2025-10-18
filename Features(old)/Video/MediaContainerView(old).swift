//
//  MediaContainerView.swift
//  SocialMap
//
//  Created by Arnaud Maillet on 22/05/2025.
//

import UIKit
import AVFoundation

final class MediaContainerView: UIView {
    
    // MARK: - Subviews
    let imageView = UIImageView()
    var videoPlayerView: VideoPlayerView?
    var currentMedia: MediaContent?
    
    private let usesStandalonePlayer: Bool
    
    // MARK: - Init
    init(frame: CGRect = .zero, usesStandalonePlayer: Bool = false) {
        self.usesStandalonePlayer = usesStandalonePlayer
        super.init(frame: frame)
        setupImageView()
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        imageView.frame = bounds
        videoPlayerView?.frame = bounds
    }
    
    func prepareForReuse() {
        currentMedia = nil
        imageView.image = nil
        imageView.isHidden = false
        
        videoPlayerView?.pause()
        videoPlayerView?.removeFromSuperview()
        videoPlayerView = nil
        
        layer.removeAllAnimations()
        transform = .identity
        alpha = 1
    }
    
    // MARK: - Setup
    private func setupImageView() {
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.frame = bounds
        imageView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        addSubview(imageView)
    }
    
    // MARK: - Public API
    func display(media: MediaContent) {
        currentMedia = media
        
        if let image =  media.thumbnailImage {
            imageView.image = image
        } else if let url = media.thumbnailURL {
            imageView.loadImage(from: url)
        } else {
            imageView.image = UIImage(named: "placeholder")
        }
    }
    
    func showVideoPlayer(_ playerView: VideoPlayerView) {
        let isSamePlayerAndInPlace = (videoPlayerView === playerView && playerView.superview === self)
        
        if !isSamePlayerAndInPlace {
            if playerView.superview !== self {
                videoPlayerView?.removeFromSuperview()
                insertSubview(playerView, aboveSubview: imageView)
                playerView.frame = bounds
                playerView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            }
            videoPlayerView = playerView
            
            let isPlayerAlreadyReady = playerView.didTriggerFirstFrame
            playerView.alpha = isPlayerAlreadyReady ? 1 : 0
            
            playerView.onFirstFrameRendered = { [weak self, weak playerView] in
                guard let self, let player = playerView else { return }
                UIView.animate(withDuration: 0.18, delay: 0, options: [.curveEaseInOut]) {
                    player.alpha = 1
                }
            }
        }
        
        if !playerView.isPlaying {
            playerView.play()
        }
    }
    
//    func assignNewPlayer(for media: MediaContent) {
//        guard media.isVideo, let url = media.url else { return }
//        let videoId = media.id.uuidString
//        
//        if let player = VideoPlayerManager.shared.assignNewPlayer(for: videoId, url: url) {
//            showVideoPlayer(player)
//        } else {
//            print("❌ [MediaView] assignNewPlayer a échoué pour \(videoId)")
//        }
//    }
    
    func assignPlayer() {
        guard
            let currentMedia = debugUnwrap(currentMedia),
            let url = currentMedia.url,
            currentMedia.isVideo
        else { return }
        let videoId = currentMedia.id.uuidString
        
        if let player = VideoPlayerManager.shared.assignPlayer(for: videoId, url: url) {
            showVideoPlayer(player)
        } else {
            print("❌ [MediaView] assignNewPlayer a échoué pour \(videoId)")
        }
    }
    
    func assignStandalonePlayer(for media: MediaContent) {
        let videoId = media.id.uuidString
        if let player = VideoPlayerManager.shared.createStandalonePlayer(for: media) {
            showVideoPlayer(player)
        } else {
            print("❌ [MediaView] assignStandalonePlayer a échoué pour \(videoId)")
        }
    }
    
    func migratePlayer(to media: MediaContent, from toReplace: MediaContent?) {
        guard media.isVideo, let url = media.url else { return }
        let videoId = media.id.uuidString
        
        guard let toReplace = toReplace else {
            print("❌ [MediaView] Aucun media à remplacer fourni pour \(videoId)")
            return
        }
        
        let replaceId = toReplace.id.uuidString
        if let migrated = VideoPlayerManager.shared.migratePlayer(from: replaceId, to: videoId, url: url) {
            showVideoPlayer(migrated)
        } else {
            print("⚠️ [MediaView] Impossible de migrer depuis \(replaceId)")
        }
    }
    
    
    func hideVideoPlayer() {
        videoPlayerView?.pause()
        videoPlayerView?.removeFromSuperview()
        videoPlayerView = nil
        imageView.isHidden = false
        imageView.alpha = 1
    }
    
    func releasePlayer() {
        guard let media = currentMedia else { return }

        if usesStandalonePlayer {
            VideoPlayerManager.shared.releaseStandalonePlayer(for: media.id.uuidString)
        } else {
            VideoPlayerManager.shared.releasePlayer(for: media.id.uuidString)
        }
    }
    
    func playVideoPlayer()  {
        videoPlayerView?.play()
    }
    func pauseVideoPlayer() { videoPlayerView?.pause() }
    
    
    func forceImageViewToManualLayout() {
        imageView.translatesAutoresizingMaskIntoConstraints = true
        imageView.frame = self.bounds
        imageView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    }
    
    func restoreImageViewAutoLayout() {
        imageView.translatesAutoresizingMaskIntoConstraints = false
    }
    
    func pauseIfNeeded() {
        videoPlayerView?.player?.pause()
    }
    
    func resumeIfNeeded() {
        if let player = videoPlayerView?.player, player.timeControlStatus != .playing {
            player.play()
        }
    }
    
    func isDisplayingPlayer(_ playerView: VideoPlayerView) -> Bool {
        return videoPlayerView === playerView
    }
}

//final class MediaContainerView: UIView {
//
//    // MARK: - Subviews
//    let imageView = UIImageView()
//    var videoPlayerView: VideoPlayerView?
//    var currentMedia: MediaContent?
//
//    // MARK: - Init
//    override init(frame: CGRect) {
//        super.init(frame: frame)
//        setupImageView()
//    }
//
//    required init?(coder: NSCoder) { fatalError() }
//
//    override func layoutSubviews() {
//        super.layoutSubviews()
//        imageView.frame = self.bounds
//    }
//
//    func prepareForReuse() {
//        currentMedia = nil
//        imageView.image = nil
//        imageView.isHidden = false
//
//        videoPlayerView?.pause()
//        videoPlayerView?.removeFromSuperview()
//        videoPlayerView = nil
//
//        layer.removeAllAnimations()
//        transform = .identity
//        alpha = 1
//    }
//
//    // MARK: - Setup
//
//    private func setupImageView() {
//        imageView.contentMode = .scaleAspectFill
//        imageView.clipsToBounds = true
//        imageView.translatesAutoresizingMaskIntoConstraints = false
//        addSubview(imageView)
//
//        NSLayoutConstraint.activate([
//            imageView.topAnchor.constraint(equalTo: topAnchor),
//            imageView.bottomAnchor.constraint(equalTo: bottomAnchor),
//            imageView.leadingAnchor.constraint(equalTo: leadingAnchor),
//            imageView.trailingAnchor.constraint(equalTo: trailingAnchor),
//        ])
//    }
//
//    // MARK: - Public API
//
//    func display(media: MediaContent) {
//        currentMedia = media
//
//        if let image =  media.thumbnailImage {
//            imageView.image = image
//        } else if let url = media.thumbnailURL {
//            imageView.loadImage(from: url)
//        } else {
//            imageView.image = UIImage(named: "placeholder")
//        }
//    }
//
//    func showVideoPlayer(_ playerView: VideoPlayerView) {
//        let isSamePlayerAndInPlace = (videoPlayerView === playerView && playerView.superview === self)
//
//        if !isSamePlayerAndInPlace {
//            if playerView.superview !== self {
//                videoPlayerView?.removeFromSuperview()
//                insertSubview(playerView, aboveSubview: imageView)
//                playerView.frame = bounds
//                playerView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
//                playerView.setNeedsLayout()
//                playerView.layoutIfNeeded()
//            }
//
//            videoPlayerView = playerView
//
//            let isPlayerAlreadyReady = playerView.didTriggerFirstFrame
//            playerView.alpha = isPlayerAlreadyReady ? 1 : 0
//
//            playerView.onFirstFrameRendered = { [weak self, weak playerView] in
//                guard let self, let player = playerView else { return }
//                UIView.animate(withDuration: 0.18, delay: 0, options: [.curveEaseInOut]) {
//                    player.alpha = 1
//                }
//            }
//
//            if let playerLayer = playerView.playerLayer {
//                print("🎬 VideoPlayerView has AVPlayerLayer with player:", playerLayer.player ?? "❌ nil")
//            } else {
//                print("❌ No AVPlayerLayer found in VideoPlayerView")
//            }
//            debugInfo()
//        }
//
//        if !playerView.isPlaying {
//            playerView.play()
//        }
//    }
//
//    func assignNewPlayer(for media: MediaContent) {
//        guard media.isVideo, let url = media.url else { return }
//        let videoId = media.id.uuidString
//
//        if let player = VideoPlayerManager.shared.assignNewPlayer(for: videoId, url: url) {
//            showVideoPlayer(player)
//        } else {
//            print("❌ [MediaView] assignNewPlayer a échoué pour \(videoId)")
//        }
//    }
//
//    func migratePlayer(to media: MediaContent, from toReplace: MediaContent?) {
//        guard media.isVideo, let url = media.url else { return }
//        let videoId = media.id.uuidString
//
//        guard let toReplace = toReplace else {
//            print("❌ [MediaView] Aucun media à remplacer fourni pour \(videoId)")
//            return
//        }
//
//        let replaceId = toReplace.id.uuidString
//        if let migrated = VideoPlayerManager.shared.migratePlayer(from: replaceId, to: videoId, url: url) {
//            showVideoPlayer(migrated)
//        } else {
//            print("⚠️ [MediaView] Impossible de migrer depuis \(replaceId)")
//        }
//    }
//
//
//    func hideVideoPlayer() {
//        videoPlayerView?.pause()
//        videoPlayerView?.removeFromSuperview()
//        videoPlayerView = nil
//        imageView.isHidden = false
//        imageView.alpha = 1
//    }
//
//    func playVideoPlayer()  {
//        videoPlayerView?.play()
//    }
//    func pauseVideoPlayer() { videoPlayerView?.pause() }
//
//
//    func forceImageViewToManualLayout() {
//        imageView.translatesAutoresizingMaskIntoConstraints = true
//        imageView.frame = self.bounds
//        imageView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
//    }
//
//    func restoreImageViewAutoLayout() {
//        imageView.translatesAutoresizingMaskIntoConstraints = false
//    }
//}


extension MediaContainerView {
    func debugInfo(label: String = "") {
        let prefix = label.isEmpty ? "" : "[\(label)] "
        let hasPlayer = videoPlayerView != nil
        let isInViewHierarchy = videoPlayerView?.superview === self
        let isPlaying = videoPlayerView?.isPlaying ?? false
        let mediaId = currentMedia?.id.uuidString.prefix(6) ?? "nil"
        
        print("""
        \(prefix)🧩 MediaView Debug:
        • ref: \(Unmanaged.passUnretained(self).toOpaque())
        • mediaId: \(mediaId)
        • hasPlayerView: \(hasPlayer ? "✅ yes" : "❌ no")
        • inHierarchy: \(isInViewHierarchy ? "✅ yes" : "❌ no")
        • isPlaying: \(isPlaying ? "▶️ playing" : "⏸️ paused/stopped")
        • superview: \(String(describing: self.superview))
        • playerSuperview: \(String(describing: videoPlayerView?.superview))
        """)
    }
}
