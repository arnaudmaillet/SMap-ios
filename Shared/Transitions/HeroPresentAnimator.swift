//
//  HeroTransitionAnimator.swift
//  SocialMap
//
//  Created by Arnaud Maillet on 23/04/2025.
//


import UIKit

final class HeroTransitionAnimator: NSObject, UIViewControllerAnimatedTransitioning {
    private let originView: UIView
    private let originFrame: CGRect
    private let post: Post.Model
    private let isPresenting: Bool
    
    init(originView: UIView, originFrame: CGRect, post: Post.Model, isPresenting: Bool) {
        self.originView = originView
        self.originFrame = originFrame
        self.post = post
        self.isPresenting = isPresenting
    }
    
    func transitionDuration(using context: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.4
    }
    
    func animateTransition(using context: UIViewControllerContextTransitioning) {
        let container = context.containerView
        
        guard let toVC = context.viewController(forKey: .to) else { return }
        
        if !isPresenting {
            context.completeTransition(true)
            return
        }
        
        
        toVC.view.isHidden = true
        container.addSubview(toVC.view)
        
        // 1. Animated view (media)
        let animatedView = originView
        animatedView.removeFromSuperview()
        animatedView.frame = originFrame
        animatedView.layer.cornerRadius = 24
        animatedView.clipsToBounds = true
        container.addSubview(animatedView)
        
        // 2. Snapshot overlay
        let fullOverlay = PostOverlayView()
        fullOverlay.frame = toVC.view.bounds
        fullOverlay.frame.origin = CGPoint(x: -9999, y: 0) // sécurité visuelle
        container.addSubview(fullOverlay)
        
        fullOverlay.configure(with: post, safeAreaInsets: container.safeAreaInsets) {
            fullOverlay.layoutIfNeeded()
            
            guard let overlaySnapshot = fullOverlay.snapshotView(afterScreenUpdates: true) else {
                fullOverlay.removeFromSuperview()
                return
            }
            
            fullOverlay.removeFromSuperview()
            
            let initialOverlayFrame = container.convert(self.originView.bounds, from: self.originView)
            overlaySnapshot.frame = initialOverlayFrame
            overlaySnapshot.layer.cornerRadius = 24
            overlaySnapshot.clipsToBounds = true
            overlaySnapshot.alpha = 0
            container.addSubview(overlaySnapshot)
            
            let finalFrame = toVC.view.frame
            
            UIView.animate(withDuration: self.transitionDuration(using: context),
                           delay: 0,
                           usingSpringWithDamping: 0.96,
                           initialSpringVelocity: 0.6,
                           options: [.curveEaseInOut],
                           animations: {
                animatedView.frame = finalFrame
                animatedView.layer.cornerRadius = 55
                animatedView.layer.borderWidth = 0
                animatedView.layer.borderColor = UIColor.clear.cgColor
                container.backgroundColor = UIColor.black.withAlphaComponent(0.4)
                
                overlaySnapshot.frame = finalFrame
                overlaySnapshot.layer.cornerRadius = 55
                overlaySnapshot.alpha = 1
            }, completion: { _ in
                toVC.view.isHidden = false
                animatedView.removeFromSuperview()
                overlaySnapshot.removeFromSuperview()
                context.completeTransition(true)
                container.backgroundColor = UIColor.clear
            })
        }
    }
}
