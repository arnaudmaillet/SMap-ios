//
//  HomeActionButtonRowCell.swift
//  SocialMap
//
//  Created by Arnaud Maillet on 22/06/2025.
//

import UIKit

final class HomeActionButtonRowCell: UICollectionViewCell {
    static let reuseIdentifier = "HomeActionButtonRowCell"
    private var actions: [HomeActionButtonModel] = []
    private var activeIndex: Int = 0
    private var onTap: ((Int) -> Void)?
    
    private var usesSmallCell: Bool = false

    private lazy var horizontalCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumInteritemSpacing = 12
        layout.sectionInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        layout.estimatedItemSize = UICollectionViewFlowLayout.automaticSize
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.translatesAutoresizingMaskIntoConstraints = false
        cv.backgroundColor = .clear
        cv.showsHorizontalScrollIndicator = false
        cv.dataSource = self
        cv.delegate = self
        cv.register(HomeActionButtonCell.self, forCellWithReuseIdentifier: HomeActionButtonCell.reuseIdentifier)
        cv.register(HomeSmallActionButtonCell.self, forCellWithReuseIdentifier: HomeSmallActionButtonCell.reuseIdentifier)
        return cv
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(horizontalCollectionView)
        NSLayoutConstraint.activate([
            horizontalCollectionView.topAnchor.constraint(equalTo: contentView.topAnchor),
            horizontalCollectionView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            horizontalCollectionView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            horizontalCollectionView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
        ])
    }
    required init?(coder: NSCoder) { fatalError() }

    func configure(with actions: [HomeActionButtonModel], activeIndex: Int, usesSmallCell: Bool = false, onTap: @escaping (Int) -> Void) {
        self.actions = actions
        self.activeIndex = activeIndex
        self.usesSmallCell = usesSmallCell
        self.onTap = onTap
        horizontalCollectionView.reloadData()
    }
    
    func setActiveIndex(_ newIndex: Int) {
        guard newIndex != activeIndex else { return }
        let oldIndex = activeIndex
        activeIndex = newIndex
        // Désactive l'ancien
        if usesSmallCell {
            if let oldCell = horizontalCollectionView.cellForItem(at: IndexPath(item: oldIndex, section: 0)) as? HomeSmallActionButtonCell {
                oldCell.setActive(false)
            }
            if let newCell = horizontalCollectionView.cellForItem(at: IndexPath(item: newIndex, section: 0)) as? HomeSmallActionButtonCell {
                newCell.setActive(true)
            }
        } else {
            if let oldCell = horizontalCollectionView.cellForItem(at: IndexPath(item: oldIndex, section: 0)) as? HomeActionButtonCell {
                oldCell.setActive(false)
            }
            if let newCell = horizontalCollectionView.cellForItem(at: IndexPath(item: newIndex, section: 0)) as? HomeActionButtonCell {
                newCell.setActive(true)
            }
        }
        scrollToMakeVisible(index: newIndex)
    }

    private func scrollToMakeVisible(index: Int) {
        guard let layout = horizontalCollectionView.collectionViewLayout as? UICollectionViewFlowLayout,
              let attributes = layout.layoutAttributesForItem(at: IndexPath(item: index, section: 0)) else { return }
        
        let sectionInsetLeft = layout.sectionInset.left
        let sectionInsetRight = layout.sectionInset.right
        let cellFrame = attributes.frame
        let margin: CGFloat = sectionInsetLeft
        
        let visibleMinX = horizontalCollectionView.contentOffset.x + sectionInsetLeft
        let visibleMaxX = horizontalCollectionView.contentOffset.x + horizontalCollectionView.bounds.width - sectionInsetRight
        
        let cellMinX = cellFrame.minX
        let cellMaxX = cellFrame.maxX

        // Déjà totalement visible ? On ne fait rien.
        let isFullyVisible = cellMinX >= visibleMinX && cellMaxX <= visibleMaxX
        guard !isFullyVisible else { return }

        var targetOffsetX = horizontalCollectionView.contentOffset.x

        if cellMinX < visibleMinX {
            // Dépasse à gauche : scroll pour aligner à gauche + marge
            targetOffsetX = cellMinX - sectionInsetLeft - margin
        } else if cellMaxX > visibleMaxX {
            // Dépasse à droite : scroll pour aligner à droite + marge
            targetOffsetX = cellMaxX - horizontalCollectionView.bounds.width + sectionInsetRight + margin
        }

        // Clamp l’offset pour ne pas dépasser les bornes du contenu
        let maxOffsetX = horizontalCollectionView.contentSize.width - horizontalCollectionView.bounds.width
        let finalOffsetX = min(max(targetOffsetX, 0), maxOffsetX > 0 ? maxOffsetX : 0)

        horizontalCollectionView.setContentOffset(CGPoint(x: finalOffsetX, y: 0), animated: true)
    }
}

extension HomeActionButtonRowCell: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int { actions.count }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if usesSmallCell {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: HomeSmallActionButtonCell.reuseIdentifier, for: indexPath) as! HomeSmallActionButtonCell
            cell.configure(with: actions[indexPath.item], active: indexPath.item == activeIndex)
            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: HomeActionButtonCell.reuseIdentifier, for: indexPath) as! HomeActionButtonCell
            cell.configure(with: actions[indexPath.item], active: indexPath.item == activeIndex)
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard indexPath.item != activeIndex else { return }
        setActiveIndex(indexPath.item)
        onTap?(indexPath.item)
    }
    
    func scrollViewWillEndDragging(_ scrollView: UIScrollView,
                                   withVelocity velocity: CGPoint,
                                   targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        guard let collectionView = scrollView as? UICollectionView,
              let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout else { return }
        
        // Récupère toutes les cells visibles à la fin du scroll
        let visibleCells = collectionView.visibleCells
        guard !visibleCells.isEmpty else { return }
        
        // On va snapper la cellule la plus proche du bord gauche
        // Calcul de la distance minimale
        let targetX = targetContentOffset.pointee.x + layout.sectionInset.left
        
        // Cherche l'indexPath de la cellule la plus proche du bord gauche
        let visibleLayouts = collectionView.indexPathsForVisibleItems.compactMap { indexPath in
            layout.layoutAttributesForItem(at: indexPath)
        }
        
        guard let closest = visibleLayouts.min(by: { abs($0.frame.minX - targetX) < abs($1.frame.minX - targetX) }) else { return }
        
        // Calcule le nouvel offset pour placer la cellule contre la gauche (en tenant compte du sectionInset)
        let newOffsetX = closest.frame.minX - layout.sectionInset.left
        targetContentOffset.pointee.x = max(0, min(newOffsetX, collectionView.contentSize.width - collectionView.bounds.width))
    }
}

