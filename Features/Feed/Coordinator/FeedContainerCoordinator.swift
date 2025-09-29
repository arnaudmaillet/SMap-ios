//
//  FeedCoordinator.swift
//  SocialMap
//
//  Created by Arnaud Maillet on 27/04/2025.
//

import UIKit
import MapKit

enum FeedScreenState {
    case feed
    case gallery
}

protocol FeedContainerCoordinatorProtocol: AnyObject {
    func presentFeedFromMap(for posts: [Post.Model], selectedPost: Post.Model, from annotationView: MKAnnotationView, in mapView: MKMapView)
    func prepareGalleryForDismiss(for post: Post.Model?)
    func presentFeedFromGallery(_ container: FeedContainerViewController, galleryCell: GalleryCell, post: Post.Model, media: MediaContent, originIndexPath: IndexPath)
    func dimissFeedToGallery(_: FeedContainerViewController)
}

final class FeedContainerCoordinator: FeedContainerCoordinatorProtocol, FeedContainerViewControllerDelegate {
    
    // MARK: - Properties
    
    private weak var presentingViewController: (UIViewController & FeedControllerDelegate)?
    private var transitionDelegate: NavigationTransitionDelegate?
    var galleryVC: GalleryViewController?
    weak var feedContainerVC: FeedContainerViewController?
    private var lastOpenedGalleryIndexPath: IndexPath = IndexPath(item: 0, section: 1)
    private var originalPost: Post.Model?
    private(set) var screenState: FeedScreenState = .feed
    
    var sharedPlayerPool: [VideoPlayerView] = []
    var sharedPlayerPoolCapacity: Int = 3 // ou plus si tu veux
    var playerAssignments: [String: VideoPlayerView] = [:]
    
    // MARK: - Initialization
    
    init(presentingViewController: UIViewController & FeedControllerDelegate) {
        self.presentingViewController = presentingViewController
        
        for _ in 0..<sharedPlayerPoolCapacity {
            sharedPlayerPool.append(VideoPlayerView())
        }
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
        guard let window = presentingViewController?.view.window else { return }
        let animatedView = extractPreviewView(from: annotationView) ?? annotationView
        let frameInWindow = animatedView.convert(animatedView.bounds, to: window)
        
        // 1. Prépare la backdrop Gallery (vivante)
        let galleryVC = GalleryViewController(posts: galleryPosts)
        galleryVC.coordinator = self
        galleryVC.view.frame = window.bounds
        galleryVC.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        galleryVC.view.alpha = 1
        galleryVC.customSafeAreaInsets = presentingViewController?.view.safeAreaInsets ?? .zero
        self.galleryVC = galleryVC
        
        // 2. Prépare le Feed
        let feedVC = FeedViewController(posts: feedPosts, originPost: selectedPost)
        feedVC.coordinator = self
        feedVC.originFrame = frameInWindow
        feedVC.delegate = presentingViewController
        feedVC.homeContainerView = (presentingViewController as? HomeViewController)?.view
        
        let selectedPost: Post.Model = feedPosts.first! // Ou choisis selon logique d’entrée
        
        playerAssignments.removeAll()
        for player in sharedPlayerPool { player.removeFromSuperview() }
        
        // 3. Container VC (le vrai présenté)
        let containerVC = FeedContainerViewController(galleryVC: galleryVC, feedVC: feedVC)
        containerVC.modalPresentationStyle = .custom
        containerVC.delegate = self
        self.feedContainerVC = containerVC
        
        // 4. Transition delegate : injecte ton custom delegate sur le container
        let transitionDelegate = NavigationTransitionDelegate(
            originView: animatedView,
            originFrame: frameInWindow,
            post: selectedPost,
            originalPost: selectedPost,
            homeVC: presentingViewController as? HomeViewController,
            screenState: screenState
        )
        
        self.transitionDelegate = transitionDelegate
        containerVC.transitioningDelegate = transitionDelegate
        
        self.originalPost = selectedPost
        screenState = .feed
        
        // 5. Callback appelé **une fois le HeroPresent fini**
        transitionDelegate.onHeroPresentDidFinish = { [weak self] in
            guard let galleryVC = self?.galleryVC else { return }
            galleryVC.view.setNeedsLayout()
            galleryVC.view.layoutIfNeeded()
            galleryVC.view.alpha = 0
            UIView.animate(withDuration: 0.14) {
                galleryVC.view.alpha = 1
            }
            self?.screenState = .feed
        }
        
        // 6. Présente le container VC
        presentingViewController?.present(containerVC, animated: true)
    }
    
