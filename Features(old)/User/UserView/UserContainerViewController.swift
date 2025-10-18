//
//  UserContainerViewController.swift
//  SocialMap
//
//  Created by Arnaud Maillet on 09/08/2025.
//

import UIKit

protocol UserContainerControllable: AnyObject {
    var containerView: UIView? { get }
    var containerViewController: UIViewController { get }
    var feedView: UIView? { get }
    var feedViewOverlayView: UIView? { get }
    var profileView: UIView? { get }
    var coordinatorDelegate: FeedCoordinatorDelegate? { get }
    var currentPost: Post.Model? { get }
    
    func animateFeedViewBackToOrigin()
    func scaleParentView(to scale: CGFloat, animated: Bool)
}

extension UserContainerViewController: UserContainerControllable {
    var containerViewController: UIViewController { self }
    var containerView: UIView? { view }
    var feedView: UIView? { feedVC.view }
    var feedViewOverlayView: UIView? { feedVC.currentOverlayView() }
    var profileView: UIView? { profileVC.view }
    var currentPost: Post.Model? { feedVC.currentPost ?? feedVC.viewModel.posts.first }
}

struct UserContainerViewControllerConfig {
    let rootVC: UIViewController
    let profileVC: ProfileViewController
    let feedVC: FeedViewController
    let coordinatorOnLeftExit: HeroDimissableStackScreen?
}

final class UserContainerViewController: UIViewController {

    // MARK: - Child VCs
    let rootVC: UIViewController
    let feedVC: FeedViewController
    let profileVC: ProfileViewController
    
    // MARK: - Coordination
    var didDismiss: (() -> Void)?
    var coordinator: UserContainerCoordinator?
    
    weak var coordinatorDelegate: FeedCoordinatorDelegate?
    weak var coordinatorOnLeftExit: HeroDimissableStackScreen?
    
    // MARK: - Gesture Handler
    private var gestureManager: FeedGestureManager?

    init(config: UserContainerViewControllerConfig) {
        self.rootVC = config.rootVC
        self.feedVC = config.feedVC
        self.profileVC = config.profileVC
        self.feedVC.exitDelegate = config.coordinatorOnLeftExit
        super.init(nibName: nil, bundle: nil)
        modalPresentationStyle = .custom
    }

    required init?(coder: NSCoder) { fatalError() }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.clipsToBounds = true

        embed(profileVC)
        embed(feedVC)
        configureFeedDisabledState()
    }

    deinit { didDismiss?() }

    private func embed(_ vc: UIViewController) {
        addChild(vc)
        view.addSubview(vc.view)
        vc.view.frame = view.bounds
        vc.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        vc.didMove(toParent: self)
    }
    
    private func setupGestures() {
//        guard
//            let coordinatorDelegate = debugUnwrap(coordinatorDelegate)
//        else { return }
//        
//        let gestureManager = FeedGestureManager(coordinatorDelegate: coordinatorDelegate)
//        gestureManager.attach(container: self, post: feedVC.currentPost ?? feedVC.posts.first!)
//        self.gestureManager = gestureManager
    }
    
    func enableFeedInteraction() {
        feedVC.view.alpha = 1
        feedVC.view.isUserInteractionEnabled = true
        feedVC.collectionView.isScrollEnabled = true
        view.bringSubviewToFront(feedVC.view) // au cas où
    }
    
    private func configureFeedDisabledState() {
        feedVC.view.alpha = 0            // invisible
        feedVC.view.isUserInteractionEnabled = false  // touches passent au profil
        feedVC.collectionView.isScrollEnabled = false
        // sécurité vidéos
        // VideoPlayerManager.shared.pauseAll() // si le feed a déjà attaché des players
    }
    
    func animateFeedViewBackToOrigin() {
        UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 0.96, initialSpringVelocity: 0.5, options: [.curveEaseOut], animations: {
            self.feedVC.view.transform = .identity
        }, completion: { _ in
            self.feedVC.view.center = self.feedVC.view.center
            self.feedVC.view.layer.cornerRadius = 0
            self.profileVC.view.transform = .identity
        })
    }
    
    func scaleParentView(to scale: CGFloat, animated: Bool = false) {
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
