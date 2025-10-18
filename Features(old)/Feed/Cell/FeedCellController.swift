//
//  FeedCellController.swift
//  SocialMap
//
//  Created by Arnaud Maillet on 30/04/2025.
//


import UIKit


final class FeedCellController {
    
    // MARK: - Properties
    
    var cell: FeedCell?
    var post: Post.Model
    var currentIndex = 0
    private(set) var galleryItems: [MediaContent] = []
    private weak var parentFeedViewController: FeedViewController?
    private weak var scrollCoordinator: ScrollCoordinator?
    
    // MARK: - Configuration
    
    init(cell: FeedCell, with post: Post.Model, safeAreaInsets: UIEdgeInsets, parentFeedViewController: FeedViewController, scrollCoordinator: ScrollCoordinator) {
        self.cell = cell
        self.post = post
        self.parentFeedViewController = parentFeedViewController
        self.scrollCoordinator = scrollCoordinator

        switch post.content {
        case .media(let media):
            galleryItems = [media]
        case .gallery(let medias):
            galleryItems = medias
        }
        
        cell.configure(with: post, safeAreaInsets: safeAreaInsets, parentFeedViewController: parentFeedViewController, scrollCoordinator: scrollCoordinator)
        currentIndex = 0
        
        if case let .gallery(items) = post.content {
            galleryItems = items
            currentIndex = 0
        }
        
        // Branche tous les events
        cell.onTapInteractionLeft = { [weak self] in self?.goToPrevious() }
        cell.onTapInteractionRight = { [weak self] in self?.goToNext() }
        
        cell.onBackButtonTapped = { [weak self] in
            self?.parentFeedViewController?.triggerDismiss()
        }
        
        cell.onFollowTapped = { [weak self] in
            // Gère follow/toggle ou commentaires
            self?.cell?.overlayView.toggleBodyOrComments(animated: true)
        }
        
        cell.onRequestFeedScrollActivation = { [weak self] in
            guard
                let coordinator = self?.scrollCoordinator,
                let feedCollectionView = self?.parentFeedViewController?.collectionView
            else { return }
            coordinator.activate(feedCollectionView)
        }
        cell.setNeedsLayout()
        cell.layoutIfNeeded()
        // Ajout scrolls au coordinator
        scrollCoordinator.addScrollView(parentFeedViewController.collectionView)
        cell.overlayView.scrollCoordinator = scrollCoordinator
        scrollCoordinator.activate(parentFeedViewController.collectionView)
    }
    
    // MARK: - Navigation
    
    private func goToNext() {
        guard currentIndex + 1 < galleryItems.count else { return }
        currentIndex += 1
        displayCurrentMedia()
        cell?.overlayView.updateProgress(to: currentIndex)
    }

    private func goToPrevious() {
        guard currentIndex - 1 >= 0 else { return }
        currentIndex -= 1
        displayCurrentMedia()
        cell?.overlayView.updateProgress(to: currentIndex)
    }
    
    // MARK: - Media
    
    func displayCurrentMedia() {
        guard let cell = cell,
              currentIndex >= 0,
              currentIndex < galleryItems.count else { return }

        let media = galleryItems[currentIndex]
        assignPlayerIfNeeded(for: media)
        cell.overlayView.updateProgress(to: currentIndex)
    }
    
    func updateMedia(with newPost: Post.Model) {
        self.post = newPost
        self.currentIndex = 0

        switch newPost.content {
        case .media(let media):
            galleryItems = [media]
        case .gallery(let medias):
            galleryItems = medias
        }

        // Remettre à jour le contenu visuel de la cellule
        guard let cell = cell else { return }
        
        cell.configure(
            with: newPost,
            safeAreaInsets: parentFeedViewController?.view.safeAreaInsets ?? .zero,
            parentFeedViewController: parentFeedViewController!,
            scrollCoordinator: scrollCoordinator!
        )
        displayCurrentMedia()
        synchronizeProgressBar()
    }
    
    func playPlayer() {
        guard let media = currentMedia, media.isVideo else { return }
        cell?.mediaView.playVideoPlayer()
    }

    func pausePlayer() {
        cell?.mediaView.pauseVideoPlayer()
    }
    
    private func assignPlayerIfNeeded(for media: MediaContent) {
        guard let cell = self.cell else { return }

        if !media.isVideo {
            cell.mediaView.hideVideoPlayer()
            cell.mediaView.display(media: media)
            return
        }

        let videoId = media.id.uuidString
        
        if let previousMedia = currentMedia, previousMedia.id != media.id {
            VideoPlayerManager.shared.releasePlayer(for: previousMedia.id.uuidString)
        }

        if let player = VideoPlayerManager.shared.assignedPlayer(for: videoId) {
            print("[assignPlayerIfNeeded] Player already assigned for", videoId)
            cell.mediaView.showVideoPlayer(player)
            return
        }

        if let url = media.url,
           let player = VideoPlayerManager.shared.assignPlayer(for: videoId, url: url) {
            print("[assignPlayerIfNeeded] Player acquired for", videoId)
            cell.mediaView.showVideoPlayer(player)
        } else {
            print("[assignPlayerIfNeeded] Player pool full or URL nil for", videoId)
            cell.mediaView.hideVideoPlayer()
            cell.mediaView.display(media: media)
        }
    }
    
    func releasePlayerIfNeeded() {
        guard let media = currentMedia, media.isVideo else { return }
        VideoPlayerManager.shared.releasePlayer(for: media.id.uuidString)
        cell?.mediaView.hideVideoPlayer()
    }
    
    // MARK: - ProgressBar
    
    func synchronizeProgressBar() {
        guard let cell = cell else { return }
        if galleryItems.count <= 1 {
            cell.overlayView.configureProgressBar(count: 0, currentIndex: 0)
        } else {
            cell.overlayView.configureProgressBar(count: galleryItems.count, currentIndex: currentIndex)
        }
    }
    
    // MARK: - State accessors
    
    var galleryCount: Int { galleryItems.count }
    
    var currentMedia: MediaContent? {
        if !galleryItems.isEmpty, currentIndex >= 0, currentIndex < galleryItems.count {
            return galleryItems[currentIndex]
        }
        switch post.content {
        case .media(let media):
            return media
        case .gallery:
            break
        }
        return nil
    }
    
    func detachMediaView() {
        cell?.mediaView.removeFromSuperview()
    }
    
    func applyCornerRadius(_ radius: CGFloat) {
        cell?.layer.cornerRadius = radius
        cell?.layer.masksToBounds = true
    }
    
    func applySafeAreaInsets(_ insets: NSDirectionalEdgeInsets) {
        cell?.overlayView.applySafeAreaInsets(insets)
    }
}
