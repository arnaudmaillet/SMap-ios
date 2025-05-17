//
//  HeroDismissAnimator.swift
//  SocialMap
//
//  Created by Arnaud Maillet on 27/04/2025.
//

import UIKit

struct HeroDismissConfig {
    let sourceImageView: UIImageView
    let destinationImage: UIImage?
    let destinationFrame: CGRect
    let overlayView: UIView?
    let finalCornerRadius: CGFloat
    let finalBorderWidth: CGFloat
    let finalBorderColor: CGColor
    
    static func basic(from controller: FeedViewController, overlayView: UIView?) -> HeroDismissConfig? {
        guard let postImageView = controller.currentPostImageView else { return nil }
        
        return HeroDismissConfig(
            sourceImageView: postImageView,
            destinationImage: controller.originImage,
            destinationFrame: controller.originFrame,
            overlayView: overlayView,
            finalCornerRadius: 24,
            finalBorderWidth: 3,
            finalBorderColor: UIColor.accent.cgColor
        )
    }
}

final class HeroDismissAnimatorTransition: NSObject, UIViewControllerAnimatedTransitioning {
    private let config: HeroDismissConfig
    
    init(config: HeroDismissConfig) {
        self.config = config
    }
    
    func transitionDuration(using context: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.35
    }
    
    func animateTransition(using context: UIViewControllerContextTransitioning) {
        guard let fromVC = context.viewController(forKey: .from) else {
            context.completeTransition(false)
            return
        }
        
        HeroDismissAnimator.animateDismiss(config: config, from: fromVC) {
            context.completeTransition(true)
        }
    }
}

final class HeroDismissAnimator {
    
    static func animateDismiss(config: HeroDismissConfig, from controller: UIViewController, completion: @escaping () -> Void) {
        let container = controller.view
        
        let preview = UIImageView(image: config.sourceImageView.image)
        preview.frame = config.sourceImageView.convert(config.sourceImageView.bounds, to: container)
        preview.layer.cornerRadius = 55
        preview.contentMode = .scaleAspectFill
        preview.clipsToBounds = true
        container?.addSubview(preview)
        
        let fadeImageView = UIImageView(image: config.destinationImage)
        fadeImageView.frame = preview.bounds
        fadeImageView.contentMode = .scaleAspectFill
        fadeImageView.clipsToBounds = true
        fadeImageView.layer.cornerRadius = 55
        fadeImageView.alpha = 0
        preview.addSubview(fadeImageView)
        
        var overlaySnapshot: UIView?
        if let overlayView = config.overlayView {
            config.overlayView?.isHidden = true
            overlaySnapshot = overlayView.snapshotView(afterScreenUpdates: false)
            if let overlaySnapshot = overlaySnapshot {
                overlaySnapshot.frame = overlayView.convert(overlayView.bounds, to: container)
                overlaySnapshot.layer.cornerRadius = 55
                overlaySnapshot.clipsToBounds = true
                overlaySnapshot.alpha = 1
                container?.addSubview(overlaySnapshot)
            }
        }
        
        (controller as? FeedViewController)?.hideFeedContent()
        controller.view.superview?.backgroundColor = .clear
        
        UIView.animate(withDuration: 0.25) {
            fadeImageView.alpha = 1
        }
        
        UIView.animate(withDuration: 0.35,
                       delay: 0,
                       usingSpringWithDamping: 0.95,
                       initialSpringVelocity: 0.6,
                       options: [.curveEaseOut],
                       animations: {
            
            if let feedController = controller as? FeedViewController {
                let zoomAnimator = UIViewPropertyAnimator(duration: 0.2, curve: .easeOut) {
                    if let homeVC = feedController.delegate as? HomeViewController {
                        homeVC.contentView.transform = .identity
                        homeVC.contentView.alpha = 1
                    }
                }
                zoomAnimator.startAnimation()
            }
            
            if let feedController = controller as? FeedViewController,
               let targetFrame = feedController.delegate?.currentAnnotationFrameInWindow() {
                preview.frame = targetFrame
                fadeImageView.frame = preview.bounds
                overlaySnapshot?.frame = targetFrame
            } else {
                preview.frame = config.destinationFrame
                fadeImageView.frame = preview.bounds
                overlaySnapshot?.frame = config.destinationFrame
            }
            
            preview.layer.cornerRadius = config.finalCornerRadius
            preview.layer.borderWidth = config.finalBorderWidth
            preview.layer.borderColor = config.finalBorderColor
            fadeImageView.layer.cornerRadius = config.finalCornerRadius
            
            if let overlaySnapshot = overlaySnapshot {
                UIView.animate(withDuration: 0.4) {
                    overlaySnapshot.alpha = 0
                }
            }
        }, completion: { _ in
            if let feedController = controller as? FeedViewController,
               let homeVC = feedController.delegate as? HomeViewController,
               let annotation = homeVC.lastSelectedAnnotation {

                feedController.delegate?.feedDidDismiss()

                homeVC.waitUntilAnnotationIsRendered(annotation) {
                    completion() // ici seulement, la transition est validée
                }
            } else {
                completion()
            }
        })
    }
}
