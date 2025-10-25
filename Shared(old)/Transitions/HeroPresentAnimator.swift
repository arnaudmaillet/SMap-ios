//
//  HeroPresentAnimator.swift
//  SocialMap
//
//  Created by Arnaud Maillet on 23/04/2025.
//



import UIKit

final class HeroPresentAnimator: NSObject, UIViewControllerAnimatedTransitioning {

    // MARK: - Properties

    private let config: HeroTransitionConfig
    private weak var transitionDelegate: NavigationTransitionDelegate?

    // MARK: - Init

    init(config: HeroTransitionConfig, transitionDelegate: NavigationTransitionDelegate?) {
        self.config = config
        self.transitionDelegate = transitionDelegate
    }

    // MARK: - Duration

    func transitionDuration(using context: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.4
    }

    // MARK: - Main Animation

    func animateTransition(using context: UIViewControllerContextTransitioning) {
        let container = context.containerView

        guard let toVC = context.viewController(forKey: .to) else {
            context.completeTransition(false)
            return
        }
        
        let rootVC = transitionDelegate?.rootVC
        container.addSubview(toVC.view)

        // MARK: - Initial values from originView

        let initialCornerRadius = config.originView.layer.cornerRadius
        let initialBorderWidth = config.originView.layer.borderWidth
        let initialBorderColor = config.originView.layer.borderColor

        // MARK: - Setup animatedView (clone from origin)

        let animatedView = config.originView
        animatedView.removeFromSuperview()
        animatedView.frame = config.originFrame
        animatedView.layer.cornerRadius = initialCornerRadius
        animatedView.layer.borderWidth = initialBorderWidth
        animatedView.layer.borderColor = initialBorderColor
        animatedView.clipsToBounds = true
        container.addSubview(animatedView)
        // MARK: - Setup overlay snapshot

        let overlayView = OverlayView()
        overlayView.frame = CGRect(x: -9999, y: -9999, width: toVC.view.bounds.width, height: toVC.view.bounds.height)
        overlayView.configure(with: config.post)
        overlayView.applySafeAreaInsets(NSDirectionalEdgeInsets(edgeInsets: toVC.view.safeAreaInsets))
        
        container.addSubview(overlayView)
        overlayView.setNeedsLayout()
        overlayView.layoutIfNeeded()

        guard let overlaySnapshot = overlayView.snapshotView(afterScreenUpdates: true) else {
            overlayView.removeFromSuperview()
            context.completeTransition(false)
            return
        }
        overlayView.removeFromSuperview()
        
        overlaySnapshot.alpha = 0
        overlaySnapshot.frame = config.originFrame
        overlaySnapshot.layer.cornerRadius = initialCornerRadius
        overlaySnapshot.clipsToBounds = true
        container.addSubview(overlaySnapshot)

        // MARK: - Optional map zoom-out animation
        if let homeVC = rootVC as? HomeVC {
            UIViewPropertyAnimator(duration: 0.4, dampingRatio: 0.8) {
                homeVC.view.transform = CGAffineTransform(scaleX: UIConstant.view.zoomScale, y: UIConstant.view.zoomScale)
            }.startAnimation()
        }

        // MARK: - Animate transition

        let finalFrame = toVC.view.frame
        toVC.view.isHidden = true
        
        UIView.animate(withDuration: transitionDuration(using: context),
                       delay: 0,
                       usingSpringWithDamping: 0.96,
                       initialSpringVelocity: 0.6,
                       options: [.curveEaseInOut],
                       animations: {
            animatedView.frame = finalFrame
            animatedView.layer.cornerRadius = self.config.cornerRadius
            animatedView.layer.borderWidth = self.config.borderWidth
            animatedView.layer.borderColor = self.config.borderColor

            overlaySnapshot.frame = finalFrame
            overlaySnapshot.layer.cornerRadius = self.config.cornerRadius
            overlaySnapshot.alpha = 1
        }, completion: { _ in
            animatedView.removeFromSuperview()
            overlaySnapshot.removeFromSuperview()
            context.completeTransition(true)
            toVC.view.isHidden = false
            self.transitionDelegate?.onHeroPresentDidFinish?()
        })
    }
}
