//
//  FeedCoordinator.swift
//  SocialMap
//
//  Created by Arnaud Maillet on 27/04/2025.
//

import UIKit
import MapKit
import AVFoundation

protocol FeedEntryDelegate: AnyObject {
    func presentFeedFromMap(
        for posts: [Post.Model],
        selectedPost: Post.Model,
        from annotationView: MKAnnotationView,
        in mapView: MKMapView
    )
}

protocol FeedOnRightExitSide: AnyObject {
    func presentUserProfile(from gesture: UIPanGestureRecognizer)
}

protocol FeedInternalNavigationDelegate: AnyObject {
    func presentFeedFromGallery(_ container: FeedContainerViewController, galleryCell: GalleryCell, post: Post.Model, media: MediaContent, originIndexPath: IndexPath)
    func dismissFeedToGallery()
}

protocol FeedLifecycleDelegate: AnyObject {
    func prepareGalleryForDismiss(for post: Post.Model?)
}

typealias FeedCoordinatorDelegate =
FeedEntryDelegate &
HeroDimissableStackScreen &
FeedInternalNavigationDelegate &
FeedLifecycleDelegate

final class FeedContainerCoordinator: FeedCoordinatorDelegate, FeedOnRightExitSide {
    
    // MARK: - Properties
    
    private var rootVC: UIViewController?
    var transitionDelegate: NavigationTransitionDelegate?
    weak var container: FeedContainerViewController?
    private var lastOpenedGalleryIndexPath: IndexPath = IndexPath(item: 0, section: 0)
    private var originalPost: Post.Model?
    
    private var sidePanelTransitionDelegate: SidePanelTransitioningDelegate?
    private var stackCoordinator: StackScreenCoordinator?
    
    // MARK: - Initialization
    
    init(rootVC: UIViewController) {
        self.rootVC = rootVC
    }
    
    // MARK: - Public Methods
    
    func presentFeedFromMap(for posts: [Post.Model], selectedPost: Post.Model, from annotationView: MKAnnotationView, in mapView: MKMapView) {
        // Mélange aléatoirement 75% des posts (en gardant selectedPost en premier)
        var feedPosts = posts.randomSubset(percent: 0.75)
        // S’assurer que selectedPost est présent et au début
        feedPosts.removeAll(where: { $0.id == selectedPost.id })
        feedPosts.insert(selectedPost, at: 0)
        
        var galleryPosts = posts.randomSubset(percent: 0.75)
        if !galleryPosts.contains(where: { $0.id == selectedPost.id }) {
            galleryPosts.insert(selectedPost, at: 0)
        }
        
        presentFeedFromMap(feedPosts: feedPosts, galleryPosts: galleryPosts, selectedPost: selectedPost, from: annotationView, in: mapView)
    }
    
    // MARK: - Private
    
    private func presentFeedFromMap(
        feedPosts: [Post.Model],
        galleryPosts: [Post.Model],
        selectedPost: Post.Model,
        from annotationView: MKAnnotationView,
        in mapView: MKMapView
    ) {
        guard let rootVC = debugUnwrap(rootVC)
        else { return }
        
        let animatedView = extractPreviewView(from: annotationView) ?? annotationView
        let frameInWindow = animatedView.convert(animatedView.bounds, to: rootVC.view)
        
        // 1. Prépare la backdrop Gallery (vivante)
        let galleryVC = GalleryViewController(posts: galleryPosts)
        galleryVC.coordinator = self
        galleryVC.view.frame = rootVC.view.bounds
        galleryVC.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        galleryVC.customSafeAreaInsets = rootVC.view.safeAreaInsets
        
        // 2. Prépare le Feed
        let viewModel = FeedViewModel(posts: feedPosts)
        let feedVC = FeedViewController(viewModel: viewModel)
        
        let selectedPost: Post.Model = feedPosts.first!
        
        VideoPlayerManager.shared.releaseAll()
        
        // 3. Container VC (le vrai présenté)
        let containerVCConfig = FeedContainerViewControllerConfig(
            rootVC: rootVC,
            galleryVC: galleryVC,
            feedVC: feedVC,
            coordinatorOnRightExit: self,
            coordinatorDelegate: self
        )
        
        let containerVC = FeedContainerViewController(config: containerVCConfig)
        
        containerVC.modalPresentationStyle = .custom
        
        self.container = containerVC
        
        // 4. Transition delegate : injecte ton custom delegate sur le container
        let transitionDelegate = NavigationTransitionDelegate(
            originView: animatedView,
            originFrame: frameInWindow,
            post: selectedPost,
            originalPost: selectedPost,
            rootVC: rootVC
        )
        
        self.transitionDelegate = transitionDelegate
        containerVC.transitioningDelegate = transitionDelegate
        
        self.originalPost = selectedPost
        
        // 5. Callback appelé **une fois le HeroPresent fini**
        transitionDelegate.onHeroPresentDidFinish = {
            galleryVC.view.layoutIfNeeded()
            feedVC.collectionView.layoutIfNeeded()
            feedVC.updateCurrentPlayingVideo()
        }
        
        // 6. Présente le container VC
        rootVC.present(containerVC, animated: true)
    }
    
