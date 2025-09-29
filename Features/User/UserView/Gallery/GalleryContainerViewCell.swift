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
    // MARK: - Pages Cell
    final class ContainerViewCell: UICollectionViewCell {
        private var collectionView: UICollectionView!
        private var categories: [String] = []
        private var posts: [Post.Model] = []
        private var onHeightChanged: (() -> Void)?
        
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
            collectionView.backgroundColor = .white
            collectionView.dataSource = self
            collectionView.delegate = self
            collectionView.register(Gallery.PageViewCell.self, forCellWithReuseIdentifier: Gallery.PageViewCell.reuseIdentifier)
            contentView.addSubview(collectionView)
            collectionView.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                collectionView.topAnchor.constraint(equalTo: contentView.topAnchor),
                collectionView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
                collectionView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
                collectionView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
            ])
        }

        func configure(categories: [String], posts: [Post.Model], onHeightChanged: @escaping () -> Void) {
            self.categories = categories
            self.posts = posts
            self.onHeightChanged = onHeightChanged
            collectionView.reloadData()
        }
        
        func scrollToPage(_ index: Int) {
            collectionView.scrollToItem(at: IndexPath(item: index, section: 0), at: .centeredHorizontally, animated: true)
        }
        
        func currentPageHeight() -> CGFloat {
            if let pageCellView = collectionView.visibleCells.first as? PageViewCell {
                print("AAAAAAA", pageCellView.contentHeight())
                return max(pageCellView.contentHeight(), 0)
            }
            return 0
        }
    }
}

extension Gallery.ContainerViewCell: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int { categories.count }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Gallery.PageViewCell.reuseIdentifier, for: indexPath) as! Gallery.PageViewCell
        cell.onHeightReady = { [weak self] in self?.onHeightChanged?() }
        cell.reloadAndNotify()
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, layout layout2: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return collectionView.bounds.size
    }
}
