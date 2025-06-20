//
//  OverlayCommentsView.swift
//  SocialMap
//
//  Created by Arnaud Maillet on 20/05/2025.
//

import UIKit

final class CommentsView: UIView {
    
    // MARK: - Properties
    
    private let _collectionView: UICollectionView
    private var _scrollCoordinator: ScrollCoordinator?
    
    var infoContainerViewToInject: UIView?
    
    // MARK: - Init

    override init(frame: CGRect) {
        self._collectionView = CommentsView.makeCollectionView(contentInsets: .zero)
        super.init(frame: frame)
        setupLayout()
        _collectionView.delegate = self
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    // MARK: - Setup

    private static func makeCollectionView(contentInsets: NSDirectionalEdgeInsets) -> UICollectionView {
        let layout = UICollectionViewCompositionalLayout { _, _ in
            let itemSize = NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1.0),
                heightDimension: .estimated(44)
            )
            let item = NSCollectionLayoutItem(layoutSize: itemSize)
            let groupSize = NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1.0),
                heightDimension: .estimated(44)
            )
            let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitems: [item])
            let section = NSCollectionLayoutSection(group: group)
            section.interGroupSpacing = 0
            section.contentInsets = contentInsets
            return section
        }

        let collection = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collection.translatesAutoresizingMaskIntoConstraints = false
        collection.alwaysBounceVertical = true
        collection.showsVerticalScrollIndicator = false
        collection.contentInset = .zero
        collection.contentInsetAdjustmentBehavior = .never
        collection.backgroundColor = .clear
        collection.register(CommentCell.self, forCellWithReuseIdentifier: "CommentCell")
        return collection
    }

    private func setupLayout() {
        translatesAutoresizingMaskIntoConstraints = false
        addSubview(_collectionView)
        NSLayoutConstraint.activate([
            _collectionView.topAnchor.constraint(equalTo: topAnchor),
            _collectionView.bottomAnchor.constraint(equalTo: bottomAnchor),
            _collectionView.leadingAnchor.constraint(equalTo: leadingAnchor),
            _collectionView.trailingAnchor.constraint(equalTo: trailingAnchor)
        ])
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        guard kind == UICollectionView.elementKindSectionHeader else { fatalError() }
        let header = collectionView.dequeueReusableSupplementaryView(
            ofKind: kind,
            withReuseIdentifier: CommentsHeaderContainerView.reuseIdentifier,
            for: indexPath
        ) as! CommentsHeaderContainerView

        // Retire l'ancien si présent
        header.infoContainerView.subviews.forEach { $0.removeFromSuperview() }
        
        // Ajoute la vraie vue préparée par ton controller parent
        if let infoContainer = infoContainerViewToInject {
            infoContainer.translatesAutoresizingMaskIntoConstraints = false
            header.infoContainerView.addSubview(infoContainer)
            NSLayoutConstraint.activate([
                infoContainer.topAnchor.constraint(equalTo: header.infoContainerView.topAnchor),
                infoContainer.leadingAnchor.constraint(equalTo: header.infoContainerView.leadingAnchor),
                infoContainer.trailingAnchor.constraint(equalTo: header.infoContainerView.trailingAnchor),
                infoContainer.bottomAnchor.constraint(equalTo: header.infoContainerView.bottomAnchor)
            ])
        }
        return header
    }
    
    // MARK: - Public API
    
    var collectionView: UICollectionView { _collectionView }

    var scrollCoordinator: ScrollCoordinator? {
        get { _scrollCoordinator }
        set {
            _scrollCoordinator = newValue
            if let coordinator = newValue {
                coordinator.addScrollView(_collectionView)
            }
        }
    }
    
    func applySafeAreaInsets(_ insets: NSDirectionalEdgeInsets) {
        let newLayout = CommentsView.makeCollectionView(contentInsets: insets).collectionViewLayout
        _collectionView.setCollectionViewLayout(newLayout, animated: false)
    }

    func activateScroll() {
        _scrollCoordinator?.activate(_collectionView)
    }
    func deactivateScroll() {
        _scrollCoordinator?.deactivateAll()
    }
    var isActiveScroll: Bool {
        _scrollCoordinator?.isActive(_collectionView) ?? false
    }
}

extension CommentsView: UICollectionViewDelegate {}

final class CommentsHeaderContainerView: UICollectionReusableView {
    static let reuseIdentifier = "CommentsHeaderContainerView"

    // Ton container avec le fond, coins arrondis etc.
    let infoContainerView = UIView()

    override init(frame: CGRect) {
        super.init(frame: frame)
        infoContainerView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(infoContainerView)
        NSLayoutConstraint.activate([
            infoContainerView.topAnchor.constraint(equalTo: topAnchor),
            infoContainerView.leadingAnchor.constraint(equalTo: leadingAnchor),
            infoContainerView.trailingAnchor.constraint(equalTo: trailingAnchor),
            infoContainerView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
}

final class CommentsHeaderView: UIView {
    // Simple UIView, tu pourras customiser l’apparence si besoin
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .red // ou autre couleur
    }
    required init?(coder: NSCoder) { fatalError() }
}

final class OverlayCommentsView: UIView {

    // MARK: - Subviews
    
    let collectionView: UICollectionView
    private var fadeThresholdLine: UIView?
    // MARK: - Init

    override init(frame: CGRect) {
        // Init de collectionView avant super.init
        self.collectionView = OverlayCommentsView.makeCollectionView()
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    

    // MARK: - Setup

    private static func makeCollectionView() -> UICollectionView {
        let layout = UICollectionViewCompositionalLayout { sectionIndex, layoutEnvironment in
            // Item (cellule)
            let itemSize = NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1.0),
                heightDimension: .estimated(44)
            )
            let item = NSCollectionLayoutItem(layoutSize: itemSize)

            // Group (vertical)
            let groupSize = NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1.0),
                heightDimension: .estimated(44)
            )
            let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitems: [item])

