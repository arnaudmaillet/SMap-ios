//
//  GalleryPageViewCell.swift
//  SocialMap
//
//  Created by Arnaud Maillet on 03/08/2025.
//

import UIKit

extension Gallery.SectionViewCell {
    static let reuseIdentifier = "Gallery.PageViewCell"
}

extension Gallery {
    final class SectionViewCell: UICollectionViewCell {
        private var gridCollectionView: UICollectionView!
        var onHeightReady: (() -> Void)?
        
        override init(frame: CGRect) {
            super.init(frame: frame)
            setupGrid()
        }
        required init?(coder: NSCoder) { fatalError() }
        
        private func setupGrid() {
            gridCollectionView = UICollectionView(frame: .zero, collectionViewLayout: Self.makeLayout())
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
        
        override func layoutSubviews() {
            super.layoutSubviews()
            onHeightReady?()
        }
        
        func contentHeight() -> CGFloat {
            gridCollectionView.layoutIfNeeded()
            return gridCollectionView.collectionViewLayout.collectionViewContentSize.height
        }
        
        func reloadAndNotify() {
            gridCollectionView.performBatchUpdates(nil) { [weak self] _ in
                self?.onHeightReady?()
            }
        }
    }
}


extension Gallery.SectionViewCell {
    static func makeLayout() -> UICollectionViewCompositionalLayout {
        return UICollectionViewCompositionalLayout { section, env in
            let cellSpacing: CGFloat = 4
            let horizontalInset: CGFloat = cellSpacing
            let isCellLarge: [Bool] = [true, false, false, false, false, true, true, false, false, false, true]
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
                
                for i in 0..<isCellLarge.count {
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
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int { 22 }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Gallery.ViewCell.reuseIdentifier, for: indexPath) as! Gallery.ViewCell
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, layout layout2: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = (collectionView.bounds.width - 2) / 3
        return CGSize(width: width, height: width)
    }
}
