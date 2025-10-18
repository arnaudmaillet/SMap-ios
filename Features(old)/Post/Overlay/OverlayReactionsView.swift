//
//  OverlayReactionsView.swift
//  SocialMap
//
//  Created by Arnaud Maillet on 30/04/2025.
//

import UIKit

final class OverlayReactionsView: UIView, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    // MARK: - Model
    struct Reaction {
        let iconName: String
        let count: String
        let iconColor: UIColor?

        init(iconName: String, count: String, iconColor: UIColor? = nil) {
            self.iconName = iconName
            self.count = count
            self.iconColor = iconColor
        }
    }
    
    private enum Section: Int, CaseIterable {
        case fake
        case reactions
    }
    
    // MARK: - Constants
    private static let cellHeight: CGFloat = 56
    private static let cellSpacing: CGFloat = 0
    private static let numberOfCellVisibleByDefault: Int = 4

    // MARK: - UI Components
    private let shareButton = makeStaticButton(iconName: "arrowshape.turn.up.forward.fill")
    private let viewsButton = makeStaticButton(iconName: "arrow.2.squarepath", count: "2.3k")
    private let reactionsContainer = UIView()
    private let _collectionView: UICollectionView
    private var collectionViewHeightConstraint: NSLayoutConstraint?
    private var boundsObservation: NSKeyValueObservation?

    private var reactions: [Reaction] = []
    private var fakeTopCells: Int = 0
    
    private let mainContainer = UIView()

    // MARK: - Init

    override init(frame: CGRect) {
        self._collectionView = UICollectionView(frame: .zero, collectionViewLayout: OverlayReactionsView.makeLayout())
        super.init(frame: frame)
        setupViews()
        setupConstraints()
    }

    required init?(coder: NSCoder) { fatalError() }

    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        boundsObservation = reactionsContainer.observe(\.bounds, options: [.new]) { [weak self] container, change in
            guard let self = self else { return }
            self.updateFakeTopCells()
            self.adjustCollectionViewHeightToMultiple()
            self._collectionView.reloadData()
        }
    }
    
    override var intrinsicContentSize: CGSize {
        CGSize(width: 56, height: UIView.noIntrinsicMetric)
    }
    
    deinit {
        boundsObservation?.invalidate()
    }
    
    // MARK: - Setup

    private func setupViews() {
        mainContainer.translatesAutoresizingMaskIntoConstraints = false
        addSubview(mainContainer)
        
        // --- Reactions Collection View ---
        reactionsContainer.translatesAutoresizingMaskIntoConstraints = false
        reactionsContainer.clipsToBounds = true
        mainContainer.addSubview(reactionsContainer)

        _collectionView.backgroundColor = .clear
        _collectionView.showsVerticalScrollIndicator = false
        _collectionView.translatesAutoresizingMaskIntoConstraints = false
        _collectionView.delegate = self
        _collectionView.dataSource = self
        _collectionView.register(ReactionCell.self, forCellWithReuseIdentifier: ReactionCell.reuseIdentifier)
        _collectionView.register(AddReactionFooterView.self,
                                forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter,
                                withReuseIdentifier: AddReactionFooterView.reuseIdentifier)
        _collectionView.register(
            ReactionSectionHeaderView.self,
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: ReactionSectionHeaderView.reuseIdentifier
        )

        reactionsContainer.addSubview(_collectionView)
        collectionViewHeightConstraint = _collectionView.heightAnchor.constraint(equalToConstant: 0)
        collectionViewHeightConstraint?.isActive = true
        
        // --- Placement des boutons et container (de bas en haut) ---
        mainContainer.addSubview(shareButton)
        mainContainer.addSubview(viewsButton)
        mainContainer.addSubview(reactionsContainer)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            // shareButton ancré en bas
            shareButton.leadingAnchor.constraint(equalTo: mainContainer.leadingAnchor),
            shareButton.trailingAnchor.constraint(equalTo: mainContainer.trailingAnchor),
            shareButton.bottomAnchor.constraint(equalTo: mainContainer.bottomAnchor),
            
            // viewsButton au-dessus du shareButton
            viewsButton.leadingAnchor.constraint(equalTo: mainContainer.leadingAnchor),
            viewsButton.trailingAnchor.constraint(equalTo: mainContainer.trailingAnchor),
            viewsButton.bottomAnchor.constraint(equalTo: shareButton.topAnchor, constant: -16),
            
            // _collectionView a l'interieur de reactionsContainer
            _collectionView.leadingAnchor.constraint(equalTo: reactionsContainer.leadingAnchor),
            _collectionView.trailingAnchor.constraint(equalTo: reactionsContainer.trailingAnchor),
            _collectionView.bottomAnchor.constraint(equalTo: reactionsContainer.bottomAnchor),
            
            // reactionsContainer prend le reste, ancré en haut, et descend jusqu'au viewsButton
            reactionsContainer.leadingAnchor.constraint(equalTo: mainContainer.leadingAnchor),
            reactionsContainer.trailingAnchor.constraint(equalTo: mainContainer.trailingAnchor),
            reactionsContainer.topAnchor.constraint(equalTo: mainContainer.topAnchor),
            reactionsContainer.bottomAnchor.constraint(equalTo: viewsButton.topAnchor, constant: -16),
            
            // main container
            mainContainer.topAnchor.constraint(equalTo: topAnchor),
            mainContainer.bottomAnchor.constraint(equalTo: bottomAnchor),
            mainContainer.leadingAnchor.constraint(equalTo: leadingAnchor),
            mainContainer.trailingAnchor.constraint(equalTo: trailingAnchor)
        ])
    }

    // MARK: - Layout
    
    private func adjustCollectionViewHeightToMultiple() {
        let availableHeight = reactionsContainer.bounds.height
        let cellHeight = Self.cellHeight
        let cellSpacing = Self.cellSpacing

        let maxCells = max(1, Int(floor((availableHeight + cellSpacing) / (cellHeight + cellSpacing))))
        let visibleCells = min(maxCells, reactions.count)
        let totalHeight = CGFloat(visibleCells) * cellHeight + CGFloat(max(0, visibleCells - 1)) * cellSpacing

        collectionViewHeightConstraint?.constant = totalHeight
        _collectionView.isScrollEnabled = (reactions.count > visibleCells)
    }

    private static func makeLayout() -> UICollectionViewLayout {
        let layout = UICollectionViewCompositionalLayout { sectionIndex, env in
            guard let section = Section(rawValue: sectionIndex) else { return nil }

            let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(cellHeight))
            let item = NSCollectionLayoutItem(layoutSize: itemSize)

            let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(400))
            let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitems: [item])

            switch section {
            case .fake:
                let fakeSection = NSCollectionLayoutSection(group: group)
                fakeSection.interGroupSpacing = cellSpacing
                fakeSection.contentInsets = .zero
                return fakeSection
            case .reactions:
                // Header pour l’icône/titre
                let headerSize = NSCollectionLayoutSize(
                    widthDimension: .fractionalWidth(1.0),
                    heightDimension: .absolute(OverlayReactionsView.cellHeight)
                )
                let header = NSCollectionLayoutBoundarySupplementaryItem(
                    layoutSize: headerSize,
                    elementKind: UICollectionView.elementKindSectionHeader,
                    alignment: .top
                )
                header.pinToVisibleBounds = true

                // Footer (add reaction)
                let footerSize = NSCollectionLayoutSize(
                    widthDimension: .fractionalWidth(1.0),
                    heightDimension: .absolute(56)
                )
                let footer = NSCollectionLayoutBoundarySupplementaryItem(
                    layoutSize: footerSize,
                    elementKind: UICollectionView.elementKindSectionFooter,
                    alignment: .bottom
                )
                footer.pinToVisibleBounds = true

                let section = NSCollectionLayoutSection(group: group)
                section.boundarySupplementaryItems = [header, footer]
                section.interGroupSpacing = cellSpacing
                section.contentInsets = .zero
                // --- Handler pour edge scale/fade ---
                section.visibleItemsInvalidationHandler = { visibleItems, contentOffset, env in
                    let topEdge = contentOffset.y
                    let bottomEdge = contentOffset.y + env.container.contentSize.height

                    for item in visibleItems where item.representedElementCategory == .cell {
                        let distanceToTop = item.frame.minY - topEdge
                        let distanceToBottom = bottomEdge - item.frame.maxY

                        // --- FADE EN HAUT ---
                        if distanceToTop < cellHeight {
                            let ratio = max(distanceToTop / cellHeight, 0)
                            item.alpha = ratio
                            item.transform = .identity
                        }
                        // --- SCALE + FADE EN BAS ---
                        else if distanceToBottom < cellHeight {
                            let ratio = max(distanceToBottom / cellHeight, 0)
                            item.alpha = ratio         // Alpha 0 → 1
                            item.transform = CGAffineTransform(scaleX: ratio, y: ratio)
                        }
                        // --- NORMAL ---
                        else {
                            item.alpha = 1
                            item.transform = .identity
                        }
                    }
                }
                return section
            }
        }
        return layout
    }
    

    private func updateFakeTopCells() {
        let availableHeight = reactionsContainer.bounds.height
        let cellHeight = Self.cellHeight
        let cellSpacing = Self.cellSpacing
        let maxCells = max(1, Int(floor((availableHeight + cellSpacing) / (cellHeight + cellSpacing))))
        let newFake = max(maxCells - OverlayReactionsView.numberOfCellVisibleByDefault, 0)
        if newFake != fakeTopCells {
            fakeTopCells = newFake
            _collectionView.reloadData()
        }
    }

    // MARK: - DataSource

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        Section.allCases.count
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch Section(rawValue: section)! {
        case .fake:
            return fakeTopCells
        case .reactions:
            return reactions.count
        }
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        switch Section(rawValue: indexPath.section)! {
        case .fake:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ReactionCell.reuseIdentifier, for: indexPath)
            cell.contentView.backgroundColor = .clear
            cell.isUserInteractionEnabled = false
            cell.contentView.subviews.forEach { $0.isHidden = true }
            return cell
        case .reactions:
            let item = reactions[indexPath.item]
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ReactionCell.reuseIdentifier, for: indexPath) as! ReactionCell
            let icon = UIImage(systemName: item.iconName)
            cell.configure(icon: icon, count: item.count)
            cell.contentView.subviews.forEach { $0.isHidden = false }
            return cell
        }
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        onReactionTap?(indexPath.item)
    }

    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if kind == UICollectionView.elementKindSectionHeader,
           Section(rawValue: indexPath.section) == .reactions {
            let header = collectionView.dequeueReusableSupplementaryView(
                ofKind: kind,
                withReuseIdentifier: ReactionSectionHeaderView.reuseIdentifier,
                for: indexPath
            ) as! ReactionSectionHeaderView
            // Configure avec les bons paramètres
            header.configure(icon: UIImage(systemName: "eye.fill"), count: "1,2M", iconColor: .systemYellow)
            return header
        }
        
        if kind == UICollectionView.elementKindSectionFooter {
            let footer = collectionView.dequeueReusableSupplementaryView(
                ofKind: kind,
                withReuseIdentifier: AddReactionFooterView.reuseIdentifier,
                for: indexPath) as! AddReactionFooterView
            footer.addButton.addTarget(self, action: #selector(handleAddReaction), for: .touchUpInside)
            return footer
        }
        return UICollectionReusableView()
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        referenceSizeForFooterInSection section: Int) -> CGSize {
        return CGSize(width: collectionView.bounds.width, height: 56)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offsetY = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height
        let frameHeight = scrollView.bounds.height

        let pullDistance = offsetY + frameHeight - contentHeight

        if pullDistance > 0 {
            // Récupère le footer
            if let footer = collectionView.supplementaryView(
                forElementKind: UICollectionView.elementKindSectionFooter,
                at: IndexPath(item: 0, section: 0)
            ) as? AddReactionFooterView {
                // Met à jour la hauteur du footer
                var frame = footer.frame
                frame.size.height = 56 + pullDistance
                footer.frame = frame
            }
        }
    }

    func scrollViewWillEndDragging(_ scrollView: UIScrollView,
                                  withVelocity velocity: CGPoint,
                                  targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        let cellHeight = Self.cellHeight
        let cellSpacing = Self.cellSpacing
        let snapUnit = cellHeight + cellSpacing

        let collectionHeight = scrollView.bounds.height
        let targetY = targetContentOffset.pointee.y
        let index = round((targetY + collectionHeight - cellHeight) / snapUnit)
        let newOffset = index * snapUnit - (collectionHeight - cellHeight)
        targetContentOffset.pointee.y = max(0, newOffset)
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        let offsetY = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height
        let frameHeight = scrollView.bounds.height

        let pullDistance = offsetY + frameHeight - contentHeight

        let triggerThreshold: CGFloat = 60
        if pullDistance > triggerThreshold {
            // Déclenche le load more
            print("triggerLoadMore()")
        }
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        CGSize(width: collectionView.bounds.width, height: Self.cellHeight)
    }

    // MARK: - Factory Methods

    private static func makeStaticButton(iconName: String, count: String? = nil, height: CGFloat? = nil) -> UIView {
        guard let image = UIImage(systemName: iconName) else { return UIView() }

        let imageView = UIImageView(image: image)
        imageView.tintColor = .white
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.widthAnchor.constraint(equalToConstant: 32).isActive = true
        imageView.heightAnchor.constraint(equalToConstant: 32).isActive = true

        let stack: UIStackView
        if let count = count {
            let label = UILabel()
            label.text = count
            label.font = .preferredFont(forTextStyle: .caption1)
            
            label.textColor = .white
            label.textAlignment = .center
            stack = UIStackView(arrangedSubviews: [imageView, label])
        } else {
            stack = UIStackView(arrangedSubviews: [imageView])
        }

        stack.axis = .vertical
        stack.alignment = .center
        stack.spacing = 4
        stack.translatesAutoresizingMaskIntoConstraints = false

        let container = UIView()
        container.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(stack)

        NSLayoutConstraint.activate([
            stack.centerXAnchor.constraint(equalTo: container.centerXAnchor)
        ])

        if let height = height {
            container.heightAnchor.constraint(equalToConstant: height).isActive = true
            stack.centerYAnchor.constraint(equalTo: container.centerYAnchor).isActive = true
        } else {
            NSLayoutConstraint.activate([
                stack.topAnchor.constraint(equalTo: container.topAnchor),
                stack.bottomAnchor.constraint(equalTo: container.bottomAnchor)
            ])
        }

        return container
    }
    
    // MARK: - Public API
    
    var collectionView: UICollectionView { _collectionView }
    
    var onReactionTap: ((Int) -> Void)?

    func configure(with reactions: [Reaction]) {
        self.reactions = reactions
        updateFakeTopCells()
        _collectionView.reloadData()
        setNeedsLayout()
    }

    @objc private func handleAddReaction() {
        print("Add reaction tapped!")
    }
}

