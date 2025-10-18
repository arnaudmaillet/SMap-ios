//
//  GalleryContainerView.swift
//  SocialMap
//
//  Created by Arnaud Maillet on 28/07/2025.
//

import UIKit

extension Gallery.ContainerViewCell {
    static let reuseIdentifier = "Gallery.ContainerViewCell"
}

struct Gallery {
    final class ContainerViewCell: UICollectionViewCell {
        private var collectionView: UICollectionView!
        private var categories: [String] = []
        
        var viewModel: GalleryViewModel!
        var onMediaTapped: OnGalleryTap?
        
        override init(frame: CGRect) {
            super.init(frame: frame)
            setupPages()
        }
        required init?(coder: NSCoder) { fatalError() }
        
        private func setupPages() {
            let layout = UICollectionViewFlowLayout()
            layout.scrollDirection = .horizontal
            layout.minimumLineSpacing = 0
            collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
            collectionView.isPagingEnabled = true
            collectionView.showsHorizontalScrollIndicator = false
            collectionView.dataSource = self
            collectionView.delegate = self
            collectionView.register(Gallery.SectionViewCell.self, forCellWithReuseIdentifier: Gallery.SectionViewCell.reuseIdentifier)
            contentView.addSubview(collectionView)
            collectionView.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                collectionView.topAnchor.constraint(equalTo: contentView.topAnchor),
                collectionView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
                collectionView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
                collectionView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
            ])
        }

        func configure(categories: [String]) {
            self.categories = categories
            collectionView.reloadData()
        }
        
        func scrollToPage(_ index: Int) {
            collectionView.scrollToItem(at: IndexPath(item: index, section: 0), at: .centeredHorizontally, animated: true)
        }
        
        func currentVisibleSectionCell() -> Gallery.SectionViewCell? {
            for cell in collectionView.visibleCells {
                return cell as? Gallery.SectionViewCell
            }
            return nil
        }
    }
}

extension Gallery.ContainerViewCell: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int { categories.count }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: Gallery.SectionViewCell.reuseIdentifier,
            for: indexPath
        ) as! Gallery.SectionViewCell

        cell.viewModel = viewModel
        
        cell.onMediaTapped = { [weak self] ctx in
            self?.onMediaTapped?(ctx)
        }
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, layout layout2: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return collectionView.bounds.size
    }
}
