//
//  PostPreviewView.swift
//  SocialMap
//
//  Created by Arnaud Maillet on 21/04/2025.
//

import UIKit
import AVFoundation

extension Post {
    final class PreviewView: UIView {
        
        // MARK: - UI Components
        
        let imageView = UIImageView()
        
        // MARK: - Properties
        
        private let aspectRatio: CGSize = CGSize(width: 9, height: 16)
        private(set) var isDisplayingVideo: Bool = false
        
        // MARK: - Initializer
        
        init(size: CGFloat = 72) {
            let defaultSize = CGSize(width: size, height: size)
            super.init(frame: CGRect(origin: .zero, size: defaultSize))
            
            backgroundColor = .black
            layer.cornerRadius = 16 + size.remainderAfterPowerOfTwo
            layer.borderWidth = 3
            layer.borderColor = UIColor.accent.cgColor
            clipsToBounds = true
            
            setupImageView()
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        // MARK: - Layout
        
        override func layoutSubviews() {
            super.layoutSubviews()
            imageView.frame = bounds
        }
        
        // MARK: - Setup
        
        /// Sets up the image view inside the preview.
        private func setupImageView() {
            imageView.contentMode = .scaleAspectFill
            imageView.backgroundColor = .black
            imageView.clipsToBounds = true
            imageView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            imageView.frame = bounds
            addSubview(imageView)
        }
        
        // MARK: - Configuration
        
        /// Configures the preview with a post and adjusts the size accordingly.
        func configure(with post: Post.Model, size: CGFloat) {
            isDisplayingVideo = post.mainRenderable?.isVideo ?? false

            let postSize: CGSize

            if isDisplayingVideo {
                let isVertical = post.mainRenderable?.isVertical ?? true
                if isVertical {
                    postSize = CGSize(width: size, height: size * (16.0 / 9.0))
                } else {
                    postSize = CGSize(width: size * (16.0 / 9.0), height: size)
                }
            } else {
                postSize = CGSize(width: size, height: size)
            }

            frame.size = postSize
            setNeedsLayout()
            layoutIfNeeded()

            if let thumbnail = post.mainRenderable?.thumbnailImage {
                imageView.image = thumbnail
            } else if let url = post.mainRenderable?.thumbnailURL {
                imageView.alpha = 0
                imageView.loadImage(from: url) { [weak self] image in
                    guard let self, let image else { return }
                    self.imageView.image = image
                    UIView.animate(withDuration: 0.25) {
                        self.imageView.alpha = 1
                    }
                }
            } else {
                imageView.image = UIImage(named: "placeholder")
            }
        }
    }
}