final class ReactionSectionHeaderView: UICollectionReusableView {
    static let reuseIdentifier = "ReactionSectionHeaderView"
    private let reactionView = ReactionView()

    override init(frame: CGRect) {
        super.init(frame: frame)
        reactionView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(reactionView)
        NSLayoutConstraint.activate([
            reactionView.leadingAnchor.constraint(equalTo: leadingAnchor),
            reactionView.trailingAnchor.constraint(equalTo: trailingAnchor),
            reactionView.topAnchor.constraint(equalTo: topAnchor),
            reactionView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
        clipsToBounds = true
    }
    required init?(coder: NSCoder) { fatalError() }
    func configure(icon: UIImage?, count: String, iconColor: UIColor? = nil) {
        reactionView.configure(icon: icon, count: count, iconColor: iconColor)
    }
}

final class ReactionCell: UICollectionViewCell {
    static let reuseIdentifier = "ReactionCell"
    private let reactionView = ReactionView()

    override init(frame: CGRect) {
        super.init(frame: frame)
        reactionView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(reactionView)
        NSLayoutConstraint.activate([
            reactionView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            reactionView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            reactionView.topAnchor.constraint(equalTo: contentView.topAnchor),
            reactionView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
        contentView.clipsToBounds = true
    }
    required init?(coder: NSCoder) { fatalError() }
    func configure(icon: UIImage?, count: String, iconColor: UIColor? = nil) {
        reactionView.configure(icon: icon, count: count, iconColor: iconColor)
    }
}

final class ReactionView: UIView {
    let iconView = UIImageView()
    let countLabel = UILabel()
    override init(frame: CGRect) {
        super.init(frame: frame)
        iconView.contentMode = .scaleAspectFit
        iconView.tintColor = .white
        iconView.translatesAutoresizingMaskIntoConstraints = false

        countLabel.font = .preferredFont(forTextStyle: .caption1)
        countLabel.numberOfLines = 1
        countLabel.textColor = .white
        countLabel.textAlignment = .center
        countLabel.translatesAutoresizingMaskIntoConstraints = false

        let stack = UIStackView(arrangedSubviews: [iconView, countLabel])
        stack.axis = .vertical
        stack.alignment = .center
        stack.spacing = 4
        stack.translatesAutoresizingMaskIntoConstraints = false

        addSubview(stack)
        NSLayoutConstraint.activate([
            iconView.widthAnchor.constraint(equalToConstant: 28),
            iconView.heightAnchor.constraint(equalToConstant: 28),
            stack.centerXAnchor.constraint(equalTo: centerXAnchor),
            stack.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
        clipsToBounds = true
    }

    required init?(coder: NSCoder) { fatalError() }

    func configure(icon: UIImage?, count: String, iconColor: UIColor? = nil) {
        iconView.image = icon
        iconView.tintColor = iconColor ?? .white
        countLabel.text = count
    }
}

final class AddReactionFooterView: UICollectionReusableView {
    static let reuseIdentifier = "AddReactionFooterView"
    
    let addButton = UIButton(type: .system)
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    required init?(coder: NSCoder) { fatalError() }
    
    private func setup() {
        addButton.setImage(UIImage(systemName: "plus"), for: .normal)
        addButton.tintColor = .white
        addButton.backgroundColor = UIColor.accent
        addButton.layer.cornerRadius = 16
        addButton.translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(addButton)
        NSLayoutConstraint.activate([
            addButton.centerXAnchor.constraint(equalTo: centerXAnchor),
            addButton.centerYAnchor.constraint(equalTo: centerYAnchor),
            addButton.widthAnchor.constraint(equalToConstant: 32),
            addButton.heightAnchor.constraint(equalToConstant: 32)
        ])
    }
}