    func presentFeedFromGallery(
        _ container: FeedContainerViewController,
        galleryCell: GalleryCell,
        post: Post.Model,
        media: MediaContent,
        originIndexPath: IndexPath
    ) {
        guard let window = container.view.window else {
            print("🔴 [Coordinator] No window found for container")
            return
        }
        self.screenState = .gallery
        
        let mediaView = galleryCell.mediaView
        
        // ==========================
        // === 1. CAS VIDEO HERO ====
        // ==========================
        guard let cellVideoView = mediaView.videoPlayerView else {
            print("❗️[Coordinator] videoView is nil, abort VIDEO hero transition")
            return
        }
        let videoId = media.id.uuidString
        guard let videoView = playerAssignments[videoId] else { return } // déjà assigné
        videoView.removeFromSuperview()
        
        print("🟢 [Coordinator] VIDEO hero transition")
        let galleryVC = container.galleryVC
        
        // Désactive toutes les autres vidéos de la galerie (hors celle qu’on anime)
        for cell in galleryVC.galleryView.collectionView.visibleCells {
            guard let gc = cell as? GalleryCell else { continue }
            if gc !== galleryCell {
                print("   • Pause video in cell at \(galleryVC.galleryView.collectionView.indexPath(for: gc) ?? IndexPath())")
                gc.mediaView.videoPlayerView?.pause()
            }
        }
        
        // Hero Animation, même si source == destination
        let startFrame = mediaView.convert(mediaView.bounds, to: window)
        let destFrame = container.feedVC.view.convert(container.feedVC.view.bounds, to: window)
        let destCornerRadius: CGFloat = 55

        
        // Retire le player du mediaView (cellule galerie)
        videoView.removeFromSuperview()
        videoView.frame = startFrame
        videoView.layer.cornerRadius = mediaView.layer.cornerRadius
        videoView.clipsToBounds = true
        videoView.layer.borderColor = UIColor.green.cgColor
        videoView.layer.borderWidth = 1
        videoView.translatesAutoresizingMaskIntoConstraints = true
        window.addSubview(videoView)
        mediaView.isHidden = true
        
        // Overlay Hero Snapshot (UI)
        let overlayView = OverlayView()
        overlayView.frame = CGRect(x: -9999, y: -9999, width: destFrame.width, height: destFrame.height)
        overlayView.configure(with: post)
        overlayView.applySafeAreaInsets(NSDirectionalEdgeInsets(edgeInsets: container.feedVC.view.safeAreaInsets))
        container.view.addSubview(overlayView)
        overlayView.setNeedsLayout()
        overlayView.layoutIfNeeded()
        guard let overlaySnapshot = overlayView.snapshotView(afterScreenUpdates: true) else {
            overlayView.removeFromSuperview()
            print("🔴 [Coordinator] overlaySnapshot failed")
            return
        }
        overlayView.removeFromSuperview()
        overlaySnapshot.frame = startFrame
        overlaySnapshot.layer.cornerRadius = mediaView.layer.cornerRadius
        overlaySnapshot.alpha = 0
        window.addSubview(overlaySnapshot)
        
        // Prépare les posts du feed (le post cliqué d'abord)
        let allPosts = galleryVC.allPosts
        var feedPosts: [Post.Model] = [post]
        for p in allPosts where p.id != post.id { feedPosts.append(p) }
        
        container.feedVC.posts = feedPosts
        container.feedVC.cellControllers = [:]
        container.feedVC.collectionView.reloadData()
        container.feedVC.view.layoutIfNeeded()
        container.feedVC.configure(for: post, media: media)
        self.lastOpenedGalleryIndexPath = originIndexPath
        self.screenState = .feed
        
        for cell in galleryVC.galleryView.collectionView.visibleCells {
            guard let gc = cell as? GalleryCell else { continue }
            let cellVideoId = gc.mediaView.currentMedia?.id.uuidString
            if cellVideoId != videoId {
                print("   • Pause and unregister video in cell at \(galleryVC.galleryView.collectionView.indexPath(for: gc) ?? IndexPath()), id: \(cellVideoId ?? "-")")
                gc.mediaView.videoPlayerView?.pause()
                if let cellVideoId {
                    VideoPlayerManager.shared.unregister(id: cellVideoId, scope: VideoPlayerScope.gallery)
                }
            }
        }
        
        // 2. Sécurité : décharge tous les IDs du scope manager sauf celui de la vidéo animée (si d'autres sont "ghostés")
        let allRegisteredIds = Set(VideoPlayerManager.shared.playersByScope[VideoPlayerScope.gallery]?.keys ?? [String: WeakBox]().keys)
        for id in allRegisteredIds {
            if id != videoId {
                print("   • Unregister manager-only video id: \(id)")
                VideoPlayerManager.shared.unregister(id: id, scope: VideoPlayerScope.gallery)
            }
        }
        
        let remainingIds = Set(VideoPlayerManager.shared.playersByScope[VideoPlayerScope.gallery]?.keys ?? [String: WeakBox]().keys)
        if remainingIds.isEmpty {
            print("🟡 [Coordinator] Aucun player actif dans .gallery après nettoyage.")
        } else {
            print("🟢 [Coordinator] Players restants dans .gallery après nettoyage:")
            for id in remainingIds {
                let isHero = (id == videoId) ? " (HERO)" : ""
                let desc = VideoPlayerManager.shared.playersByScope[VideoPlayerScope.gallery]?[id]?.value
                    .map { String(describing: type(of: $0)) } ?? "nil"
                print("   - id: \(id)\(isHero) => \(desc)")
            }
        }
        
        
        UIView.animate(
            withDuration: 0.45,
            delay: 0,
            usingSpringWithDamping: 0.95,
            initialSpringVelocity: 0.6,
            options: [.curveEaseOut],
            animations: {
                videoView.frame = destFrame
                videoView.layer.cornerRadius = destCornerRadius
                overlaySnapshot.frame = destFrame
                overlaySnapshot.layer.cornerRadius = destCornerRadius
                overlaySnapshot.alpha = 1
                galleryVC.galleryView.transform = CGAffineTransform(scaleX: UIConstant.view.zoomScale, y: UIConstant.view.zoomScale)
                container.feedVC.scaleHomeView(forTransition: UIConstant.view.zoomScale, animated: false)
            },
            completion: { _ in
                videoView.removeFromSuperview()
                overlaySnapshot.removeFromSuperview()
                // Replace la vidéo dans la bonne cellule du feed (toujours sharedVideoView)
                let indexPath = IndexPath(item: 0, section: 0)
                if let cell = container.feedVC.collectionView.cellForItem(at: indexPath) as? FeedCell {
                    let feedMediaView = cell.mediaView
                    feedMediaView.addSubview(videoView)
                    videoView.frame = feedMediaView.bounds
                    videoView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
                    VideoPlayerManager.shared.unregister(id: videoId, scope: VideoPlayerScope.gallery)
                    VideoPlayerManager.shared.register(videoView, id: videoId, scope: VideoPlayerScope.feed)
                    cell.overlayView.isHidden = false
                    cell.overlayView.alpha = 1
                    cell.overlayView.configure(with: post)
                } else {
                    print("❗️[Coordinator] No FeedCell found at \(indexPath) after reload")
                }
                self.screenState = .feed
                container.feedVC.view.isHidden = false
                container.view.bringSubviewToFront(container.feedVC.view)
                container.feedVC.view.alpha = 1
                container.feedVC.scaleHomeView(forTransition: 1, animated: false)
            }
        )
        return
        
        // ===========================
        // === 2. CAS IMAGE HERO ====
        // ===========================
        guard let imageView = mediaView.subviews.first(where: { $0 is UIImageView }) as? UIImageView,
              let image = imageView.image else { return }
        
        let proxy = UIImageView(image: image)
        proxy.contentMode = .scaleAspectFill
        proxy.clipsToBounds = true
        proxy.layer.cornerRadius = mediaView.layer.cornerRadius
        proxy.frame = startFrame
        window.addSubview(proxy)
        mediaView.isHidden = true
        
        overlayView.frame = CGRect(x: -9999, y: -9999, width: destFrame.width, height: destFrame.height)
        overlayView.configure(with: post)
        overlayView.applySafeAreaInsets(NSDirectionalEdgeInsets(edgeInsets: container.feedVC.view.safeAreaInsets))
        container.view.addSubview(overlayView)
        overlayView.setNeedsLayout()
        overlayView.layoutIfNeeded()
        guard let overlaySnapshot = overlayView.snapshotView(afterScreenUpdates: true) else {
            overlayView.removeFromSuperview()
            return
        }
        overlayView.removeFromSuperview()
        overlaySnapshot.frame = startFrame
        overlaySnapshot.layer.cornerRadius = mediaView.layer.cornerRadius
        overlaySnapshot.alpha = 0
        window.addSubview(overlaySnapshot)
        
        // Crée la nouvelle liste de posts pour le feed (le post cliqué d'abord)
        for p in allPosts where p.id != post.id { feedPosts.append(p) }
        container.feedVC.posts = feedPosts
        container.feedVC.cellControllers = [:]
        container.feedVC.collectionView.reloadData()
        container.feedVC.view.layoutIfNeeded()
        container.feedVC.configure(for: post, media: media)
        self.lastOpenedGalleryIndexPath = originIndexPath
        self.screenState = .feed
        
        UIView.animate(withDuration: 0.35,
                       delay: 0,
                       usingSpringWithDamping: 0.95,
                       initialSpringVelocity: 0.6,
                       options: [.curveEaseOut],
                       animations: {
            proxy.frame = destFrame
            proxy.layer.cornerRadius = destCornerRadius
            overlaySnapshot.frame = destFrame
            overlaySnapshot.layer.cornerRadius = destCornerRadius
            overlaySnapshot.alpha = 1
            galleryVC.galleryView.transform = CGAffineTransform(scaleX: UIConstant.view.zoomScale, y: UIConstant.view.zoomScale)
            container.feedVC.scaleHomeView(forTransition: UIConstant.view.zoomScale, animated: false)
        }, completion: { _ in
            proxy.removeFromSuperview()
            overlaySnapshot.removeFromSuperview()
            let indexPath = IndexPath(item: 0, section: 0)
            if let cell = container.feedVC.collectionView.cellForItem(at: indexPath) as? FeedCell {
                cell.overlayView.isHidden = false
                cell.overlayView.alpha = 1
                cell.overlayView.configure(with: post)
            }
            self.screenState = .feed
            container.feedVC.view.isHidden = false
            container.view.bringSubviewToFront(container.feedVC.view)
            container.feedVC.view.alpha = 1
            container.feedVC.scaleHomeView(forTransition: 1, animated: false)
        })
    }
    
    
    func dismissFeedToMap(_ container: FeedContainerViewController) {
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
    
    func dimissFeedToGallery(_ container: FeedContainerViewController) {
        print("===== [DISMISS FEED TO GALLERY] =====")
        guard
            let indexPath = container.feedVC.collectionView.indexPathsForVisibleItems.first,
            let feedCell = container.feedVC.collectionView.cellForItem(at: indexPath) as? FeedCell,
            let window = container.view.window
        else {
            print("❌ [Dismiss] Pas de feedCell/Window")
            removeFeed(in: container, animated: false)
            return
        }

        let targetIndexPath: IndexPath = lastOpenedGalleryIndexPath
        container.galleryVC.galleryView.collectionView.layoutIfNeeded()
        container.feedVC.collectionView.layoutIfNeeded()
        feedCell.setNeedsLayout()
        feedCell.layoutIfNeeded()

        guard let destCell = container.galleryVC.galleryView.collectionView.cellForItem(at: targetIndexPath) as? GalleryCell else {
            print("❌ [Dismiss] Pas de destCell à \(targetIndexPath)")
            removeFeed(in: container, animated: false)
            return
        }

        let destView = destCell.mediaView
        let mediaView = feedCell.mediaView
        mediaView.setNeedsLayout()
        mediaView.layoutIfNeeded()

        // Préparation commune
        let startFrame: CGRect
        let galleryScale = container.galleryVC.view.transform.a
        let endFrameRaw = destView.convert(destView.bounds, to: window)
        let endFrame = endFrameRaw.unscaledFrame(relativeTo: window, scale: galleryScale)

        // Overlay snapshot (commun aux deux cas)
        let overlayView = feedCell.overlayView
        let overlaySnapshot = overlayView.snapshotView(afterScreenUpdates: false)
        if let overlaySnapshot = overlaySnapshot {
            overlaySnapshot.frame = overlayView.convert(overlayView.bounds, to: window).unscaledFrame(relativeTo: window, scale: galleryScale)
            overlaySnapshot.clipsToBounds = true
            overlaySnapshot.layer.cornerRadius = container.feedVC.contentView.layer.cornerRadius * container.feedVC.contentView.transform.a
            window.addSubview(overlaySnapshot)
        }
        overlayView.alpha = 0

        // CAS VIDÉO
        if let media = mediaView.currentMedia, media.isVideo {
            let videoId = media.id.uuidString
            guard let videoView = playerAssignments[videoId] else {
                print("❗️[Dismiss] No VideoPlayerView assigned for this videoId")
                return
            }

            if videoView.superview !== mediaView {
                print("⚠️ [Dismiss] videoView.superview != mediaView — forçage")
                mediaView.addSubview(videoView)
                videoView.frame = mediaView.bounds
                videoView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
                mediaView.setNeedsLayout()
                mediaView.layoutIfNeeded()
            }

            // Forcer layout avant conversion
            container.feedVC.view.layoutIfNeeded()
            feedCell.layoutIfNeeded()
            videoView.layoutIfNeeded()

            startFrame = videoView.convert(videoView.bounds, to: window)

            // Prépare le player pour animation
            videoView.layer.cornerRadius = container.feedVC.contentView.layer.cornerRadius * container.feedVC.contentView.transform.a
            videoView.clipsToBounds = true
            videoView.translatesAutoresizingMaskIntoConstraints = true
            videoView.removeFromSuperview()
            videoView.frame = startFrame
            window.addSubview(videoView)

            destView.isHidden = true

            UIView.animate(withDuration: 0.45,
                           delay: 0,
                           usingSpringWithDamping: 0.95,
                           initialSpringVelocity: 0.6,
                           options: [.curveEaseOut],
                           animations: {
                videoView.frame = endFrame
                videoView.layer.cornerRadius = destView.layer.cornerRadius
                overlaySnapshot?.frame = endFrame
                overlaySnapshot?.alpha = 0
                overlaySnapshot?.layer.cornerRadius = destView.layer.cornerRadius
                container.feedVC.view.alpha = 0.5
                container.galleryVC.galleryView.transform = .identity
                container.feedVC.scaleHomeView(forTransition: UIConstant.view.zoomScale, animated: false)
            }, completion: { _ in
                videoView.removeFromSuperview()
                overlaySnapshot?.removeFromSuperview()
                destView.isHidden = false

                destView.addSubview(videoView)
                videoView.frame = destView.bounds
                videoView.autoresizingMask = [.flexibleWidth, .flexibleHeight]

                if let videoId = mediaView.currentMedia?.id.uuidString {
                    VideoPlayerManager.shared.unregister(id: videoId, scope: VideoPlayerScope.feed)
                    VideoPlayerManager.shared.register(videoView, id: videoId, scope: VideoPlayerScope.gallery)
                }

                container.galleryVC.updateCurrentPlayingVideos(forcePlayCell: destCell)

                container.feedVC.contentView.transform = .identity
                container.feedVC.contentView.center = container.feedVC.view.center
                container.feedVC.contentView.layer.cornerRadius = 0
                container.feedVC.scaleHomeView(forTransition: 1, animated: false)

                self.removeFeed(in: container, animated: false)

                container.galleryVC.galleryView.collectionView.isScrollEnabled = true
                container.galleryVC.galleryView.collectionView.isUserInteractionEnabled = true
                self.screenState = .gallery
            })
        }
        // CAS IMAGE
        else {
            guard let imageView = mediaView.subviews.first(where: { $0 is UIImageView }) as? UIImageView,
                  let image = imageView.image else {
                print("❌ [Dismiss] Pas d'imageView dans la cellule Feed")
                removeFeed(in: container, animated: false)
                return
            }
            
            let proxy = UIImageView(image: image)
            proxy.contentMode = .scaleAspectFill
            proxy.clipsToBounds = true
            proxy.layer.cornerRadius = imageView.layer.cornerRadius
            proxy.layer.masksToBounds = true
            
            let apparentRadius = container.feedVC.contentView.layer.cornerRadius
            let appliedScale = container.feedVC.contentView.transform.a
            let ajustedBorder = apparentRadius * appliedScale
            proxy.layer.cornerRadius = ajustedBorder
            
            startFrame = imageView.convert(imageView.bounds, to: window)
            proxy.frame = startFrame
            window.addSubview(proxy)
            
            let destCornerRadius = destView.layer.cornerRadius

            imageView.isHidden = true
            destView.isHidden = true
            
            UIView.animate(withDuration: 0.35,
                           delay: 0,
                           usingSpringWithDamping: 0.95,
                           initialSpringVelocity: 0.6,
                           options: [.curveEaseOut],
                           animations: {
                proxy.frame = endFrame
                proxy.layer.cornerRadius = destCornerRadius
                overlaySnapshot?.frame = endFrame
                overlaySnapshot?.alpha = 0
                overlaySnapshot?.layer.cornerRadius = destCornerRadius
                container.feedVC.view.alpha = 0.5
                container.galleryVC.galleryView.transform = .identity
                container.feedVC.scaleHomeView(forTransition: UIConstant.view.zoomScale, animated: false)
            }, completion: { _ in
                proxy.removeFromSuperview()
                overlaySnapshot?.removeFromSuperview()
                destView.isHidden = false
                container.feedVC.view.alpha = 0
                container.feedVC.contentView.transform = .identity
                container.feedVC.contentView.center = container.feedVC.view.center
                container.feedVC.contentView.layer.cornerRadius = 0
                container.feedVC.scaleHomeView(forTransition: 1, animated: false)
                self.removeFeed(in: container, animated: false)
                container.galleryVC.galleryView.collectionView.isScrollEnabled = true
                container.galleryVC.galleryView.collectionView.isUserInteractionEnabled = true
                self.screenState = .gallery
                
                container.galleryVC.updateCurrentPlayingVideos()
            })
        }
    }
    
    private func removeFeed(in container: FeedContainerViewController, animated: Bool) {
        container.feedVC.view.isHidden = true
        container.view.bringSubviewToFront(container.galleryVC.view)
        if animated {
            UIView.animate(withDuration: 0.2) {
                container.galleryVC.view.alpha = 1
            }
        } else {
            container.galleryVC.view.alpha = 1
        }
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
        guard let galleryVC = self.galleryVC else { print("❌ [Coordinator] galleryVC nil"); return }
        let indexPath = lastOpenedGalleryIndexPath ?? IndexPath(item: 0, section: 1)
        guard let post = post else { print("❌ [Coordinator] post nil"); return }
        guard let feedVC = feedContainerVC?.feedVC else { print("❌ [Coordinator] feedVC nil"); return }
        guard let currentIndexPath = feedVC.collectionView.indexPathsForVisibleItems.first else {
            print("❌ [Coordinator] Pas d'indexPath visible"); return
        }
        
        // --- ESSAYER DE PASSER PAR LE CONTROLLER SI IL EST OK ---
        if let cellController = feedVC.cellControllers[currentIndexPath], !cellController.galleryItems.isEmpty {
            let media: MediaContent
            if let gallery = cellController.galleryItems[safe: cellController.currentIndex] {
                media = gallery
            } else if let mediaItem = cellController.galleryItems.first {
                media = mediaItem
            } else {
                print("🔴 [Coordinator] Pas de media dans cellController.galleryItems (should never happen here)")
                return
            }
            galleryVC.updateGalleryItem(at: indexPath, with: post, media: media)
            galleryVC.scrollToItemIfNeeded(at: indexPath)
            galleryVC.hideImageView(at: indexPath)
            return
        }
        
        // --- SINON, FALLBACK "SAFE" DIRECTEMENT AVEC LE MODEL DE DONNÉES ---
        print("⚠️ [Coordinator] Controller absent ou vide pour \(currentIndexPath). Fallback dataSource.")
        let fallbackPost = feedVC.posts[safe: currentIndexPath.item]
        let fallbackMedia: MediaContent?
        switch fallbackPost?.content {
        case .media(let m): fallbackMedia = m
        case .gallery(let medias): fallbackMedia = medias.first
        default: fallbackMedia = nil
        }
        guard let fallbackMedia = fallbackMedia, let fallbackPost = fallbackPost else {
            print("🔴 [Coordinator] fallbackPost/media KO")
            return
        }
        galleryVC.updateGalleryItem(at: indexPath, with: fallbackPost, media: fallbackMedia)
        galleryVC.scrollToItemIfNeeded(at: indexPath)
        galleryVC.hideImageView(at: indexPath)
    }
    
    func assignPlayerIfNeeded(to cell: GalleryCell, for media: MediaContent) {
        guard media.isVideo else { return }
        let videoId = media.id.uuidString

        // Si déjà assigné, on le rattache à la bonne MediaContainerView
        if let player = playerAssignments[videoId] {
            cell.mediaView.showVideoPlayer(player, for: media)
            return
        }
        if let player = sharedPlayerPool.first(where: { $0.superview == nil }) {
            if let url = media.url {
                playerAssignments[videoId] = player
                player.configure(with: url, id: media.id)
                cell.mediaView.showVideoPlayer(player, for: media)
            } else {
                cell.mediaView.hideVideoPlayer()
            }
        } else {
            cell.mediaView.hideVideoPlayer()
        }
    }

    // Quand une vidéo quitte le pool/écran
    func releasePlayer(for media: MediaContent) {
        let videoId = media.id.uuidString
        if let player = playerAssignments[videoId] {
            player.pause()
            player.removeFromSuperview()
            playerAssignments.removeValue(forKey: videoId)
        }
    }
}


//    func presentFeedFromGallery(
//        _ container: FeedContainerViewController,
//        galleryCell: GalleryCell,
//        post: Post.Model,
//        media: MediaContent,
//        originIndexPath: IndexPath
//    ) {
//        print("presentFeedFromGallery")
//        guard let window = container.view.window else { return }
//        self.screenState = .gallery
//        // Animation hero (proxy UIImageView)
//        let mediaView = galleryCell.mediaView
//        guard let imageView = mediaView.subviews.first(where: { $0 is UIImageView }) as? UIImageView,
//              let image = imageView.image else { return }
//
//        let startFrame = mediaView.convert(mediaView.bounds, to: window)
//        let proxy = UIImageView(image: image)
//        proxy.contentMode = .scaleAspectFill
//        proxy.clipsToBounds = true
//        proxy.layer.cornerRadius = mediaView.layer.cornerRadius
//        proxy.frame = startFrame
//        window.addSubview(proxy)
//        mediaView.isHidden = true
//
//        let endFrame = container.feedVC.view.convert(container.feedVC.view.bounds, to: window)
//        let destCornerRadius: CGFloat = 55
//
//        // 1. Construit le tableau de posts : le post tapé d'abord
//        let galleryVC = container.galleryVC
//        let allPosts = galleryVC.allPosts
//        var feedPosts: [Post.Model] = [post]
//        for p in allPosts where p.id != post.id { feedPosts.append(p) }
//
//        let overlayView = OverlayView()
//        overlayView.frame = CGRect(x: -9999, y: -9999, width: endFrame.width, height: endFrame.height)
//        overlayView.configure(with: post)
//        overlayView.applySafeAreaInsets(NSDirectionalEdgeInsets(edgeInsets: container.feedVC.view.safeAreaInsets))
//        // Pas de isHidden ici !
//        container.view.addSubview(overlayView)
//        overlayView.setNeedsLayout()
//        overlayView.layoutIfNeeded()
//
//        guard let overlaySnapshot = overlayView.snapshotView(afterScreenUpdates: true) else {
//            overlayView.removeFromSuperview()
//            return
//        }
//        overlayView.removeFromSuperview()
//
//        overlaySnapshot.frame = startFrame // même frame que le proxy image
//        overlaySnapshot.layer.cornerRadius = mediaView.layer.cornerRadius
//        overlaySnapshot.alpha = 0
//        window.addSubview(overlaySnapshot)
//
//        // Injecte les posts ET reset les cellControllers
//        container.feedVC.posts = feedPosts
//        container.feedVC.cellControllers = [:]
//        container.feedVC.collectionView.reloadData()
//        container.feedVC.view.layoutIfNeeded() // S'assurer que les cellules existent
//
//        // 3. Scroll/configure sur le post et média sélectionné
//        container.feedVC.configure(for: post, media: media)
//
//        self.lastOpenedGalleryIndexPath = originIndexPath
//        screenState = .feed
//
//        // 4. Animation hero puis affiche feedVC
//        UIView.animate(withDuration: 0.35,
//                       delay: 0,
//                       usingSpringWithDamping: 0.95,
//                       initialSpringVelocity: 0.6,
//                       options: [.curveEaseOut],
//                       animations: {
//            proxy.frame = endFrame
//            proxy.layer.cornerRadius = destCornerRadius
//            overlaySnapshot.frame = endFrame
//            overlaySnapshot.layer.cornerRadius = destCornerRadius
//            overlaySnapshot.alpha = 1
//            galleryVC.galleryView.transform = CGAffineTransform(scaleX: UIConstant.view.zoomScale, y: UIConstant.view.zoomScale)
//            container.feedVC.scaleHomeView(forTransition: UIConstant.view.zoomScale, animated: false)
//        }, completion: { _ in
//            proxy.removeFromSuperview()
//            overlaySnapshot.removeFromSuperview()
//
//            let indexPath = IndexPath(item: 0, section: 0) // ou l'index réel du post
//            if let cell = container.feedVC.collectionView.cellForItem(at: indexPath) as? FeedCell {
//                // 🔥 Forcer l'overlay à être visible
//                cell.overlayView.isHidden = false
//                cell.overlayView.alpha = 1
//                // (re)configure si besoin :
//                cell.overlayView.configure(with: post)
//            }
//            self.screenState = .feed
//            container.feedVC.view.isHidden = false
//            container.view.bringSubviewToFront(container.feedVC.view)
//            container.feedVC.view.alpha = 1
//            container.feedVC.scaleHomeView(forTransition: 1, animated: false)
//        })
//    }



//    func dimissFeedToGallery(_ container: FeedContainerViewController) {
//        guard
//            let indexPath = container.feedVC.collectionView.indexPathsForVisibleItems.first,
//            let feedCell = container.feedVC.collectionView.cellForItem(at: indexPath) as? FeedCell,
//            let window = container.view.window
//        else {
//            removeFeed(in: container, animated: false)
//            return
//        }
//        self.screenState = .feed
//        let targetIndexPath: IndexPath = lastOpenedGalleryIndexPath
//
//        // 1. Update la grille cible AVANT l'animation
//        container.galleryVC.galleryView.collectionView.layoutIfNeeded()
//
//        // 2. Récupère la cellule de destination (à jour)
//        guard let destCell = container.galleryVC.galleryView.collectionView.cellForItem(at: targetIndexPath) as? GalleryCell else {
//            removeFeed(in: container, animated: false)
//            return
//        }
//
//
//        let destView = destCell.mediaView
//        let mediaView = feedCell.mediaView
//
//        // 3. Prépare le proxy pour l'animation (image)
//        guard let imageView = mediaView.subviews.first(where: { $0 is UIImageView }) as? UIImageView,
//              let image = imageView.image else {
//            removeFeed(in: container, animated: false)
//            return
//        }
//        let proxy = UIImageView(image: image)
//        proxy.contentMode = .scaleAspectFill
//        proxy.clipsToBounds = true
//        proxy.layer.cornerRadius = imageView.layer.cornerRadius
//        proxy.layer.masksToBounds = true
//
//        let apparentRadius = container.feedVC.contentView.layer.cornerRadius
//        let appliedScale = container.feedVC.contentView.transform.a
//        let ajustedBorder = apparentRadius * appliedScale
//        proxy.layer.cornerRadius = ajustedBorder
//
//        // 4. Calcule les frames d'animation (corrigé avec scale de gallery)
//        let startFrame = imageView.convert(imageView.bounds, to: window)
//        let galleryScale = container.galleryVC.view.transform.a
//        let endFrameRaw = destView.convert(destView.bounds, to: window)
//        let endFrame = endFrameRaw.unscaledFrame(relativeTo: window, scale: galleryScale)
//        proxy.frame = startFrame
//        window.addSubview(proxy)
//
//        let destCornerRadius = destView.layer.cornerRadius
//
//        // 5. Prépare le snapshot de l'overlay si nécessaire
//        let overlayView = feedCell.overlayView
//        let overlaySnapshot = overlayView.snapshotView(afterScreenUpdates: false)
//        if let overlaySnapshot = overlaySnapshot {
//            overlaySnapshot.frame = overlayView.convert(overlayView.bounds, to: window).unscaledFrame(relativeTo: window, scale: galleryScale)
//            overlaySnapshot.clipsToBounds = true
//            overlaySnapshot.layer.cornerRadius = ajustedBorder
//            window.addSubview(overlaySnapshot)
//        }
//        // 6. Masque les views réelles pour éviter les artefacts pendant l'anim
//        imageView.isHidden = true
//        destView.isHidden = true
//        overlayView.alpha = 0
//
//        // 7. Lance l'animation
//        UIView.animate(withDuration: 0.35,
//                       delay: 0,
//                       usingSpringWithDamping: 0.95,
//                       initialSpringVelocity: 0.6,
//                       options: [.curveEaseOut],
//                       animations: {
//            proxy.frame = endFrame
//            proxy.layer.cornerRadius = destCornerRadius
//            overlaySnapshot?.frame = endFrame
//            overlaySnapshot?.alpha = 0
//            overlaySnapshot?.layer.cornerRadius = destCornerRadius
//            container.feedVC.view.alpha = 0.5
//            container.galleryVC.galleryView.transform = .identity
//            container.feedVC.scaleHomeView(forTransition: UIConstant.view.zoomScale, animated: false)
//
//        }, completion: { _ in
//            proxy.removeFromSuperview()
//            overlaySnapshot?.removeFromSuperview()
//            destView.isHidden = false
//
//            container.feedVC.view.alpha = 0
//            container.feedVC.contentView.transform = .identity
//            container.feedVC.contentView.center = container.feedVC.view.center
//            container.feedVC.contentView.layer.cornerRadius = 0
//            container.feedVC.scaleHomeView(forTransition: 1, animated: false)
//
//            self.removeFeed(in: container, animated: false)
//            container.galleryVC.galleryView.collectionView.isScrollEnabled = true
//            container.galleryVC.galleryView.collectionView.isUserInteractionEnabled = true
//            self.screenState = .gallery
//        })
//    }
