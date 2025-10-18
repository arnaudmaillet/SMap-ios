//
//  UserContainerCoordinator.swift
//  SocialMap
//
//  Created by Arnaud Maillet on 09/08/2025.
//

import UIKit
import AVFoundation

final class UserContainerCoordinator: HeroDimissableStackScreen {
    weak var parent: FeedContainerCoordinator?
    private weak var presentingVC: UIViewController?
    private var transitionDelegate: SidePanelTransitioningDelegate?
    private(set) weak var container: UserContainerViewController?
    let manager = VideoPlayerManager.shared
    
    init(parent: FeedContainerCoordinator?, presentingVC: UIViewController) {
        self.parent = parent
        self.presentingVC = presentingVC
    }
    
    func present(user: User, from pan: UIPanGestureRecognizer) {
        guard let presentingVC = presentingVC else { return }
        
        // 1) Feed pour le profil (réutilise ton FeedViewController existant)
        let viewModel = FeedViewModel(posts: user.posts)
        let feedVC = FeedViewController(viewModel: viewModel)
        
        // 2) Profil
        let profileVC = ProfileViewController(user: user)
        //        profileVC.onDismiss = { [weak self] in
        //            self?.dismiss()
        //        }
        
        profileVC.onMediaTapped = { [weak self] ctx in
            guard let self = debugUnwrap(self) else { return }
            self.presentFeedFromProfile(
                mediaView: ctx.mediaView,
                item: ctx.item,
                originIndexPath: ctx.indexPath
            )
        }
        
        // 3) Container feed+profil
        let containerVCConfig = UserContainerViewControllerConfig(
            rootVC: presentingVC,
            profileVC: profileVC,
            feedVC: feedVC,
            coordinatorOnLeftExit: self
        )
        
        let container = UserContainerViewController(config: containerVCConfig)
        
        // 4) Transition interactive (slide qui suit le doigt)
        let sideDelegate = SidePanelTransitioningDelegate()
        let interactive = UIPercentDrivenInteractiveTransition()
        sideDelegate.interactiveTransition = interactive
        self.transitionDelegate = sideDelegate
        
        container.transitioningDelegate = sideDelegate
        container.modalPresentationStyle = .custom
        
        // Cleanup + reprise vidéo du feed parent à la fermeture
        container.didDismiss = { [weak self] in
            //            self?.parent?.resumeFeedVideo()
        }
        
        container.coordinator = self
        self.container = container
        
        // 5) Présentation + amorçage de l’interactif avec la position actuelle du pan
        presentingVC.present(container, animated: true)
        
        let tx = -max(0, pan.translation(in: presentingVC.view).x) // swipe gauche => négatif
        let w = presentingVC.view.bounds.width
        let percent = min(max(tx / w, 0), 1)
        interactive.update(max(percent, 0.001)) // > 0 pour enclencher l’interactif
    }
    
    
    func presentFeedFromProfile(
        mediaView: MediaContainerView,
        item: GalleryItem,
        originIndexPath: IndexPath
    ) {
        guard
            let container = debugUnwrap(self.container),
            let window = debugUnwrap(container.view.window),
            let mediaSuperView = debugUnwrap(mediaView.superview)
        else { return }

        let post = item.post
        let media = item.media
        let feedVC = container.feedVC
        let profileVC = container.profileVC
        let startFrame = mediaView.convert(mediaView.bounds, to: window)
        let destFrame = feedVC.view.convert(feedVC.view.bounds, to: window)
        let destIndexPath = IndexPath(item: 0, section: 0)
        let cornerRadius = UIConstant.device.cornerRadius

        profileVC.collectionView.isScrollEnabled = false

        // --- 1. Préparer les posts (remplacer ou insérer) ---
        if feedVC.viewModel.numberOfPosts() > 0 {
            feedVC.viewModel.replacePost(at: 0, with: post)
        } else {
            feedVC.viewModel.insertPost(post, at: 0)
        }

        // --- 2. Préparer le player ---
        manager.releaseAllStandalone()
        manager.releaseAll(except: [media.id.uuidString])
        assignPlayerIfNeeded(to: mediaView, for: media)

        // --- 3. Layouts nécessaires ---
        container.view.layoutIfNeeded()
        feedVC.view.layoutIfNeeded()
        mediaSuperView.layoutIfNeeded()
        mediaView.layoutIfNeeded()

        // --- 4. Animation HERO setup ---
        feedVC.view.isHidden = true
        feedVC.view.alpha = 0
        container.view.bringSubviewToFront(feedVC.view)

        mediaView.removeFromSuperview()
        mediaView.frame = startFrame
        mediaView.clipsToBounds = true
        mediaView.translatesAutoresizingMaskIntoConstraints = true
        mediaView.layer.cornerRadius = 0
        window.addSubview(mediaView)

        mediaView.layoutIfNeeded()
        mediaView.videoPlayerView?.frame = mediaView.bounds
        (mediaView.videoPlayerView?.layer as? AVPlayerLayer)?.frame = mediaView.bounds

        // --- 5. Snapshot de l'overlay ---
        let overlayView = OverlayView()
        overlayView.frame = CGRect(x: -9999, y: -9999, width: destFrame.width, height: destFrame.height)
        overlayView.configure(with: post)
        overlayView.applySafeAreaInsets(NSDirectionalEdgeInsets(edgeInsets: feedVC.view.safeAreaInsets))
        container.view.addSubview(overlayView)
        overlayView.layoutIfNeeded()

        guard let overlaySnapshot = overlayView.snapshotView(afterScreenUpdates: true) else {
            overlayView.removeFromSuperview()
            return
        }

        overlayView.removeFromSuperview()
        overlaySnapshot.frame = startFrame
        overlaySnapshot.alpha = 0
        overlaySnapshot.layer.cornerRadius = cornerRadius
        overlaySnapshot.applyRoundedMask(cornerRadius)
        window.addSubview(overlaySnapshot)

        // --- 6. Animation vers le feed ---
        UIView.animate(
            withDuration: 2,
            delay: 0,
            usingSpringWithDamping: 0.95,
            initialSpringVelocity: 0.6,
            options: [.curveEaseOut],
            animations: {
                mediaView.frame = destFrame
                mediaView.layer.cornerRadius = cornerRadius
                overlaySnapshot.frame = destFrame
                overlaySnapshot.alpha = 1
                overlaySnapshot.layer.cornerRadius = cornerRadius
                overlaySnapshot.applyRoundedMask(cornerRadius)
            },
            completion: { _ in
                mediaView.layer.cornerRadius = 0
                overlaySnapshot.removeFromSuperview()

                feedVC.view.isHidden = false
                feedVC.view.alpha = 1

                // --- 7. Injecter mediaView dans la bonne cellule ---
                if let feedCell = feedVC.collectionView.cellForItem(at: destIndexPath) as? FeedCell {
                    feedCell.replaceMediaView(with: mediaView)
                    feedCell.contentView.bringSubviewToFront(feedCell.overlayView)
                    mediaView.frame = feedCell.contentView.bounds
                    mediaView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
                } else {
                    feedVC.view.addSubview(mediaView)
                    mediaView.frame = feedVC.view.bounds
                    mediaView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
                }

                // --- 8. Met à jour proprement le controller ---
                let controller = feedVC.ensureCellController(for: destIndexPath, post: post, forceIfNeeded: true)
                controller?.updateMedia(with: post)

                // --- 9. Scroll + synchro ---
                feedVC.collectionView.scrollToItem(at: destIndexPath, at: .centeredVertically, animated: false)
                feedVC.collectionView.layoutIfNeeded()
                feedVC.updateCurrentPlayingVideo()
                container.enableFeedInteraction()
            }
        )
    }
    
    func assignPlayerIfNeeded(to mediaView: MediaContainerView, for media: MediaContent) {
        guard media.isVideo else {
            mediaView.hideVideoPlayer()
            mediaView.display(media: media)
            return
        }
        let videoId = media.id.uuidString
        if let player = VideoPlayerManager.shared.assignedPlayer(for: videoId) {
            mediaView.showVideoPlayer(player)
            return
        }
        if let url = media.url, let player = VideoPlayerManager.shared.assignPlayer(for: videoId, url: url) {
            mediaView.showVideoPlayer(player)
        } else {
            mediaView.hideVideoPlayer()
            mediaView.display(media: media)
        }
    }
    
    func dismiss() {
        guard let container = container else { return }
        container.dismiss(animated: true)
    }
}
