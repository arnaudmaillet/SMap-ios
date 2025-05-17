//
//  HeroPresentAnimator.swift
//  SocialMap
//
//  Created by Arnaud Maillet on 23/04/2025.
//

import UIKit

// MARK: - HeroPresentAnimator

final class HeroPresentAnimator: NSObject, UIViewControllerAnimatedTransitioning {

    // MARK: - Properties

    private let originView: UIView
    private let originFrame: CGRect
    private let post: Post.Model
    private let isPresenting: Bool

    // MARK: - Init

    init(originView: UIView, originFrame: CGRect, post: Post.Model, isPresenting: Bool) {
        self.originView = originView
        self.originFrame = originFrame
        self.post = post
        self.isPresenting = isPresenting
    }

    // MARK: - Transition Duration

    func transitionDuration(using context: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.4
    }

    // MARK: - Animate Transition

    func animateTransition(using context: UIViewControllerContextTransitioning) {
        let container = context.containerView

        guard let toVC = context.viewController(forKey: .to) else {
            context.completeTransition(false)
            return
        }

        // If not presenting, skip (dismiss handled elsewhere)
        if !isPresenting {
            context.completeTransition(true)
            return
        }

        // Hide destination view until animation completes
        toVC.view.isHidden = true
        container.addSubview(toVC.view)

        // Create animating view from origin
        let animatedView = originView
        animatedView.removeFromSuperview()
        animatedView.frame = originFrame
        animatedView.layer.cornerRadius = 24
        animatedView.clipsToBounds = true
        container.addSubview(animatedView)

        // Create overlay snapshot
        let overlayVC = OverlayViewController()
        overlayVC.configure(with: post, safeAreaInsets: container.safeAreaInsets)
        overlayVC.view.frame = CGRect(x: -9999, y: -9999, width: toVC.view.bounds.width, height: toVC.view.bounds.height)
        container.addSubview(overlayVC.view)
        overlayVC.view.setNeedsLayout()
        overlayVC.view.layoutIfNeeded()

        guard let overlaySnapshot = overlayVC.view.snapshotView(afterScreenUpdates: true) else {
            overlayVC.view.removeFromSuperview()
            context.completeTransition(false)
            return
        }
        overlayVC.view.removeFromSuperview()

        // Style snapshot
        overlaySnapshot.alpha = 0
        overlaySnapshot.frame = originFrame
        overlaySnapshot.layer.cornerRadius = 24
        overlaySnapshot.clipsToBounds = true
        container.addSubview(overlaySnapshot)

        let finalFrame = toVC.view.frame

        // MARK: - Launch parallel map zoom-out animation
        if let toVC = context.viewController(forKey: .to) as? FeedViewController,
           let homeVC = toVC.delegate as? HomeViewController {
            let zoomAnimator = UIViewPropertyAnimator(duration: 0.4, dampingRatio: 0.8) {
                homeVC.contentView.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
            }
            zoomAnimator.startAnimation()
        }

        // MARK: - Launch transition
        UIView.animate(withDuration: transitionDuration(using: context),
                       delay: 0,
                       usingSpringWithDamping: 0.96,
                       initialSpringVelocity: 0.6,
                       options: [.curveEaseInOut],
                       animations: {
            animatedView.frame = finalFrame
            animatedView.layer.cornerRadius = 55
            animatedView.layer.borderWidth = 0
            animatedView.layer.borderColor = UIColor.clear.cgColor

            overlaySnapshot.frame = finalFrame
            overlaySnapshot.layer.cornerRadius = 55
            overlaySnapshot.alpha = 1
        }, completion: { _ in
            toVC.view.isHidden = false
            animatedView.removeFromSuperview()
            overlaySnapshot.removeFromSuperview()
            context.completeTransition(true)
        })
    }
}
