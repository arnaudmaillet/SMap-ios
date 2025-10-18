//
//  FeedContainerViewController.swift
//  SocialMap
//
//  Created by Arnaud Maillet on 27/06/2025.
//

import UIKit

protocol FeedContainerControllable: AnyObject {
    var container: UIViewController { get }
    var containerView: UIView? { get }
    var feedView: UIView? { get }
    var galleryView: UIView? { get }
    var overlayView: UIView? { get }
    var coordinatorDelegate: FeedCoordinatorDelegate? { get }
    var currentPost: Post.Model? { get }
    func resetDismissAnimation(to position: CGPoint?)
    func scaleHomeView(to scale: CGFloat, animated: Bool)
}

extension FeedContainerViewController: FeedContainerControllable {
    var container: UIViewController { self }
    var containerView: UIView? { view }
    var feedView: UIView? { feedVC.view }
    var galleryView: UIView? { galleryVC.view }
    var overlayView: UIView? { feedVC.currentOverlayView() }
    var currentPost: Post.Model? { feedVC.currentPost ?? feedVC.viewModel.posts.first }
}

struct FeedContainerViewControllerConfig {
    let rootVC: UIViewController
    let galleryVC: GalleryViewController
    let feedVC: FeedViewController
    let coordinatorOnRightExit: FeedOnRightExitSide?
    let coordinatorDelegate: FeedCoordinatorDelegate?
}

final class FeedContainerViewController: UIViewController {

    // MARK: - Child ViewControllers

    let rootVC: UIViewController
    let galleryVC: GalleryViewController
    let feedVC: FeedViewController

    // MARK: - Gesture Handler

    private var gestureManager: FeedGestureManager?
    private var gestureHandler: FeedGestureHandler?

    // MARK: - Delegation & Coordination

    weak var coordinatorDelegate: FeedCoordinatorDelegate?
    weak var coordinatorExit: FeedOnRightExitSide?

    // MARK: - Init

    init(config: FeedContainerViewControllerConfig) {
        self.rootVC = config.rootVC
        self.galleryVC = config.galleryVC
        self.feedVC = config.feedVC
        self.coordinatorExit = config.coordinatorOnRightExit
        self.feedVC.exitDelegate = config.coordinatorDelegate
        self.coordinatorDelegate = config.coordinatorDelegate

        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) { fatalError() }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        setupHierarchy()
        setupGestures()
        
        view.clipsToBounds = true
    }

    // MARK: - Setup

    private func setupHierarchy() {
        embed(galleryVC)
        embed(feedVC)
    }

    private func embed(_ vc: UIViewController) {
        addChild(vc)
        view.addSubview(vc.view)
        vc.view.frame = view.bounds
        vc.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        vc.didMove(toParent: self)
    }

    private func setupGestures() {
        guard
            let coordinatorDelegate = debugUnwrap(coordinatorDelegate),
            let coordinatorExit = debugUnwrap(coordinatorExit)
        else { return }
        
        let gestureManager = FeedGestureManager(coordinatorDelegate: coordinatorDelegate, coordinatorOnRightExit: coordinatorExit)
        gestureManager.attach(container: self, post: feedVC.currentPost ?? feedVC.viewModel.posts.first!)
        self.gestureManager = gestureManager
    }

    // MARK: - Public API (used by coordinator or gestureHandler)

    func scaleHomeView(to scale: CGFloat, animated: Bool = false) {
        let transform = CGAffineTransform(scaleX: scale, y: scale)
        if animated {
            UIView.animate(withDuration: 0.25) {
                self.rootVC.view.transform = transform
            }
        } else {
            rootVC.view.transform = transform
        }
    }
}

// MARK: - API Ponts optionnels

extension FeedContainerViewController {
    
    func presentFeedFromGallery(_ cell: GalleryCell, post: Post.Model, media: MediaContent, from indexPath: IndexPath) {
        coordinatorDelegate?.presentFeedFromGallery(self, galleryCell: cell, post: post, media: media, originIndexPath: indexPath)
    }
    
    func resetDismissAnimation(to position: CGPoint?) {
        UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 0.96, initialSpringVelocity: 0.5, options: [.curveEaseOut], animations: {
            self.feedVC.view.transform = .identity
        }, completion: { _ in
            self.feedVC.view.center = position ?? self.feedVC.view.center
            self.feedVC.view.layer.cornerRadius = 0
            self.galleryVC.galleryView.transform = .identity
        })
    }
}

