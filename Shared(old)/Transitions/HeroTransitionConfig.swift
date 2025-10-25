//
//  HeroTransition.swift
//  SocialMap
//
//  Created by Arnaud Maillet on 17/05/2025.
//

import UIKit

protocol HeroTransitionVisuals {
    var transitionCornerRadius: CGFloat { get }
    var transitionBorderWidth: CGFloat { get }
    var transitionBorderColor: CGColor { get }
}


// MARK: - HeroTransitionConfig (commun à Present & Dismiss)

struct HeroTransitionConfig: HeroTransitionVisuals {
    // Vue source (animation de départ)
    let originView: UIView
    let originFrame: CGRect
    let post: Post.Model
    
    // Image cible pour le dismiss (optionnelle)
    let destinationImage: UIImage?
    
    // Frame de destination finale (dismiss)
    let destinationFrame: CGRect?
    
    // OverlayView (optionnel)
    let overlayView: UIView?
    
    // Apparence visuelle finale
    let cornerRadius: CGFloat
    let borderWidth: CGFloat
    let borderColor: CGColor
    
    let initialPostImage: UIImage?
    
    var transitionCornerRadius: CGFloat { cornerRadius }
    var transitionBorderWidth: CGFloat { borderWidth }
    var transitionBorderColor: CGColor { borderColor }
    
    // MARK: - Usines
    
    static func forPresentation(
        from originView: UIView,
        frame: CGRect,
        post: Post.Model,
        overlayView: UIView?,
        initialPostImage: UIImage? = nil
    ) -> HeroTransitionConfig {
        return HeroTransitionConfig(
            originView: originView,
            originFrame: frame,
            post: post,
            destinationImage: nil,
            destinationFrame: nil,
            overlayView: overlayView,
            cornerRadius: UIConstant.device.cornerRadius,
            borderWidth: 0,
            borderColor: UIColor.clear.cgColor,
            initialPostImage: initialPostImage
        )
    }
    
    static func forDismissalToMap(
        from containerVC: FeedContainerViewController,
        rootVC: UIViewController,
        post: Post.Model,
        originalPost: Post.Model?
    ) -> HeroTransitionConfig? {
        guard let window = rootVC.view.window else {
            print("❌ [HeroTransitionConfig] window indisponible (homeVC?.view.window == nil)")
            return nil
        }
        
        guard let homeVC = rootVC as? HomeVC else {
            print("❌ [HeroTransitionConfig] homeVC non trouvé (rootVC n'est pas d'type HomeVC)")
            return nil
        }
        
        let destinationFrame: CGRect
        if let frame = homeVC.currentAnnotationFrameInWindow() {
            destinationFrame = frame
        } else {
            let size: CGFloat = 24
            destinationFrame = CGRect(
                x: window.bounds.midX - size / 2,
                y: window.bounds.midY - size / 2,
                width: size, height: size
            )
            print("⚠️ [HeroTransitionConfig] destinationFrame indisponible — fallback au centre : \(destinationFrame)")
        }
        
        guard let snapshotView = containerVC.view.snapshotView(afterScreenUpdates: false) else {
            print("❌ [HeroTransitionConfig] snapshotView est nil (échec création snapshot du containerVC.view)")
            return nil
        }
        
        let frameInWindow = containerVC.view.convert(containerVC.view.bounds, to: window)
        snapshotView.frame = frameInWindow

        let initialPostImage = originalPost?.mainRenderable?.thumbnailImage
        
        // ——— Le choix du destinationImage
        let destinationImage: UIImage?
        destinationImage = post.mainRenderable?.thumbnailImage
        
        return HeroTransitionConfig(
            originView: snapshotView,
            originFrame: frameInWindow,
            post: post,
            destinationImage: destinationImage,
            destinationFrame: destinationFrame,
            overlayView: nil,
            cornerRadius: 24,
            borderWidth: 3,
            borderColor: UIColor.accent.cgColor,
            initialPostImage: initialPostImage
        )
    }
}

