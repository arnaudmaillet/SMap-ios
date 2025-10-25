//
//  HeroDismissAnimator.swift
//  SocialMap
//
//  Created by Arnaud Maillet on 27/04/2025.
//

import UIKit
import MapKit

final class HeroDismissAnimator: NSObject, UIViewControllerAnimatedTransitioning {

    // MARK: - Properties

    private let config: HeroTransitionConfig
    private var rootVC: UIViewController

    // MARK: - Init

    init(config: HeroTransitionConfig, rootVC: UIViewController) {
        self.config = config
        self.rootVC = rootVC
    }


    // MARK: - Transition duration

    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.35
    }

    // MARK: - Main animation
    
    func animateTransition(using context: UIViewControllerContextTransitioning) {
        let containerView = context.containerView
        guard
            let fromVC = context.viewController(forKey: .from),
            let toVC = context.viewController(forKey: .to)
        else {
            context.completeTransition(false)
            return
        }
        
        let initialFrame = config.originFrame
        let targetFrame = config.destinationFrame ?? config.originFrame

        // 1. Images utilisées
        let feedImage = config.destinationImage
        let annotationImage = config.initialPostImage

        // 2. Prépare le container et les deux UIImageView superposés
        let proxyContainer = UIView(frame: initialFrame)
        proxyContainer.clipsToBounds = true
        proxyContainer.layer.cornerRadius = UIConstant.device.cornerRadius
        proxyContainer.layer.borderColor = self.config.borderColor
        proxyContainer.layer.borderWidth = self.config.borderWidth

        let feedImageView = UIImageView(image: feedImage)
        feedImageView.frame = proxyContainer.bounds
        feedImageView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        feedImageView.contentMode = .scaleAspectFill

        let annotationImageView = UIImageView(image: annotationImage)
        annotationImageView.frame = proxyContainer.bounds
        annotationImageView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        annotationImageView.contentMode = .scaleAspectFill
        annotationImageView.alpha = 0 // Start invisible

        proxyContainer.addSubview(feedImageView)
        proxyContainer.addSubview(annotationImageView)
        containerView.addSubview(proxyContainer)

        // Ajout overlay optionnel (inchangé)
        var overlaySnapshot: UIView?
        if let overlayView = config.overlayView {
            let snap = overlayView.snapshotView(afterScreenUpdates: true)
            snap?.frame = proxyContainer.frame
            if let snap = snap {
                overlaySnapshot = snap
                containerView.addSubview(snap)
            }
        }

        let correctedTargetFrame = targetFrame.unscaledFrame(relativeTo: containerView.window, scale: rootVC.view.transform.a)
        fromVC.view.isHidden = true

        // ----- ANIMATION -----
        UIView.animate(
            withDuration: 0.35,
            delay: 0,
            usingSpringWithDamping: 0.95,
            initialSpringVelocity: 0.6,
            options: [.curveEaseOut],
            animations: {
                proxyContainer.frame = correctedTargetFrame
                proxyContainer.layer.cornerRadius = self.config.cornerRadius
                proxyContainer.layer.borderWidth = self.config.borderWidth
                proxyContainer.layer.borderColor = self.config.borderColor
                overlaySnapshot?.frame = proxyContainer.frame
                overlaySnapshot?.alpha = 0

                // CROSSFADE pendant toute la durée
                annotationImageView.alpha = 1

                toVC.view.transform = .identity
                toVC.view.alpha = 1
                toVC.view.isHidden = false
                self.rootVC.view.transform = .identity
                self.rootVC.view.alpha = 1
                self.rootVC.view.isHidden = false
            },
            completion: { _ in
                proxyContainer.removeFromSuperview()
                overlaySnapshot?.removeFromSuperview()

                if let homeVC = self.rootVC as? HomeVC {
                    homeVC.refreshLastSelectedAnnotation()
                    if let annotation = homeVC.lastSelectedAnnotation {
                        homeVC.waitUntilAnnotationIsRendered(annotation) {
                            fromVC.view.isHidden = false
                            homeVC.setMapInteractionEnabled(true)
                            context.completeTransition(true)
                        }
                    }
                } else {
                    fromVC.view.isHidden = false
                    context.completeTransition(true)
                }
            }
        )
    }
}


