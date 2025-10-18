//
//  MediaView.swift
//  SocialMap
//
//  Created by Arnaud Maillet on 07/10/2025.
//

import UIKit

extension MediaFeature.UI.View {
    final class MediaView: UIView {
        typealias MediaContent = MediaFeature.Domain.Model.MediaContent
        
        private let imageView = UIImageView()
        private let videoPlayerView = UIView()

        override init(frame: CGRect) {
            super.init(frame: frame)
            setup()
        }

        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }

        private func setup() {
            imageView.contentMode = .scaleAspectFill
            imageView.clipsToBounds = true
            imageView.translatesAutoresizingMaskIntoConstraints = false
            videoPlayerView.translatesAutoresizingMaskIntoConstraints = false
            videoPlayerView.backgroundColor = .black

            addSubview(imageView)
            addSubview(videoPlayerView)

            NSLayoutConstraint.activate([
                imageView.topAnchor.constraint(equalTo: topAnchor),
                imageView.bottomAnchor.constraint(equalTo: bottomAnchor),
                imageView.leadingAnchor.constraint(equalTo: leadingAnchor),
                imageView.trailingAnchor.constraint(equalTo: trailingAnchor),

                videoPlayerView.topAnchor.constraint(equalTo: topAnchor),
                videoPlayerView.bottomAnchor.constraint(equalTo: bottomAnchor),
                videoPlayerView.leadingAnchor.constraint(equalTo: leadingAnchor),
                videoPlayerView.trailingAnchor.constraint(equalTo: trailingAnchor),
            ])

            imageView.isHidden = true
            videoPlayerView.isHidden = true
        }

        func configure(with media: MediaContent) {
            switch media.type {
            case .image:
                loadImage(for: media)
            case .video:
                loadVideo(for: media)
            }
        }

        private func loadImage(for media: MediaContent) {
            imageView.isHidden = false
            videoPlayerView.isHidden = true

            switch media.source {
            case .asset(let name):
                imageView.image = UIImage(named: name)
            case .file(let path):
                imageView.image = UIImage(contentsOfFile: path)
            case .url(let url):
                Task {
                    do {
                        let (data, _) = try await URLSession.shared.data(from: url)
                        if let image = UIImage(data: data) {
                            DispatchQueue.main.async {
                                self.imageView.image = image
                            }
                        }
                    } catch {
                        print("Erreur chargement image : \(error)")
                    }
                }
            }
        }

        private func loadVideo(for media: MediaContent) {
            imageView.isHidden = true
            videoPlayerView.isHidden = false

            // 🔜 Ajouter gestion AVPlayer ici
        }
    }
}