    func presentFeedFromGallery(
        _ container: FeedContainerViewController,
        galleryCell: GalleryCell,
        post: Post.Model,
        media: MediaContent,
        originIndexPath: IndexPath
    ) {
        guard let window = container.view.window else { return }
        
        let destIndexPath = IndexPath(item: 0, section: 0)
        let galleryVC = container.galleryVC
        let mediaView = galleryCell.mediaView
        let videoId = media.id.uuidString
        let startFrame = mediaView.convert(mediaView.bounds, to: window)
        let destFrame = container.feedVC.view.convert(container.feedVC.view.bounds, to: window)
        let destCornerRadius: CGFloat = 55
        
        // Clean autres players
        for (mid, _) in VideoPlayerManager.shared.assignments {
            if mid != videoId {
                VideoPlayerManager.shared.releasePlayer(for: mid)
            }
        }
        
        // Préparation Feed
        if container.feedVC.viewModel.numberOfPosts() > 0 {
            container.feedVC.viewModel.replacePost(at: 0, with: post)
        } else {
            container.feedVC.viewModel.insertPost(post, at: 0)
        }
        
        // 2. Mise à jour du controller associé
        if let controller = container.feedVC.cellControllers[destIndexPath] {
            controller.updateMedia(with: post)
        }
        
        container.feedVC.view.isHidden = true
        container.feedVC.view.alpha = 0
        galleryVC.collectionView.isScrollEnabled = false
        galleryVC.collectionView.layoutIfNeeded()
        
        galleryVC.playOnlyGalleryCell(galleryCell)
        galleryCell.mediaView.debugInfo()
        
        // Préparation mediaView
        mediaView.removeFromSuperview()
        mediaView.frame = startFrame
        mediaView.clipsToBounds = true
        mediaView.translatesAutoresizingMaskIntoConstraints = true
        window.addSubview(mediaView)
        window.bringSubviewToFront(mediaView)
        
        mediaView.layoutIfNeeded()
        mediaView.videoPlayerView?.frame = mediaView.bounds
        (mediaView.videoPlayerView?.layer as? AVPlayerLayer)?.frame = mediaView.bounds
        
        // Snapshot Overlay
        let overlayView = OverlayView()
        overlayView.frame = CGRect(x: -9999, y: -9999, width: destFrame.width, height: destFrame.height)
        overlayView.configure(with: post)
        overlayView.applySafeAreaInsets(NSDirectionalEdgeInsets(edgeInsets: container.feedVC.view.safeAreaInsets))
        container.view.addSubview(overlayView)
        overlayView.layoutIfNeeded()
        
        guard let overlaySnapshot = overlayView.snapshotView(afterScreenUpdates: true) else {
            overlayView.removeFromSuperview()
            return
        }
        
        overlayView.removeFromSuperview()
        overlaySnapshot.frame = startFrame
        overlaySnapshot.alpha = 0
        overlaySnapshot.layer.cornerRadius = mediaView.layer.cornerRadius
        overlaySnapshot.applyRoundedMask(mediaView.layer.cornerRadius)
        window.addSubview(overlaySnapshot)
        
        mediaView.forceImageViewToManualLayout()
        
        container.feedVC.collectionView.reloadData()
        container.feedVC.collectionView.layoutIfNeeded()
        
        
        // MARK: - Animation HERO
        UIView.animate(
            withDuration: 0.35,
            delay: 0,
            usingSpringWithDamping: 0.95,
            initialSpringVelocity: 0.6,
            options: [.curveEaseOut],
            animations: {
                mediaView.frame = destFrame
                mediaView.layer.cornerRadius = destCornerRadius
                overlaySnapshot.frame = destFrame
                overlaySnapshot.layer.cornerRadius = destCornerRadius
                overlaySnapshot.alpha = 1
                overlaySnapshot.applyRoundedMask(destCornerRadius)
                galleryVC.galleryView.transform = CGAffineTransform(scaleX: UIConstant.view.zoomScale, y: UIConstant.view.zoomScale)
            },
            completion: { _ in
                mediaView.layer.cornerRadius = 0
                overlaySnapshot.layer.cornerRadius = 0
                
                mediaView.removeFromSuperview()
                overlaySnapshot.removeFromSuperview()
                
                if let cell = container.feedVC.collectionView.cellForItem(at: destIndexPath) as? FeedCell, let controller = container.feedVC.cellControllers[destIndexPath] {
                    // On remplace proprement l'ancien mediaView (créé par la cellule)
                    cell.replaceMediaView(with: mediaView)
                    cell.contentView.bringSubviewToFront(cell.overlayView)
                    mediaView.frame = cell.contentView.bounds
                    mediaView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
                    mediaView.restoreImageViewAutoLayout()
                }
                
                if let galleryClone = container.galleryVC.collectionView.cellForItem(at: originIndexPath) as? GalleryCell {
                    let clone = MediaContainerView()
                    clone.frame = galleryClone.contentView.bounds
                    clone.autoresizingMask = [.flexibleWidth, .flexibleHeight]
                    clone.currentMedia = media
                    clone.imageView.image = mediaView.imageView.image
                    galleryClone.contentView.addSubview(clone)
                    galleryClone.mediaView = clone
                }
                container.feedVC.view.isHidden = false
                container.feedVC.view.alpha = 1
                container.feedVC.updateCurrentPlayingVideo()
                
                container.view.bringSubviewToFront(container.feedVC.view)
                galleryVC.collectionView.isScrollEnabled = true
                self.lastOpenedGalleryIndexPath = originIndexPath
            }
        )
    }
    