//    func animateTransition(using context: UIViewControllerContextTransitioning) {
//            let containerView = context.containerView
//            guard let fromVC = context.viewController(forKey: .from),
//                  let toVC = context.viewController(forKey: .to) else {
//                context.completeTransition(false)
//                return
//            }
//
//            debugPrintViewControllerHierarchy()
//            print("🟧 [HeroDismissAnimator] BEGIN ---")
//            print("fromVC:", fromVC)
//            print("toVC:", toVC)
//            print("containerView:", containerView)
//            print("[HeroDismissAnimator] --- HIERARCHY BEFORE ---")
//            dumpWindowHierarchy()
//            print("=============================================")
//
//            // Place la Home sous le feed
//            containerView.insertSubview(toVC.view, belowSubview: fromVC.view)
//            toVC.view.transform = .identity
//            toVC.view.alpha = 1
//            toVC.view.isHidden = false
//
//            // Proxy image animée (hero)
//            let initialFrame = config.originView.convert(config.originView.bounds, to: containerView)
//            let targetFrame = config.destinationFrame ?? config.originFrame
//            let preview = UIImageView(image: config.destinationImage)
//            preview.frame = initialFrame
//            preview.contentMode = .scaleAspectFill
//            preview.clipsToBounds = true
//            preview.layer.cornerRadius = 45
//            containerView.addSubview(preview)
//            print("🟩 [HeroDismissAnimator] Ajout preview (proxy image) ---")
//            print("preview.frame:", preview.frame)
//
//            // Cache le fromVC (le feed) pendant l'animation
//            fromVC.view.isHidden = true
//
//            UIView.animate(
//                withDuration: 0.35,
//                delay: 0,
//                usingSpringWithDamping: 0.95,
//                initialSpringVelocity: 0.6,
//                options: [.curveEaseOut],
//                animations: {
//                    print("🟦 [HeroDismissAnimator] Animation ---")
//                    toVC.view.transform = .identity
//                    toVC.view.alpha = 1
//                    toVC.view.isHidden = false
//                    preview.frame = targetFrame
//                    preview.layer.cornerRadius = self.config.cornerRadius
//
//                    // Reset homeVC si trouvé
//                    if let nav = toVC as? UINavigationController,
//                       let home = nav.viewControllers.first {
//                        home.view.transform = .identity
//                        home.view.alpha = 1
//                        home.view.isHidden = false
//                        print("🟦 [HeroDismissAnimator] Reset homeVC.view.transform/alpha/hidden dans animate block")
//                    }
//                },
//                completion: { _ in
//                    print("🟪 [HeroDismissAnimator] Animation FINISH ---")
//                    preview.removeFromSuperview()
//                    // *** NE PAS REMOVE fromVC.view ni toVC.view ***
//                    // UIKit va faire le ménage après completeTransition
//
//                    print("[HeroDismissAnimator] --- COMPLETION ---")
//                    print("fromVC:", fromVC)
//                    print("toVC:", toVC)
//                    print("toVC.view.isHidden:", toVC.view.isHidden, "alpha:", toVC.view.alpha, "transform:", toVC.view.transform)
//                    dumpWindowHierarchy()
//
//                    // Vérif post-transition
//                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
//                        print("🟦 [HeroDismissAnimator] -- POST TRANSITION --")
//                        dumpWindowHierarchy()
//                        if let nav = toVC as? UINavigationController,
//                           let home = nav.viewControllers.first as? HomeVC {
//                            print("==== [DEBUG] HOME VIEW ÉTAT APRÈS DISMISS ====")
//                            logView(home.view, label: "HomeVC.view")
//                            if let mapView = home.view.subviews.first(where: { $0 is MKMapView }) {
//                                logView(mapView, label: "mapView")
//                            }
//                            print("=============================================")
//                            print("[HeroDismissAnimator] --- HIERARCHY AFTER ---")
//                            debugPrintViewControllerHierarchy()
//                            print("=============================================")
//                            printSubviewsRecursively(home.view)
//                        }
//                    }
//                    context.completeTransition(true)
//                }
//            )
//        }
    
    // MARK: - Dismiss Logic

