//
//  StackScreenGestureManager.swift
//  SocialMap
//
//  Created by Arnaud Maillet on 25/08/2025.
//

import UIKit

private enum PanDirection {
    case up, down, left, right, undefined
}

private var panDirection: PanDirection = .undefined

protocol StackScreenGestureControllable: UIViewController {
    var gestureView: UIView? { get }

    func resetDismissAnimation(to position: CGPoint?)
    func scaleUnderlyingView(to scale: CGFloat, animated: Bool)
}

final class StackScreenGestureManager: NSObject, UIGestureRecognizerDelegate {
    private unowned let stackCoordinator: StackScreenCoordinator
    private weak var stackControllable: StackScreenGestureControllable?
    
    private var panHandler: UIPanGestureRecognizer?
    private var containerPan: UIPanGestureRecognizer?
    private var originalCenter: CGPoint = .zero
    
    init(coordinator: StackScreenCoordinator) {
        self.stackCoordinator = coordinator
        super.init()
    }
    
    func attach(controllable: StackScreenGestureControllable) {
        self.stackControllable = controllable
        setupGestures()
    }
    
    // MARK: - Setup Gestures
    private func setupGestures() {
        guard
            let controllable = debugUnwrap(stackControllable),
            let view = debugUnwrap(controllable.gestureView)
        else { return }
        
        print("✅ [GestureManager] Setup des gestures sur \(controllable)")
        
        let panHandler = UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:)))
        panHandler.delegate = self
        view.addGestureRecognizer(panHandler)
        self.panHandler = panHandler
    }
    
    // MARK: - Gesture Handlers
    @objc private func handlePan(_ gesture: UIPanGestureRecognizer) {
        guard
            let controllable = stackControllable,
            let view = debugUnwrap(controllable.gestureView)
        else { return }
        
        let translation = gesture.translation(in: view.superview)
        
        switch gesture.state {
        case .began:
            originalCenter = view.center
            
            view.layer.removeAllAnimations()
            view.layer.masksToBounds = true
            view.layer.cornerRadius = UIConstant.device.cornerRadius
            
            controllable.view.layer.removeAllAnimations()
            controllable.scaleUnderlyingView(to: UIConstant.view.zoomScale, animated: false)
            panDirection = .undefined
            
        case .changed:
            // Détection de la direction si pas encore définie
            if panDirection == .undefined {
                if abs(translation.y) > abs(translation.x) {
                    panDirection = translation.y > 0 ? .down : .up
                } else {
                    panDirection = translation.x > 0 ? .right : .left
                }
            }
            
            switch panDirection {
            case .down:
                applyTransformAndAlpha(to: view, translation: translation)
                
            case .right:
                controllable.view.backgroundColor = .clear
                updateStackTranslation(translationX: translation.x, in: view)
                
            default:
                break
            }
            
        case .ended, .cancelled:
            switch panDirection {
            case .up:
                print("Swipe up détecté (pas de dismiss)")
                
            case .down:
                handlePanEnded(translation: translation, velocity: gesture.velocity(in: view))
                
            case .right:
                let threshold: CGFloat = 120
                if translation.x > threshold {
                    stackCoordinator.dismiss()
                } else {
                    // Si seuil pas atteint → revient à la position initiale
                    UIView.animate(
                        withDuration: 0.35,
                        delay: 0,
                        usingSpringWithDamping: 0.95,
                        initialSpringVelocity: 0.6,
                        options: [.allowUserInteraction, .curveEaseOut]
                    ) {
                        self.stackControllable?.view.transform = .identity
                    } completion: { _ in
                        controllable.view.backgroundColor = .black
                    }
                }
                
            case .left:
                print("⬅️ Swipe gauche détecté (pas de dismiss)")
                
            default: break
            }
            
            panDirection = .undefined
            
        default: break
        }
    }
    
    private func updateStackTranslation(translationX: CGFloat, in view: UIView) {
        guard let controllable = stackControllable,
              let presentingView = stackCoordinator.presentingVC?.view
        else { return }
        
        // On ne veut agir que pour les swipes vers la droite
        guard translationX > 0 else {
            controllable.view.transform = .identity
            return
        }
        
        // Calcul du pourcentage de progression
        let progress = min(max(translationX / view.bounds.width, 0), 1)
        
        // Applique la translation horizontale de la pile entière
        controllable.view.transform = CGAffineTransform(translationX: translationX, y: 0)
        
        // 🎯 Le presentingVC part de UIConstant.view.zoomScale → va jusqu’à 1.0
        let initialScale: CGFloat = UIConstant.view.zoomScale
        let scale = initialScale + (1.0 - initialScale) * progress
        presentingView.transform = CGAffineTransform(scaleX: scale, y: scale)
    }
    
    // MARK: - Pan End Handling
    private func handlePanEnded(translation: CGPoint, velocity: CGPoint) {
        guard
            let controllable = stackControllable,
            let view = debugUnwrap(controllable.gestureView)
        else { return }
        
        // Seuils pour déclencher le dismiss
        let dismissDistance: CGFloat = 120
        let dismissVelocity: CGFloat = 900
        
        // Distance totale parcourue → diagonale possible
        let totalDistance = hypot(translation.x, translation.y) // √(x² + y²)
        let totalVelocity = hypot(velocity.x, velocity.y)       // √(vx² + vy²)
        
        // Vérifie si on doit dismiss
        let shouldDismiss = totalDistance > dismissDistance || totalVelocity > dismissVelocity
        
        if shouldDismiss {
            stackCoordinator.popContextProvider = {
                guard
                    let stackVC = self.stackCoordinator.stackViewController,
                    let fromVC = stackVC.topViewController as? HeroViewControllable,
                    let toVC = stackVC.viewControllers.dropLast().last as? HeroViewControllable,
                    let context = self.stackCoordinator.getContext(for: fromVC),
                    let destinationView = fromVC.heroAnimatedView(at: context.sourceIndexPath),
                    let data = fromVC.heroTransitionData()
                else {
                    print("❌ Impossible de créer le HeroTransitionContext (destination)")
                    return nil
                }

                return HeroTransitionContext(
                    fromViewController: fromVC,
                    toViewController: toVC,
                    sourceIndexPath: IndexPath(item: 0, section: 0),
                    destinationIndexPath: context.sourceIndexPath,
                    animatedView: destinationView,
                    transitionData: data,
                )
            }
            
            if let context = stackCoordinator.popContextProvider?() {
                stackCoordinator.popViewControllerWithHeroTransition(context)
            } else {
                stackCoordinator.popViewController(animated: true)
            }
        } else {
            UIView.animate(
                withDuration: 0.35,
                delay: 0,
                usingSpringWithDamping: 0.95,
                initialSpringVelocity: 0.6,
                options: [.allowUserInteraction, .curveEaseOut]
            ) {
                view.transform = .identity
            } completion: { finished in
                guard finished else { return }
                view.layer.cornerRadius = 0
                controllable.scaleUnderlyingView(to: 1, animated: false)
            }
        }
    }
    
    // MARK: - Helpers
    private func applyTransformAndAlpha(to view: UIView, translation: CGPoint) {
        let dampedX = damped(translation.x, factor: 200)
        let dampedY = damped(translation.y, factor: 200)
        let maxDrag: CGFloat = 300
        let distance = min(hypot(dampedX, dampedY), maxDrag)
        let progress = distance / maxDrag
        let scale = 1 - (0.5 * progress)
        
        let adjustedX = dampedX / scale
        let adjustedY = dampedY / scale
        
        view.transform = CGAffineTransform(translationX: adjustedX, y: adjustedY)
            .scaledBy(x: scale, y: scale)
    }
    
    private func damped(_ value: CGFloat, factor: CGFloat) -> CGFloat {
        return value * factor / (abs(value) + factor)
    }
    
    func dismissFromTop() {
        
    }
    
    func startRightPanel(from gesture: UIPanGestureRecognizer) {
        stackCoordinator.startRightPanel(from: gesture)
    }
    
    func updateRightPanel(percent: CGFloat) {
        stackCoordinator.updateRightPanel(percent: percent)
    }
    
    func finishRightPanel() {
        stackCoordinator.finishRightPanel()
    }
    
    func cancelRightPanel() {
        stackCoordinator.cancelRightPanel()
    }
}