    func dismiss() {
        guard let container = container else { return }
        container.dismiss(animated: true)
    }
    
    func debugFrameView(frame: CGRect, color: UIColor, cornerRadius: CGFloat = 0, in window: UIWindow) -> UIView {
        let v = UIView(frame: frame)
        v.layer.borderColor = color.cgColor
        v.layer.borderWidth = 2
        v.layer.cornerRadius = cornerRadius
        v.backgroundColor = .clear
        v.isUserInteractionEnabled = false
        window.addSubview(v)
        return v
    }
    
    func dismissFeedToGallery() {
        print("===== [DISMISS FEED TO GALLERY] =====")
        
        guard let container = container else {
            print("❌ [FeedContainerCoordinator](dimissFeedToGallery) container manquant")
            return
        }
        guard
            let feedCellVC = container.feedVC.currentVisibleController,
            let feedCell = feedCellVC.cell,
            let window = container.view.window
        else {
            print("❌ [FeedContainerCoordinator](dimissFeedToGallery) Données manquantes depuis controller")
            return
        }
        
        let destIndexPath = lastOpenedGalleryIndexPath
        let collectionView = container.galleryVC.collectionView
        
        guard
            let destCell = collectionView.cellForItem(at: destIndexPath) as? GalleryCell,
            destCell.mediaView.currentMedia?.id == feedCellVC.currentMedia?.id
        else {
            print("❌ [Dismiss] Mauvaise cellule ou mauvais contenu pour \(destIndexPath)")
            return
        }
        
        let destMediaView = destCell.mediaView
        let sourceMediaView = feedCell.mediaView
        
        let overlayView = feedCell.overlayView
        
        let galleryScale = container.galleryVC.view.transform.a
        let endFrame = destCell.convert(destCell.bounds, to: window).unscaledFrame(relativeTo: window, scale: galleryScale)
        
        let sourceCornerRadius = container.feedVC.view.layer.cornerRadius * container.feedVC.view.transform.a
        
        // 🔁 Préparation du mediaView (image ou vidéo)
        let startFrame = sourceMediaView.convert(sourceMediaView.bounds, to: window)
        sourceMediaView.removeFromSuperview()
        sourceMediaView.frame = startFrame
        sourceMediaView.clipsToBounds = true
        sourceMediaView.layer.cornerRadius = sourceCornerRadius
        sourceMediaView.translatesAutoresizingMaskIntoConstraints = true
        sourceMediaView.forceImageViewToManualLayout()
        window.addSubview(sourceMediaView)
        
        // 🔁 Préparation Overlay (snapshot)
        let overlaySnapshot = overlayView.snapshotView(afterScreenUpdates: false)
        if let overlaySnapshot = overlaySnapshot {
            overlaySnapshot.frame = overlayView.convert(overlayView.bounds, to: window)
            overlaySnapshot.clipsToBounds = true
            overlaySnapshot.layer.cornerRadius = sourceCornerRadius
            window.addSubview(overlaySnapshot)
        }
        overlayView.alpha = 0
        
        destMediaView.isHidden = true
        container.feedVC.view.isHidden = true
        
        UIView.animate(withDuration: 0.35,
                       delay: 0,
                       usingSpringWithDamping: 0.95,
                       initialSpringVelocity: 0.6,
                       options: [.curveEaseOut],
                       animations: {
            sourceMediaView.frame = endFrame
            sourceMediaView.layer.cornerRadius = destMediaView.layer.cornerRadius
            overlaySnapshot?.frame = endFrame
            overlaySnapshot?.alpha = 0
            overlaySnapshot?.layer.cornerRadius = destMediaView.layer.cornerRadius
            container.galleryVC.galleryView.transform = .identity
        }, completion: { _ in
            overlaySnapshot?.removeFromSuperview()
            destMediaView.isHidden = false
            
            if let media = destCell.mediaView.currentMedia,
               let index = container.galleryVC.posts.firstIndex(where: {
                   $0.content.containsMedia(withId: media.id)
               }) {
                container.galleryVC.posts[index] = feedCellVC.post
            }
            
            feedCellVC.detachMediaView()
            destCell.attachMediaView(sourceMediaView)
            
            // 🔁 💡 Créer une nouvelle vue propre dans le feed
            let feedClone = MediaContainerView()
            feedClone.frame = feedCell.contentView.bounds
            feedClone.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            feedClone.currentMedia = feedCellVC.currentMedia
            feedClone.imageView.image = sourceMediaView.imageView.image
            feedCell.contentView.addSubview(feedClone)
            feedCell.contentView.insertSubview(feedClone, belowSubview: feedCell.overlayView)
            feedCellVC.cell?.mediaView = feedClone
//            container.feedVC.removeLockedPosts(except: feedCellVC.currentMedia?.id)
            container.galleryVC.updateCurrentPlayingVideos(forcePlayCell: destCell)
            container.feedVC.resetLayout(keepViewHidden: true)
        })
    }
    
