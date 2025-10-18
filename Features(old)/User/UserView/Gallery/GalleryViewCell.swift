//
//  GalleryViewCell.swift
//  SocialMap
//
//  Created by Arnaud Maillet on 03/08/2025.
//

import UIKit

extension Gallery.ViewCell {
    static let reuseIdentifier = "Gallery.ViewCell"
}

protocol SectionCellUpdater: AnyObject {
    func updateItem(media: MediaContent, with post: Post.Model)
}

extension Gallery {
    final class ViewCell: UICollectionViewCell {
        var mediaView: MediaContainerView
        var pendingMediaView: MediaContainerView?
        
        var onRequestUpdate: ((Post.Model) -> Void)?
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
            mediaView = MediaContainerView()
            
            super.init(frame: frame)
            clipsToBounds = true
            layer.cornerRadius = 8
            contentView.addSubview(mediaView)
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
        
        override func layoutSubviews() {
            super.layoutSubviews()
            mediaView.frame = contentView.bounds
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
            contentView.addSubview(mediaView)
            mediaView.frame = contentView.bounds
        }
    }
}
