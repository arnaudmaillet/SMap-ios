//
//  MediaImageView.swift
//  SocialMap
//
//  Created by Arnaud Maillet on 07/10/2025.
//

import UIKit

extension MediaFeature.UI.View {
    public final class MediaImageView: UIImageView {
        typealias MediaContent = MediaFeature.Domain.Model.MediaContent
        
        public init(media: MediaContent) {
            super.init(frame: .zero)
            contentMode = .scaleAspectFill
            clipsToBounds = true
            loadImage(for: media)
        }

        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }

        private func loadImage(for media: MediaContent) {
            switch media.source {
            case .asset(let name):
                self.image = UIImage(named: name)

            case .file(let path):
                self.image = UIImage(contentsOfFile: path)

            case .url(let url):
                // Simple fallback loader (à remplacer par SDWebImage ou Nuke si besoin)
                Task {
                    do {
                        let (data, _) = try await URLSession.shared.data(from: url)
                        if let image = UIImage(data: data) {
                            DispatchQueue.main.async {
                                self.image = image
                            }
                        }
                    } catch {
                        print("MediaImageView: failed to load image at \(url): \(error)")
                    }
                }
            }
        }
    }
}
