//
//  PostPreviewView.swift
//  SocialMap
//
//  Created by Arnaud Maillet on 21/04/2025.
//

import UIKit
import AVFoundation

final class PostPreviewView: UIView {
    let imageView = UIImageView()
    private let playIconView = UIImageView()
    private let aspectRatio: CGSize = CGSize(width: 9, height: 16)

    private(set) var isDisplayingVideo: Bool = false

    init(size: CGFloat = 72) {
        let defaultSize = CGSize(width: size, height: size)
        super.init(frame: CGRect(origin: .zero, size: defaultSize))

        backgroundColor = .black
        layer.cornerRadius = 16 + size.remainderAfterPowerOfTwo
        layer.borderWidth = 3
        layer.borderColor = UIColor.accent.cgColor
        clipsToBounds = true

        setupImageView()
        setupPlayIcon()
    }

    required init?(coder: NSCoder) {
        fatalError()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        imageView.frame = bounds
        playIconView.center = CGPoint(x: bounds.midX, y: bounds.midY)
    }

    private func setupImageView() {
        imageView.contentMode = .scaleAspectFill
        imageView.backgroundColor = .black
        imageView.clipsToBounds = true
        imageView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        imageView.frame = bounds
        addSubview(imageView)
    }

    private func setupPlayIcon() {
        let iconSize: CGFloat = 24
        playIconView.image = UIImage(systemName: "play.circle.fill")
        playIconView.tintColor = .white
        playIconView.alpha = 0.85
        playIconView.frame.size = CGSize(width: iconSize, height: iconSize)
        addSubview(playIconView)
    }

    func configure(with post: Post, size: CGFloat) {
        isDisplayingVideo = post.mainRenderable?.isVideo ?? false
        playIconView.isHidden = !isDisplayingVideo
        
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

        if let url = post.mainRenderable?.thumbnailURL {
            imageView.loadImage(from: url) { [weak self] image in
                guard let self, let image else { return }
                let cropped = image.croppedToAspectRatio(size: postSize)
                self.imageView.image = cropped
            }
        }
    }
}
