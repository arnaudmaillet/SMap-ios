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
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "FeedCell", for: indexPath) as! FeedCell
        cell.configure(with: posts[indexPath.item], safeAreaInsets: view.safeAreaInsets)
        return cell
    }
}

// MARK: - UICollectionViewDelegate
extension FeedViewController: UICollectionViewDelegate {
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let page = Int(scrollView.contentOffset.y / scrollView.bounds.height)
        print("📸 Scroll terminé → post \(page + 1)/\(posts.count)")
        updateDismissOverlayView()
    }
}