            // Section
            let section = NSCollectionLayoutSection(group: group)
            section.interGroupSpacing = 0
            section.contentInsets = NSDirectionalEdgeInsets(top: 16, leading: 0, bottom: 0, trailing: 0)

            // Header
            let headerSize = NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1.0),
                heightDimension: .estimated(90)
            )
            let header = NSCollectionLayoutBoundarySupplementaryItem(
                layoutSize: headerSize,
                elementKind: UICollectionView.elementKindSectionHeader,
                alignment: .top
            )
            header.pinToVisibleBounds = true
            section.boundarySupplementaryItems = [header]

            return section
        }

        let collection = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collection.translatesAutoresizingMaskIntoConstraints = false
        collection.alwaysBounceVertical = true
        collection.showsVerticalScrollIndicator = false
        collection.backgroundColor = .clear

        // Enregistrement du header
        collection.register(
            OverlayCommentsHeaderView.self,
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: OverlayCommentsHeaderView.reuseIdentifier
        )

        return collection
    }
}


final class CommentCell: UICollectionViewCell {

    private let label = UILabel()

    override init(frame: CGRect) {
        super.init(frame: frame)
        label.textColor = .white
        label.numberOfLines = 0
        label.font = .preferredFont(forTextStyle: .subheadline)
        label.translatesAutoresizingMaskIntoConstraints = false

        contentView.addSubview(label)

        NSLayoutConstraint.activate([
            label.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            label.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),
            label.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            label.trailingAnchor.constraint(equalTo: contentView.trailingAnchor)
        ])
    }

    required init?(coder: NSCoder) {
        fatalError()
    }

    func configure(with text: String) {
        label.text = text
    }
}


final class OverlayCommentsHeaderView: UICollectionReusableView {
    static let reuseIdentifier = "OverlayCommentsHeaderView"

    /// Subviews
    private let descriptionView = OverlayDescriptionView()
    private let musicView = OverlayMusicView()
    private let stackView = UIStackView()

    /// Contraintes pour le resize dynamique de l'image
    private var musicWidthConstraint: NSLayoutConstraint!
    private var musicHeightConstraint: NSLayoutConstraint!

    // MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)

        // StackView vertical pour le header
        stackView.axis = .vertical
        stackView.spacing = 8
        stackView.alignment = .fill
        stackView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(stackView)
        stackView.addArrangedSubview(descriptionView)
        stackView.addArrangedSubview(musicView)

        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: topAnchor, constant: 8),
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: trailingAnchor),
            stackView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -8),
        ])

        // Contraintes dynamiques pour l'image de musique
        let imageView = musicView.musicCoverImageView

        musicView.defaultWidthConstraint.isActive = false
        musicView.defaultHeightConstraint.isActive = false

        musicWidthConstraint = imageView.widthAnchor.constraint(equalToConstant: 32)
        musicHeightConstraint = imageView.heightAnchor.constraint(equalToConstant: 32)
        musicWidthConstraint.isActive = true
        musicHeightConstraint.isActive = true
        imageView.layer.cornerRadius = 16
    }

    required init?(coder: NSCoder) { fatalError() }
    
    // MARK: - Public

    var musicCoverImageView: UIImageView { musicView.musicCoverImageView }
    var artistLabel: UILabel { musicView.artistLabel }
    var artistLabelHeightConstraint: NSLayoutConstraint { musicView.artistLabelHeightConstraint }
    
    func configure(with descriptionSource: OverlayDescriptionView, musicSource: OverlayMusicView) {
        // Copier le contenu des labels/images
        descriptionView.descriptionLabel.text = descriptionSource.descriptionLabel.text
        descriptionView.metaLabel.text = descriptionSource.metaLabel.text

        musicView.musicLabel.text = musicSource.musicLabel.text
        musicView.artistLabel.text = musicSource.artistLabel.text
        musicView.musicCoverImageView.image = musicSource.musicCoverImageView.image
    }

    /// Appelée à chaque scroll pour mettre à jour la taille de l'icône
    func updateMusicImageSize(_ size: CGFloat) {
        musicWidthConstraint.constant = size
        musicHeightConstraint.constant = size
        musicView.musicCoverImageView.layer.cornerRadius = size / 2
        musicView.musicCoverImageView.setNeedsLayout()
        musicView.musicCoverImageView.layoutIfNeeded()
    }
    
    func updateArtistLabelScale(_ scale: CGFloat) {
        let clampedScale = max(0.0, min(1.0, scale))
        let label = musicView.artistLabel
        let labelHeight = musicView.artistLabelHeightConstraint

        // Scale et hauteur
        label.transform = CGAffineTransform(scaleX: clampedScale, y: clampedScale)
        let minHeight: CGFloat = 0
        let maxHeight: CGFloat = 16
        let newHeight = minHeight + (maxHeight - minHeight) * clampedScale
        labelHeight?.constant = newHeight
        label.alpha = clampedScale

        // Retrait propre de la stack
        if clampedScale == 0 {
            if label.superview != nil {
                // Le retire proprement de la stack pour éviter espace ou contraintes bizarres
                if let stack = label.superview as? UIStackView {
                    stack.removeArrangedSubview(label)
                    label.removeFromSuperview()
                }
            }
        } else {
            if label.superview == nil, let stack = musicView.arrangedSubviews.last as? UIStackView {
                stack.addArrangedSubview(label)
            }
            label.isHidden = false
        }
    }
}
