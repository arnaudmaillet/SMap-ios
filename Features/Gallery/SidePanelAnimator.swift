//
//  GallerySlideAnimator.swift
//  SocialMap
//
//  Created by Arnaud Maillet on 20/06/2025.
//

import UIKit

final class UserProfileSlideAnimator: NSObject, UIViewControllerAnimatedTransitioning {
    private let isPresenting: Bool
    private let duration: TimeInterval = 0.3

    init(isPresenting: Bool) { self.isPresenting = isPresenting }

    func transitionDuration(using ctx: UIViewControllerContextTransitioning?) -> TimeInterval {
        return duration
    }

    func animateTransition(using ctx: UIViewControllerContextTransitioning) {
        let container = ctx.containerView
        let toVC = ctx.viewController(forKey: .to)!
        let fromVC = ctx.viewController(forKey: .from)!
        let width = container.bounds.width
        let delegate = (fromVC.transitioningDelegate as? UserProfileTransitioningDelegate)
            ?? (toVC.transitioningDelegate as? UserProfileTransitioningDelegate)

        let resetInteractiveTransition: () -> Void = {
            delegate?.interactiveTransition = nil
        }

        if isPresenting {
            container.addSubview(toVC.view)
            toVC.view.frame = container.bounds.offsetBy(dx: width, dy: 0)

            // Applique le corner radius dès le début du slide
            fromVC.view.layer.cornerRadius = UIConstant.device.cornerRadius
            fromVC.view.layer.masksToBounds = true

            UIView.animate(withDuration: duration, delay: 0, options: [.curveEaseOut], animations: {
                toVC.view.frame = container.bounds
                fromVC.view.transform = CGAffineTransform(scaleX: UIConstant.view.zoomScale, y: UIConstant.view.zoomScale)
            }, completion: { finished in
                resetInteractiveTransition()
                if ctx.transitionWasCancelled {
                    toVC.view.frame = container.bounds.offsetBy(dx: width, dy: 0)
                    fromVC.view.transform = .identity
                    fromVC.view.layer.cornerRadius = 0
                    toVC.view.removeFromSuperview()
                    ctx.completeTransition(false)
                } else {
                    fromVC.view.layer.cornerRadius = 0
                    ctx.completeTransition(true)
                }
            })
        } else {
            UIView.animate(withDuration: duration, delay: 0, options: [.curveEaseOut], animations: {
                fromVC.view.frame = container.bounds.offsetBy(dx: width, dy: 0)
                toVC.view.transform = .identity
            }, completion: { finished in
                resetInteractiveTransition()
                toVC.view.layer.cornerRadius = 0 // Reset aussi ici si besoin
                ctx.completeTransition(!ctx.transitionWasCancelled)
            })
        }
    }
}
