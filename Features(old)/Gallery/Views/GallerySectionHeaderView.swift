//
//  GallerySectionHeaderView.swift
//  SocialMap
//
//  Created by Arnaud Maillet on 21/06/2025.
//

import UIKit

final class GallerySectionHeaderView: UICollectionReusableView {
    static let reuseIdentifier = "GallerySectionHeaderView"
    let label = UILabel()

    override init(frame: CGRect) {
        super.init(frame: frame)
        label.font = .boldSystemFont(ofSize: 18)
        label.textColor = .label
        label.translatesAutoresizingMaskIntoConstraints = false
        addSubview(label)
        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            label.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -4),
            label.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            label.topAnchor.constraint(equalTo: topAnchor, constant: 0)
        ])
    }
    required init?(coder: NSCoder) { fatalError() }
}
