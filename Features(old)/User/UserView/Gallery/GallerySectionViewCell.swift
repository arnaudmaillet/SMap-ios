//
//  GallerySectionViewCell.swift
//  SocialMap
//
//  Created by Arnaud Maillet on 03/08/2025.
//

import UIKit

extension Gallery.SectionViewCell {
    static let reuseIdentifier = "Gallery.SectionViewCell"
}

struct GalleryTapContext {
    let mediaView: MediaContainerView;
    let item: GalleryItem;
    let indexPath: IndexPath;
}

typealias OnGalleryTap = (GalleryTapContext) -> Void

extension Gallery {
    final class SectionViewCell: UICollectionViewCell {
        var gridCollectionView: UICollectionView!
        let layoutPattern: [Bool]
        
        var viewModel: GalleryViewModel!
        var onMediaTapped: OnGalleryTap?
        
        override init(frame: CGRect) {
            layoutPattern = [true, false, false, false, false, true, true, false, false, false, true]
            
            super.init(frame: frame)
            setupGrid()
        }
        
        required init?(coder: NSCoder) { fatalError() }
        
        private func setupGrid() {
            gridCollectionView = UICollectionView(frame: .zero, collectionViewLayout: Self.makeLayout(with: layoutPattern))
            gridCollectionView.isScrollEnabled = false
            gridCollectionView.backgroundColor = .clear
            gridCollectionView.dataSource = self
            gridCollectionView.delegate = self
            gridCollectionView.register(ViewCell.self, forCellWithReuseIdentifier: Gallery.ViewCell.reuseIdentifier)
            
            contentView.addSubview(gridCollectionView)
            gridCollectionView.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                gridCollectionView.topAnchor.constraint(equalTo: contentView.topAnchor),
                gridCollectionView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
                gridCollectionView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
                gridCollectionView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
            ])
        }
        
        static func calculatedContentHeight(for width: CGFloat, itemCount: Int) -> CGFloat {
            let columns: CGFloat = 3
            let spacing: CGFloat = 4
            let horizontalInset: CGFloat = spacing
            let totalSpacing = (columns - 1) * spacing + 2 * horizontalInset
            let cellWidth = (width - totalSpacing) / columns
            let cellHeight = cellWidth
            
            // Frames du pattern
            let pattern: [(x: Int, y: Int, w: Int, h: Int)] = [
                (0,0,1,2), (1,0,1,1), (2,0,1,1),
                (1,1,1,1), (2,1,1,1),
                (0,2,2,1), (2,2,1,2),
                (0,3,1,1), (1,3,1,1),
                (0,4,1,1), (1,4,2,1)
            ]
            
            let itemsPerBlock = pattern.count
            let fullBlocks = itemCount / itemsPerBlock
            let remainder = itemCount % itemsPerBlock
            
            func blockHeight(for count: Int) -> CGFloat {
                guard count > 0 else { return 0 }
                var maxBottom: CGFloat = 0
                for i in 0..<count {
                    let p = pattern[i]
                    let y = CGFloat(p.y) * (cellHeight + spacing)
                    let h = CGFloat(p.h) * cellHeight + CGFloat(p.h - 1) * spacing
                    maxBottom = max(maxBottom, y + h)
                }
                return maxBottom
            }
            
            var totalHeight: CGFloat = 0
            if fullBlocks > 0 {
                totalHeight += CGFloat(fullBlocks) * blockHeight(for: itemsPerBlock)
                if fullBlocks > 1 { totalHeight += CGFloat(fullBlocks - 1) * spacing }
            }
            if remainder > 0 {
                if fullBlocks > 0 { totalHeight += spacing }
                totalHeight += blockHeight(for: remainder)
            }
            
            return totalHeight
        }
        
        override func layoutSubviews() {
            super.layoutSubviews()
            gridCollectionView.frame = contentView.bounds
            gridCollectionView.collectionViewLayout.invalidateLayout()
            gridCollectionView.layoutIfNeeded()
        }
        
        private var items: [GalleryItem] {
            viewModel.posts.enumerated().flatMap { index, post in
                switch post.content {
                case .media(let media):
                    return [GalleryItem(media: media, post: post)]
                case .gallery(let medias):
                    return medias.map { GalleryItem(media: $0, post: post) }
                }
            }
        }
        
        func visibleGalleryCellsSortedByProximity(to referenceView: UIView) -> [Gallery.ViewCell] {
            guard let window = referenceView.window else { return [] }
            
            let viewportCenter = referenceView.convert(referenceView.bounds.center, to: window)
            
            var scored: [(cell: Gallery.ViewCell, distance: CGFloat)] = []
            
            for case let cell as Gallery.ViewCell in gridCollectionView.visibleCells {
                let cellCenter = cell.convert(cell.bounds.center, to: window)
                let dx = cellCenter.x - viewportCenter.x
                let dy = cellCenter.y - viewportCenter.y
                let distance = dx * dx + dy * dy
                scored.append((cell, distance))
            }
            
            return scored.sorted(by: { $0.distance < $1.distance }).map { $0.cell }
        }
    }
}