    /// Extrait la preview UIView d'une annotation (single ou cluster).
    private func extractPreviewView(from annotationView: MKAnnotationView) -> UIView? {
        if let postView = annotationView as? Post.Annotation.View {
            return postView.preview
        } else if let clusterView = annotationView as? Post.Annotation.ClusterView {
            return clusterView.preview
        }
        return nil
    }
    
    func prepareGalleryForDismiss(for post: Post.Model?) {
        guard
            let post = debugUnwrap(post),
            let container = debugUnwrap(container),
            let feedVC = debugUnwrap(container.feedVC),
            let galleryVC = debugUnwrap(container.galleryVC),
            let currentIndexPath = debugUnwrap(feedVC.collectionView.indexPathsForVisibleItems.first, "Pas d'indexPath visible")
        else {
            return
        }
        
        // 💡 On récupère le controller actif
        guard let cellController = feedVC.cellControllers[currentIndexPath] else {
            assertionFailure("🔴 [Coordinator](prepareGalleryForDismiss) FeedCellController absent pour cellule visible à \(currentIndexPath)")
            return
        }
        
        guard !cellController.galleryItems.isEmpty else {
            assertionFailure("🔴 [Coordinator](prepareGalleryForDismiss) galleryItems vide dans FeedCellController à \(currentIndexPath)")
            return
        }
        
        // 📌 On prend le media actif si possible, sinon le premier
        let media: MediaContent
        if let selected = cellController.galleryItems[safe: cellController.currentIndex] {
            media = selected
        } else if let fallback = cellController.galleryItems.first {
            media = fallback
        } else {
            assertionFailure("🔴 [Coordinator](prepareGalleryForDismiss) Aucun media dans galleryItems (should never happen)")
            return
        }
        
        // 🔄 Mise à jour de la gallerie
        galleryVC.updateGalleryItem(at: lastOpenedGalleryIndexPath, with: post, media: media)
        galleryVC.dettachMediaView(at: lastOpenedGalleryIndexPath)
        galleryVC.scrollToItemIfNeeded(at: lastOpenedGalleryIndexPath)
        container.scaleHomeView(to: UIConstant.view.zoomScale)
    }
    
