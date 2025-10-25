//
//  MediaViewModel.swift
//  SocialMap
//
//  Created by Arnaud Maillet on 16/10/2025.
//

import Foundation
import Combine
import AVFoundation
import UIKit

extension MediaNamespace.Presentation.ViewModels {
    final class MediaViewModel: ObservableObject {
        typealias Media = MediaNamespace.Domain.Entities.Media

        @Published private(set) var image: UIImage?
        @Published private(set) var isPlayerReady: Bool = false
        private(set) var player: AVPlayer?

        private let media: Media
        private var statusObserver: NSKeyValueObservation?

        init(media: Media) {
            self.media = media
        }

        func load() {
            if media.type == .image {
                loadImage(from: media.url)
            } else if media.type == .video {
                // Charge d’abord l’image comme fallback (plus rapide)
                loadImage(from: media.url)
                preparePlayer()
            }
        }

        private func loadImage(from url: URL) {
            DispatchQueue.global(qos: .userInitiated).async {
                guard let data = try? Data(contentsOf: url),
                      let image = UIImage(data: data) else { return }

                DispatchQueue.main.async {
                    self.image = image
                }
            }
        }

        private func preparePlayer() {
            let asset = AVURLAsset(url: media.url)
            let item = AVPlayerItem(asset: asset)

            player = AVPlayer(playerItem: item)

            statusObserver = item.observe(\.status, options: [.initial, .new]) { [weak self] item, _ in
                DispatchQueue.main.async {
                    if item.status == .readyToPlay {
                        self?.isPlayerReady = true
                        self?.statusObserver = nil
                    } else if item.status == .failed {
                        print("❌ Failed to load AVPlayerItem: \(item.error?.localizedDescription ?? "")")
                        self?.statusObserver = nil
                    }
                }
            }
        }
    }
}
