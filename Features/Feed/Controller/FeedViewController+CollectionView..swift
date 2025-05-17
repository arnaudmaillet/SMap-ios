//
//  FeedViewController+CollectionView..swift
//  SocialMap
//
//  Created by Arnaud Maillet on 19/04/2025.
//

import UIKit

// MARK: - UICollectionViewDataSource
extension FeedViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return posts.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "FeedCell", for: indexPath) as? FeedCell else {
            fatalError()
        }
        
        let post = posts[indexPath.item]
        let controller = cellControllers[indexPath] ?? FeedCellController()
        
        controller.configure(cell: cell, with: post, safeAreaInsets: view.safeAreaInsets)
        cellControllers[indexPath] = controller
        
        cell.setupOverlayView(in: self)

        return cell
    }
}

// MARK: - UICollectionViewDelegate
extension FeedViewController: UICollectionViewDelegate {
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let page = Int(scrollView.contentOffset.y / scrollView.bounds.height)
        print("📸 Scroll terminé → post \(page + 1)/\(posts.count)")
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        updateCurrentCellCornerRadius(scrollView: scrollView)
    }
}