    func presentUserProfile(from gesture: UIPanGestureRecognizer) {
        guard let container = debugUnwrap(container) else { return }
        
        let currentIndex = container.feedVC.collectionView.indexPathsForVisibleItems.first
        container.feedVC.saveCurrentPlayingIndex(currentIndex)
        VideoPlayerManager.shared.pauseAll()
        
        MockUserProvider.generateUsersWithPosts(userCount: 1, postCount: 22) { users in
            guard let user = users.first else { return }
            
            let profileVC = ProfileViewController(user: user)
            
            // MARK: - Création du Stack
            let stackCoordinator = StackScreenCoordinator(presentingVC: container)
            self.stackCoordinator = stackCoordinator
            
            // MARK: - Transition Slide vers Profile
            stackCoordinator.presentOnSlide(
                screen: profileVC,
                panGesture: gesture,
                didDismiss: { [weak self] in
                    self?.resumeFeedVideo()
                }
            )
            
            // MARK: - Tap sur un média → transition vers Feed
            profileVC.onMediaTapped = { [weak self] ctx in
                guard let self, let coordinator = self.stackCoordinator else { return }
                let viewModel = FeedViewModel(posts: user.posts)
                let feedVC = FeedViewController(viewModel: viewModel)
                
                // MARK: - Libération des autres players visibles
                for cell in profileVC.collectionView.visibleCells {
                    guard
                        let containerCell = cell as? Gallery.ContainerViewCell,
                        let sectionCell = containerCell.currentVisibleSectionCell()
                    else { continue }

                    for cell in sectionCell.gridCollectionView.visibleCells {
                        guard let viewCell = cell as? Gallery.ViewCell else { continue }
                        if viewCell.mediaView !== ctx.mediaView {
                            viewCell.mediaView.releasePlayer()
                        }
                    }
                }
                
                guard
                    let fromVC = debugUnwrap(profileVC),
                    let toVC = debugUnwrap(feedVC),
                    let animatedView = debugUnwrap(ctx.mediaView),
                    let data = fromVC.heroTransitionData()
                else {
                    return
                }

                let pushContext = HeroTransitionContext(
                    fromViewController: fromVC,
                    toViewController: toVC,
                    sourceIndexPath: ctx.indexPath,
                    destinationIndexPath: IndexPath(item: 0, section: 0),
                    animatedView: animatedView,
                    transitionData: data
                )
                
                coordinator.pushViewControllerWithHeroTransition(pushContext)
            }
        }
    }
    
    private func resumeFeedVideo() {
        guard let container = debugUnwrap(container) else { return }
        container.feedVC.resumeLastPlayingVideo()
    }
}
