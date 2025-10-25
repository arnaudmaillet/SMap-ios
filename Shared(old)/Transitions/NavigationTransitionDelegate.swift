//
//  NavigationPresentTransitionDelegate.swift
//  SocialMap
//
//  Created by Arnaud Maillet on 18/04/2025.
//

import UIKit

final class NavigationTransitionDelegate: NSObject, UIViewControllerTransitioningDelegate {

    // MARK: - Properties

    private let originView: UIView
    private let originFrame: CGRect
    private let post: Post.Model
    private let originalPost: Post.Model?
    let rootVC: UIViewController

    var onHeroPresentDidFinish: (() -> Void)?

    // MARK: - Init

    init(originView: UIView, originFrame: CGRect, post: Post.Model, originalPost: Post.Model?, rootVC: UIViewController) {
        self.originView = originView
        self.originFrame = originFrame
        self.post = post
        self.originalPost = originalPost
        self.rootVC = rootVC
    }

    // MARK: - Presentation

    func animationController(
        forPresented presented: UIViewController,
        presenting: UIViewController,
        source: UIViewController
    ) -> UIViewControllerAnimatedTransitioning? {
        let overlayView = source.view
        // Passe bien l’image d’origine
        let initialPostImage = originalPost?.mainRenderable?.thumbnailImage
        let config = HeroTransitionConfig.forPresentation(
            from: originView,
            frame: originFrame,
            post: post,
            overlayView: overlayView,
            initialPostImage: initialPostImage
        )
        return HeroPresentAnimator(config: config, transitionDelegate: self)
    }

    // MARK: - Dismissal

    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        if let containerVC = dismissed as? FeedContainerViewController,
           let post = containerVC.feedVC.currentPost {
            if let config = HeroTransitionConfig.forDismissalToMap(
                from: containerVC,
                rootVC: rootVC,
                post: post,
                originalPost: originalPost
            ) {
                return HeroDismissAnimator(config: config, rootVC: rootVC)
            }
        }
        return nil
    }
}
