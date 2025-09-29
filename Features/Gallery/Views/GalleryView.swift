//
//  GalleryView.swift
//  SocialMap
//
//  Created by Arnaud Maillet on 21/06/2025.
//

import UIKit

// MARK: - Main GalleryView

final class GalleryView: UIView {

    let collectionView: UICollectionView
    private let blurView: UIVisualEffectView
    let headerView = GalleryHeaderView()

    override init(frame: CGRect) {
        // Layout collection (ne sert que pour initialisation, remplacé par compositional layout après)
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.showsVerticalScrollIndicator = false
        collectionView.backgroundColor = .clear

        // Blur effect background
        let blurEffect = UIBlurEffect(style: .systemMaterial)
        blurView = UIVisualEffectView(effect: blurEffect)
        blurView.translatesAutoresizingMaskIntoConstraints = false

        super.init(frame: frame)

        addSubview(blurView)
        addSubview(collectionView)
        addSubview(headerView)
        
        // Blur in background
        NSLayoutConstraint.activate([
            blurView.topAnchor.constraint(equalTo: topAnchor),
            blurView.bottomAnchor.constraint(equalTo: bottomAnchor),
            blurView.leadingAnchor.constraint(equalTo: leadingAnchor),
            blurView.trailingAnchor.constraint(equalTo: trailingAnchor),
        ])

        // Header
        NSLayoutConstraint.activate([
            headerView.topAnchor.constraint(equalTo: topAnchor),
            headerView.leadingAnchor.constraint(equalTo: leadingAnchor),
            headerView.trailingAnchor.constraint(equalTo: trailingAnchor),
            // Hauteur intrinsèque grâce au bouton + padding
        ])

        // Collection view (sous le header)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: topAnchor),
            collectionView.bottomAnchor.constraint(equalTo: bottomAnchor),
            collectionView.leadingAnchor.constraint(equalTo: leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: trailingAnchor),
        ])

        layer.cornerRadius = UIConstant.device.cornerRadius
        layer.masksToBounds = true
    }

    // Permet de mettre à jour le padding du header depuis le controller
    var customSafeAreaTop: CGFloat = 0 {
        didSet { headerView.topPadding = customSafeAreaTop }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
