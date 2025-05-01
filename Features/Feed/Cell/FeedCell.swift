//
//  FeedCell.swift
//  SocialMap
//
//  Created by Arnaud Maillet on 19/04/2025.
//


import UIKit

final class FeedCell: UICollectionViewCell {

    let imageView = UIImageView()
    let overlayView = PostOverlayView()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }

    required init?(coder: NSCoder) { fatalError() }

    private func setupViews() {
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        contentView.addSubview(imageView)
        contentView.addSubview(overlayView)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        imageView.frame = contentView.bounds
        overlayView.frame = contentView.bounds
    }

    func configure(with post: Post.Model, safeAreaInsets: UIEdgeInsets) {
        if let renderable = post.mainRenderable {
            imageView.loadImage(from: renderable.thumbnailURL)
        }
        overlayView.configure(with: post, safeAreaInsets: safeAreaInsets)
    }
}
