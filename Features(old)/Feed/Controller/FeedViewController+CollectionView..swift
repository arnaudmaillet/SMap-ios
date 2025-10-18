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
        return viewModel.numberOfPosts()
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "FeedCell", for: indexPath) as? FeedCell else {
            fatalError("❌ Échec du dequeue FeedCell")
        }
        let post = viewModel.post(at: indexPath.item)!
        
        let controller: FeedCellController
        if let existing = cellControllers[indexPath] {
            controller = existing
            controller.cell = cell
            controller.updateMedia(with: post)
        } else {
            controller = FeedCellController(cell: cell, with: post, safeAreaInsets: view.safeAreaInsets, parentFeedViewController: self, scrollCoordinator: scrollCoordinator)
            cellControllers[indexPath] = controller
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        guard let feedCell = cell as? FeedCell else { return }

        if let pending = feedCell.pendingMediaView {
            print("📥 [willDisplay] Rattachement pendingMediaView")
            feedCell.replaceMediaView(with: pending)
            feedCell.pendingMediaView = nil
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        guard let controller = cellControllers[indexPath] else { return }
        controller.cell = nil
        if let media = controller.currentMedia, media.isVideo {
            VideoPlayerManager.shared.releasePlayer(for: media.id.uuidString)
            controller.cell?.mediaView.hideVideoPlayer()
        }
    }
    
    // Tu peux garder cette méthode si tu veux forcer une resynchronisation de l’état d’une cellule visible
    private func synchronizeVisibleCell(at index: Int) {
        let indexPath = IndexPath(item: index, section: 0)
        guard let controller = cellControllers[indexPath] else { return }
        controller.displayCurrentMedia()
        controller.synchronizeProgressBar()
    }
    
    var currentVisibleIndex: Int {
        return Int(round(collectionView.contentOffset.y / collectionView.bounds.height))
    }
}

// MARK: - UICollectionViewDelegate
extension FeedViewController: UICollectionViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        updateCurrentPlayingVideo()
        
        let offsetY = scrollView.contentOffset.y
        let pageHeight = scrollView.bounds.height
        let minAllowedOffset = CGFloat(lockedPostIndex) * pageHeight
        if offsetY < minAllowedOffset {
            scrollView.setContentOffset(CGPoint(x: 0, y: minAllowedOffset), animated: false)
        }
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let offsetY = scrollView.contentOffset.y
        let pageHeight = scrollView.bounds.height
        let index = Int(round(offsetY / pageHeight))
        // On verrouille tout ce qui est avant
        if index > lockedPostIndex {
            lockedPostIndex = index
        }
    }
}
