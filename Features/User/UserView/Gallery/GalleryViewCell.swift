//
//  GalleryPageCellView.swift
//  SocialMap
//
//  Created by Arnaud Maillet on 03/08/2025.
//

import UIKit

extension Gallery.ViewCell {
    static let reuseIdentifier = "Gallery.ViewCell"
}

extension Gallery {
    final class ViewCell: UICollectionViewCell {
        override init(frame: CGRect) {
            super.init(frame: frame)
            backgroundColor = .red
            clipsToBounds = true
            layer.cornerRadius = 8
        }
        required init?(coder: NSCoder) { fatalError() }
    }
}
