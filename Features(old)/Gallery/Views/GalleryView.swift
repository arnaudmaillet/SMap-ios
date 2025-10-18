//
//  GalleryView.swift
//  SocialMap
//
//  Created by Arnaud Maillet on 21/06/2025.
//

import UIKit

// MARK: - Main GalleryView

final class GalleryView: UIView {

    private let _collectionView: UICollectionView
    private let blurView: UIVisualEffectView
    let headerView = HeaderGalleryView()

    override init(frame: CGRect) {
        // Layout collection (ne sert que pour initialisation, remplacé par compositional layout après)
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        _collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        _collectionView.showsVerticalScrollIndicator = false
        _collectionView.backgroundColor = .clear

        // Blur effect background
        let blurEffect = UIBlurEffect(style: .systemMaterial)
        blurView = UIVisualEffectView(effect: blurEffect)
        blurView.translatesAutoresizingMaskIntoConstraints = false

        super.init(frame: frame)

        addSubview(blurView)
        addSubview(_collectionView)
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
        _collectionView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            _collectionView.topAnchor.constraint(equalTo: topAnchor),
            _collectionView.bottomAnchor.constraint(equalTo: bottomAnchor),
            _collectionView.leadingAnchor.constraint(equalTo: leadingAnchor),
            _collectionView.trailingAnchor.constraint(equalTo: trailingAnchor),
        ])

        layer.cornerRadius = UIConstant.device.cornerRadius
        layer.masksToBounds = true
    }
    
    var collectionView: UICollectionView { _collectionView }

    var customSafeArea: UIEdgeInsets = UIEdgeInsets() {
        didSet { headerView.topPadding = customSafeArea.top }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
