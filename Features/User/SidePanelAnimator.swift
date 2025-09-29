//
//  SidePanelAnimator.swift
//  SocialMap
//
//  Created by Arnaud Maillet on 20/06/2025.
//

import UIKit

final class SidePanelAnimator: NSObject, UIViewControllerAnimatedTransitioning {
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
        print("🎬 [Animator] isPresenting: \(isPresenting)")
        print("📐 [Animator] Container bounds: \(container.bounds)")

        if isPresenting {
            container.addSubview(toVC.view)
            toVC.view.frame = container.bounds.offsetBy(dx: width, dy: 0)
            print("📍 [Animator] toVC initial frame: \(toVC.view.frame)")

            UIView.animate(withDuration: duration, animations: {
                toVC.view.frame = container.bounds
            }, completion: { finished in
                ctx.completeTransition(!ctx.transitionWasCancelled)
            })
        } else {
            UIView.animate(withDuration: duration, animations: {
                fromVC.view.frame = container.bounds.offsetBy(dx: width, dy: 0)
                toVC.view.transform = .identity
            }, completion: { finished in
                ctx.completeTransition(!ctx.transitionWasCancelled)
            })
        }
    }
}
