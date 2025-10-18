//
//  VideoPlayerView.swift
//  SocialMap
//
//  Created by Arnaud Maillet on 02/07/2025.
//

import UIKit
import AVFoundation

final class VideoPlayerView: UIView, VideoPlayable {

    // MARK: - Public Properties

    var videoId: UUID?
    var currentURL: URL?
    var player: AVPlayer?
    var onFirstFrameRendered: (() -> Void)?

    // MARK: - Private

    var playerLayer: AVPlayerLayer? { layer as? AVPlayerLayer }
    private var endObserver: NSObjectProtocol?
    var didTriggerFirstFrame = false
    private var displayObservation: NSKeyValueObservation?
    private var readyForDisplayObservation: NSKeyValueObservation?

    // MARK: - UIView

    override class var layerClass: AnyClass {
        return AVPlayerLayer.self
    }

    // MARK: - VideoPlayable

    func play() {
        player?.play()
    }

    func pause() {
        player?.pause()
    }
    
    var isVisible: Bool {
        return window != nil
    }
    
    var isPlaying: Bool {
        guard let player = player else { return false }
        return player.rate != 0 && player.error == nil
    }
    
    // MARK: - Configuration

    /// Configure le player avec une nouvelle URL et un ID associé
    func configure(with url: URL, id: UUID) {
        print("VideoPlayerView configure")
        // Si même vidéo déjà configurée, on ne fait rien
        if currentURL == url, player != nil, videoId == id { return }
        backgroundColor = .clear
        currentURL = url
        videoId = id
        cleanup()

        let player = AVPlayer(url: url)
        self.player = player
        playerLayer?.videoGravity = .resizeAspectFill
        playerLayer?.player = player
        playerLayer?.player?.isMuted = true
        playerLayer?.backgroundColor = UIColor.clear.cgColor
        displayObservation = playerLayer?.observe(\.isReadyForDisplay, options: [.new]) { [weak self] layer, change in
            guard let self = self else { return }
            if layer.isReadyForDisplay && !self.didTriggerFirstFrame {
                self.didTriggerFirstFrame = true
                DispatchQueue.main.async {
                    self.layoutIfNeeded()
                    self.playerLayer?.frame = self.bounds
                    self.onFirstFrameRendered?()
                }
            }
        }

        player.actionAtItemEnd = .pause
        player.seek(to: .zero)

        // Boucle automatique
        endObserver = NotificationCenter.default.addObserver(
            forName: .AVPlayerItemDidPlayToEndTime,
            object: player.currentItem,
            queue: .main
        ) { [weak self] _ in
            self?.player?.seek(to: .zero)
            self?.player?.play()
        }
    }
    
    func prepareToPlay(mediaId: UUID, url: URL) {
        guard videoId != mediaId else { return }
        
        videoId = mediaId
        let item = AVPlayerItem(url: url)
        player?.replaceCurrentItem(with: item)
    }

    
    func rebind(url: URL, id: UUID) {
        guard let player = self.player else {
            configure(with: url, id: id)
            return
        }

        // Sinon : remplacer le currentItem (soft bind)
        currentURL = url
        videoId = id
        didTriggerFirstFrame = false

        let item = AVPlayerItem(url: url)
        player.replaceCurrentItem(with: item)
        
        // observe le nouveau playerItem si besoin
        endObserver = NotificationCenter.default.addObserver(
            forName: .AVPlayerItemDidPlayToEndTime,
            object: item,
            queue: .main
        ) { [weak self] _ in
            self?.player?.seek(to: .zero)
            self?.player?.play()
        }

        print("🔄 rebind: switched to new video without recreating player")
    }
    
    func prepareForReuse() {
        // On efface l'image de l'ancien player AVANT de reconfigurer
        playerLayer?.player = nil
        self.player = nil
        backgroundColor = .clear
        alpha = 0 // invisible tant que la nouvelle frame n’est pas prête
        didTriggerFirstFrame = false
        currentURL = nil
        videoId = nil
        // Invalide tout observer
        displayObservation?.invalidate()
        displayObservation = nil
        if let observer = endObserver {
            NotificationCenter.default.removeObserver(observer)
            endObserver = nil
        }
    }

    // MARK: - Cleanup

    func cleanup() {
        playerLayer?.player = nil
        player = nil

        if let observer = endObserver {
            NotificationCenter.default.removeObserver(observer)
            endObserver = nil
        }
        displayObservation?.invalidate()
        displayObservation = nil
        didTriggerFirstFrame = false
        currentURL = nil
        videoId = nil
    }

    // MARK: - Deinit

    deinit {
        cleanup()
    }
}