//    func animateDismiss(config: HeroTransitionConfig, from controller: UIViewController, completion: @escaping () -> Void) {
//        guard let container = controller.view else {
//            completion()
//            return
//        }
//        print("animateDismiss called")
//        // MARK: - Initial appearance from originView
//
//        let initialCornerRadius = CGFloat(45)
//        let initialBorderWidth = config.originView.layer.borderWidth
//        let initialBorderColor = config.originView.layer.borderColor
//
//        // MARK: - Setup preview
//
//        let preview = UIImageView(image: config.destinationImage)
//        preview.frame = config.originView.convert(config.originView.bounds, to: container)
//        preview.layer.cornerRadius = initialCornerRadius
//        preview.layer.borderWidth = initialBorderWidth
//        preview.layer.borderColor = initialBorderColor
//        preview.contentMode = .scaleAspectFill
//        preview.clipsToBounds = true
//        container.addSubview(preview)
//
//        // MARK: - Fade destination image
//
//        let fadeImageView = UIImageView(image: config.destinationImage)
//        fadeImageView.frame = preview.bounds
//        fadeImageView.contentMode = .scaleAspectFill
//        fadeImageView.clipsToBounds = true
//        fadeImageView.layer.cornerRadius = initialCornerRadius
//        fadeImageView.alpha = 0
//        preview.addSubview(fadeImageView)
//
//        // MARK: - Optional overlay snapshot
//
//        var overlaySnapshot: UIView?
//        if let overlayView = config.overlayView {
//            overlayView.isHidden = true
//            let snapshot = overlayView.snapshotView(afterScreenUpdates: false)
//            if let overlay = snapshot {
//                overlay.frame = overlayView.convert(overlayView.bounds, to: container)
//                overlay.layer.cornerRadius = initialCornerRadius
//                overlay.clipsToBounds = true
//                overlay.backgroundColor = .systemRed.withAlphaComponent(0.2) // temporaire pour debug
//                overlay.tag = 999 // pour le retrouver facilement
//                container.addSubview(overlay)
//                overlaySnapshot = overlay
//                print("[HeroDismissAnimator] overlaySnapshot ajouté au container : \(overlay)")
//                print("[HeroDismissAnimator] overlaySnapshot frame: \(overlay.frame)")
//            } else {
//                print("[HeroDismissAnimator] snapshotView nil pour overlayView : \(overlayView)")
//            }
//        } else {
//            print("[HeroDismissAnimator] Pas d'overlayView dans config")
//        }
//
//        // MARK: - Preparation
//
//        (controller as? FeedViewController)?.hideFeedContent()
//        controller.view.superview?.backgroundColor = .clear
//
//        UIView.animate(withDuration: 0.25) {
//            fadeImageView.alpha = 1
//        }
//
//        // MARK: - Main animation
//
//        UIView.animate(withDuration: 0.35,
//                       delay: 0,
//                       usingSpringWithDamping: 0.95,
//                       initialSpringVelocity: 0.6,
//                       options: [.curveEaseOut],
//                       animations: {
//            if let feedVC = controller as? FeedViewController,
//               let homeVC = feedVC.delegate as? HomeVC {
//                UIViewPropertyAnimator(duration: 0.2, curve: .easeOut) {
//                    homeVC.view.transform = .identity
//                    homeVC.view.alpha = 1
//                }.startAnimation()
//            }
//
//            let targetFrame = config.destinationFrame ?? config.originFrame
//            preview.frame = targetFrame
//            fadeImageView.frame = preview.bounds
//            overlaySnapshot?.frame = targetFrame
//
//            // Transition to final style
//            preview.layer.cornerRadius = config.cornerRadius
//            preview.layer.borderWidth = config.borderWidth
//            preview.layer.borderColor = config.borderColor
//            fadeImageView.layer.cornerRadius = config.cornerRadius
//            overlaySnapshot?.layer.cornerRadius = config.cornerRadius
//            overlaySnapshot?.alpha = 0
//
//        }, completion: { _ in
//            if let feedVC = controller as? FeedViewController,
//               let homeVC = feedVC.delegate as? HomeVC,
//               let annotation = homeVC.lastSelectedAnnotation {
//
//                feedVC.delegate?.feedDidDismiss()
//
//                homeVC.waitUntilAnnotationIsRendered(annotation) {
//                    config.overlayView?.isHidden = false
//                    completion()
//                }
//            } else {
//                config.overlayView?.isHidden = false
//                completion()
//            }
//        })
//    }
//
    
