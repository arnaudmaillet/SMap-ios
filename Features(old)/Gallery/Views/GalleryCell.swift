//
//  GalleryCell.swift
//  SocialMap
//
//  Created by Arnaud Maillet on 21/06/2025.
//

import UIKit

final class GalleryCell: UICollectionViewCell {
    var mediaView = MediaContainerView()
    private var videoId: String?
    private weak var coordinator: FeedCoordinatorDelegate?
    var isLarge = false
    
    var isFullyVisibleOnScreen: Bool {
        guard let window = window else { return false }
        let visibleFrame = convert(bounds, to: window)
        let screenBounds = UIScreen.main.bounds
        return screenBounds.contains(visibleFrame)
    }

    var isReadyForPlayback: Bool {
        return isFullyVisibleOnScreen && mediaView.currentMedia != nil
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.clipsToBounds = true
        mediaView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(mediaView)
        NSLayoutConstraint.activate([
            mediaView.topAnchor.constraint(equalTo: contentView.topAnchor),
            mediaView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            mediaView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            mediaView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor)
        ])
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        mediaView.prepareForReuse()
        isLarge = false
        layer.borderColor = nil
        layer.borderWidth = 0
    }

    required init?(coder: NSCoder) { fatalError() }

    func configure(with media: MediaContent) {
        mediaView.display(media: media)
    }

    func applyCornerRadius(_ radius: CGFloat) {
        contentView.layer.cornerRadius = radius
        mediaView.layer.cornerRadius = radius
        mediaView.layer.masksToBounds = true
    }
    
    func showThumbnail() {
        mediaView.hideVideoPlayer()
    }
    
    func attachMediaView(_ newMediaView: MediaContainerView) {
        mediaView.removeFromSuperview()
        mediaView = newMediaView
        mediaView.frame = contentView.bounds
        contentView.addSubview(mediaView)
    }
}
