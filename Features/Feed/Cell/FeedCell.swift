//
//  FeedCell.swift
//  SocialMap
//
//  Created by Arnaud Maillet on 19/04/2025.
//


import UIKit

final class FeedCell: UICollectionViewCell {

    let imageView = UIImageView()
    let overlayVC = OverlayViewController()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }

    required init?(coder: NSCoder) { fatalError() }

    private func setupViews() {
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(imageView)

        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            imageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            imageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor)
        ])
    }
    
    func setupOverlayView(in parent: FeedViewController) {
        parent.injectOverlayController(overlayVC, into: contentView)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        imageView.frame = contentView.bounds
        overlayVC.view.frame = contentView.bounds
    }

    func configure(with post: Post.Model, safeAreaInsets: UIEdgeInsets) {
        if let renderable = post.mainRenderable {
            imageView.loadImage(from: renderable.thumbnailURL)
        }
        overlayVC.configure(with: post, safeAreaInsets: safeAreaInsets)
    }

    func applyCornerRadius(_ radius: CGFloat) {
        imageView.layer.cornerRadius = radius
        imageView.clipsToBounds = true
    }
}
