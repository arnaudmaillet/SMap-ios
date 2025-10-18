//
//  FeedOverlayReactions.swift
//  SocialMap
//
//  Created by Arnaud Maillet on 11/10/2025.
//

import UIKit


extension FeedFeature.UI.View {
    final class ReactionView: UIView, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
        typealias UIConstants = FeedFeature.Support.Constants.UI
        
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
        private let reactionsContainer = UIView()
        private let _collectionView: UICollectionView
        private var collectionViewHeightConstraint: NSLayoutConstraint?
        private var boundsObservation: NSKeyValueObservation?
        
        private var reactions: [Reaction] = []
        private var fakeTopCells: Int = 0
        
        private let mainContainer = UIView()
        
        // MARK: - Init
        
        override init(frame: CGRect) {
            self._collectionView = UICollectionView(frame: .zero, collectionViewLayout: Self.makeLayout())
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
            CGSize(width: UIConstants.ReactionsView.width, height: UIView.noIntrinsicMetric)
        }
        
        deinit {
            boundsObservation?.invalidate()
        }
        
        // MARK: - Setup
        
        private func setupViews() {
            clipsToBounds = false
            mainContainer.translatesAutoresizingMaskIntoConstraints = false
            addSubview(mainContainer)
            
            // --- Reactions Collection View ---
            reactionsContainer.translatesAutoresizingMaskIntoConstraints = false
            reactionsContainer.clipsToBounds = false
            mainContainer.addSubview(reactionsContainer)
            
            _collectionView.backgroundColor = .clear
            _collectionView.clipsToBounds = false
            _collectionView.showsVerticalScrollIndicator = false
            _collectionView.translatesAutoresizingMaskIntoConstraints = false
            _collectionView.delegate = self
            _collectionView.dataSource = self
            _collectionView.register(ReactionCell.self, forCellWithReuseIdentifier: ReactionCell.reuseIdentifier)
            _collectionView.register(AddReactionFooterView.self,
                                     forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter,
                                     withReuseIdentifier: AddReactionFooterView.reuseIdentifier)
            
            reactionsContainer.addSubview(_collectionView)
            collectionViewHeightConstraint = _collectionView.heightAnchor.constraint(equalToConstant: 0)
            collectionViewHeightConstraint?.isActive = true
            
            mainContainer.addSubview(reactionsContainer)
        }
        
        private func setupConstraints() {
            NSLayoutConstraint.activate([
                
                // _collectionView a l'interieur de reactionsContainer
                _collectionView.leadingAnchor.constraint(equalTo: reactionsContainer.leadingAnchor),
                _collectionView.trailingAnchor.constraint(equalTo: reactionsContainer.trailingAnchor),
                _collectionView.bottomAnchor.constraint(equalTo: reactionsContainer.bottomAnchor),
                
                // reactionsContainer prend le reste, ancré en haut, et descend jusqu'au viewsButton
                reactionsContainer.leadingAnchor.constraint(equalTo: mainContainer.leadingAnchor),
                reactionsContainer.trailingAnchor.constraint(equalTo: mainContainer.trailingAnchor),
                reactionsContainer.topAnchor.constraint(equalTo: mainContainer.topAnchor),
                reactionsContainer.bottomAnchor.constraint(equalTo: mainContainer.bottomAnchor),
                
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
                    section.boundarySupplementaryItems = [footer]
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
            let newFake = max(maxCells - Self.numberOfCellVisibleByDefault, 0)
            if newFake != fakeTopCells {
                fakeTopCells = newFake
                _collectionView.reloadData()
            }
        }
        
        func animateAppearance(visible: Bool) {
            let baseDelay: TimeInterval = 0.025

            let footer = _collectionView.supplementaryView(
                forElementKind: UICollectionView.elementKindSectionFooter,
                at: IndexPath(item: 0, section: Section.reactions.rawValue)
            )

            // 2️⃣ — Cellules visibles de la section .reactions (triées du haut vers le bas)
            let reactionCells = _collectionView.visibleCells
                .compactMap { cell -> (cell: UICollectionViewCell, indexPath: IndexPath)? in
                    guard let indexPath = _collectionView.indexPath(for: cell),
                          indexPath.section == Section.reactions.rawValue else { return nil }
                    return (cell, indexPath)
                }
                .sorted {
                    let y1 = _collectionView.convert($0.cell.frame, to: self).origin.y
                    let y2 = _collectionView.convert($1.cell.frame, to: self).origin.y
                    return y1 < y2
                }

            // --- Fonction d’animation
            func animate(_ view: UIView?, delay: TimeInterval) {
                guard let view = view else { return }

                if visible {
                    view.alpha = 0
                    view.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
                }

                UIView.animate(
                    withDuration: 0.45,
                    delay: delay,
                    usingSpringWithDamping: 0.65,
                    initialSpringVelocity: 0.7,
                    options: [.beginFromCurrentState, .curveEaseOut],
                    animations: {
                        view.alpha = visible ? 1.0 : 0.0
                        view.transform = visible ? .identity : CGAffineTransform(scaleX: 0.85, y: 0.85)
                    }
                )
            }

            // 3️⃣ — Orchestration inversée : du bas vers le haut
            if visible {
                // Footer → Cell 1 → Cell 0 → Header
                animate(footer, delay: 0.0)

                for (i, pair) in reactionCells.prefix(3).reversed().enumerated() {
                    let delay = 0.1 + baseDelay * Double(i)
                    animate(pair.cell, delay: delay)
                }
            } else {
                // Disparition : tout s’efface sans ordre spécifique (même logique)
                animate(footer, delay: 0.0)
                for (i, pair) in reactionCells.prefix(3).reversed().enumerated() {
                    animate(pair.cell, delay: baseDelay * Double(i))
                }
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
    
    final class AddReactionFooterView: UICollectionReusableView {
        typealias UIConstants = FeedFeature.Support.Constants.UI
        
        static let reuseIdentifier = "AddReactionFooterView"
        
        let addButton = UIButton()
        
        override init(frame: CGRect) {
            super.init(frame: frame)
            setup()
        }
        required init?(coder: NSCoder) { fatalError() }
        
        private func setup() {

            var config: UIButton.Configuration
            
            if #available(iOS 26.0, *) {
                config = UIButton.Configuration.glass()
            } else {
                config = UIButton.Configuration.filled()
            }
            
            config.image = UIImage(systemName: "chevron.up")
            config.baseForegroundColor = .white
            config.cornerStyle = .capsule
            config.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0)

            addButton.configuration = config
            addButton.translatesAutoresizingMaskIntoConstraints = false
            
            addSubview(addButton)
            NSLayoutConstraint.activate([
                addButton.centerXAnchor.constraint(equalTo: centerXAnchor),
                addButton.centerYAnchor.constraint(equalTo: centerYAnchor),
                addButton.widthAnchor.constraint(equalToConstant: UIConstants.Button.size),
                addButton.heightAnchor.constraint(equalToConstant: UIConstants.Button.size)
            ])
            clipsToBounds = false
        }
    }
}