//    func animateDismiss(config: HeroTransitionConfig, from controller: UIViewController, completion: @escaping () -> Void) {
//        guard let container = controller.view else {
//            print("❌ [HeroDismissAnimator] Pas de container view")
//            completion()
//            return
//        }
//        print("🟠 [HeroDismissAnimator] animateDismissMinimal called")
//
//        // 1. Setup: on part de la frame du imageView dans le feed
//        let initialFrame = config.originView.convert(config.originView.bounds, to: container)
//        let targetFrame = config.destinationFrame ?? config.originFrame
//        print("🔹 [HeroDismissAnimator] initialFrame:", initialFrame)
//        print("🔹 [HeroDismissAnimator] targetFrame:", targetFrame)
//
//        // 2. Création du proxy image
//        let preview = UIImageView(image: config.destinationImage)
//        preview.frame = initialFrame
//        preview.contentMode = .scaleAspectFill
//        preview.clipsToBounds = true
//        preview.layer.cornerRadius = CGFloat(45) // initial radius
//        preview.layer.masksToBounds = true
//        container.addSubview(preview)
//        print("🟢 [HeroDismissAnimator] Proxy imageView ajouté au container, frame:", preview.frame)
//
//        // 3. Cache le contenu original
//        (controller as? FeedViewController)?.hideFeedContent()
//        controller.view.superview?.backgroundColor = .clear
//
//        // 4. Animation principale
//        UIView.animate(withDuration: 0.35,
//                       delay: 0,
//                       usingSpringWithDamping: 0.95,
//                       initialSpringVelocity: 0.6,
//                       options: [.curveEaseOut],
//                       animations: {
//            // Si besoin, on peut re-afficher la home VC (map) sous le feed
//            if let feedVC = controller as? FeedViewController,
//               let homeVC = feedVC.delegate as? HomeVC {
//                print("🔸 [HeroDismissAnimator] homeVC.view.transform à .identity")
//                homeVC.view.transform = .identity
//                homeVC.view.alpha = 1
//            }
//
//            // Animation du proxy image (zoom out et déplacement)
//            preview.frame = targetFrame
//            preview.layer.cornerRadius = config.cornerRadius
//            preview.layer.borderWidth = config.borderWidth
//            preview.layer.borderColor = config.borderColor
//        }, completion: { _ in
//            print("✅ [HeroDismissAnimator] Animation terminée, clean-up")
//            preview.removeFromSuperview()
//
//            if let feedVC = controller as? FeedViewController,
//               let homeVC = feedVC.delegate as? HomeVC,
//               let annotation = homeVC.lastSelectedAnnotation {
//
//                print("🔄 [HeroDismissAnimator] Appel feedDidDismiss + waitUntilAnnotationIsRendered")
//                feedVC.delegate?.feedDidDismiss()
//                homeVC.waitUntilAnnotationIsRendered(annotation) {
//                    print("🔵 [HeroDismissAnimator] waitUntilAnnotationIsRendered terminé")
//                    completion()
//                }
//            } else {
//                print("🔵 [HeroDismissAnimator] Pas de FeedVC/homeVC, on termine")
//                completion()
//            }
//        })
//    }