extension Gallery.SectionViewCell {
    static func makeLayout(with pattern: [Bool]) -> UICollectionViewCompositionalLayout {
        return UICollectionViewCompositionalLayout { section, env in
            let cellSpacing: CGFloat = 4
            let horizontalInset: CGFloat = cellSpacing
            let columns: CGFloat = 3
            
            let totalSpacing = (columns - 1) * cellSpacing + 2 * horizontalInset
            let cellWidth = (env.container.effectiveContentSize.width - totalSpacing) / columns
            let cellHeight = cellWidth
            let groupHeight = cellHeight * 5 + cellSpacing * 4
            
            let group = NSCollectionLayoutGroup.custom(
                layoutSize: NSCollectionLayoutSize(
                    widthDimension: .fractionalWidth(1),
                    heightDimension: .estimated(groupHeight)
                )
            ) { _ in
                var frames: [NSCollectionLayoutGroupCustomItem] = []
                
                for i in 0..<pattern.count {
                    let frame: CGRect
                    switch i {
                    case 0:
                        frame = CGRect(x: 0, y: 0, width: cellWidth, height: cellHeight * 2 + cellSpacing)
                    case 1:
                        frame = CGRect(x: cellWidth + cellSpacing, y: 0, width: cellWidth, height: cellHeight)
                    case 2:
                        frame = CGRect(x: 2 * (cellWidth + cellSpacing), y: 0, width: cellWidth, height: cellHeight)
                    case 3:
                        frame = CGRect(x: cellWidth + cellSpacing, y: cellHeight + cellSpacing, width: cellWidth, height: cellHeight)
                    case 4:
                        frame = CGRect(x: 2 * (cellWidth + cellSpacing), y: cellHeight + cellSpacing, width: cellWidth, height: cellHeight)
                    case 5:
                        frame = CGRect(x: 0, y: 2 * (cellHeight + cellSpacing), width: 2 * cellWidth + cellSpacing, height: cellHeight)
                    case 6:
                        frame = CGRect(x: 2 * (cellWidth + cellSpacing), y: 2 * (cellHeight + cellSpacing), width: cellWidth, height: cellHeight * 2 + cellSpacing)
                    case 7:
                        frame = CGRect(x: 0, y: 3 * (cellHeight + cellSpacing), width: cellWidth, height: cellHeight)
                    case 8:
                        frame = CGRect(x: cellWidth + cellSpacing, y: 3 * (cellHeight + cellSpacing), width: cellWidth, height: cellHeight)
                    case 9:
                        frame = CGRect(x: 0, y: 4 * (cellHeight + cellSpacing), width: cellWidth, height: cellHeight)
                    case 10:
                        frame = CGRect(x: cellWidth + cellSpacing, y: 4 * (cellHeight + cellSpacing), width: 2 * cellWidth + cellSpacing, height: cellHeight)
                    default:
                        frame = .zero
                    }
                    frames.append(NSCollectionLayoutGroupCustomItem(frame: frame))
                }
                
                return frames
            }
            
            let sectionLayout = NSCollectionLayoutSection(group: group)
            sectionLayout.interGroupSpacing = cellSpacing
            sectionLayout.contentInsets = .init(top: 0, leading: horizontalInset, bottom: 0, trailing: horizontalInset)
            return sectionLayout
        }
    }
}

extension Gallery.SectionViewCell: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        items.count
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: Gallery.ViewCell.reuseIdentifier,
            for: indexPath
        ) as! Gallery.ViewCell

        let item = items[indexPath.item]
        
        let radius: CGFloat = 8
        let isLargeCell = layoutPattern[indexPath.item % layoutPattern.count]
        cell.configure(with: item.media)
        cell.applyCornerRadius(radius)
        cell.isLarge = isLargeCell

        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let cell = collectionView.cellForItem(at: indexPath) as? Gallery.ViewCell else { return }
        let item = items[indexPath.item]

        onMediaTapped?(GalleryTapContext(mediaView: cell.mediaView, item: item, indexPath: indexPath))
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        guard let viewCell = cell as? Gallery.ViewCell else { return }

        if let pending = viewCell.pendingMediaView {
            viewCell.attachMediaView(pending)
            viewCell.pendingMediaView = nil
        }
    }
}
