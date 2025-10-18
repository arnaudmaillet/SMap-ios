//
//  NavigationStackCoordinator.swift
//  SocialMap
//
//  Created by Arnaud Maillet on 13/10/2025.
//

import UIKit
import AVFoundation


extension NavigationStackFeature.UI {
    enum HeroTransitionPhase {
        case push
        case pop
    }
    
    protocol HeroDimissableStackScreen: AnyObject {
        func dismiss()
    }
    
    protocol HeroViewControllable: UIViewController {
        func heroAnimatedView(at indexPath: IndexPath) -> UIView?
        func heroContainerView(at indexPath: IndexPath) -> UIView?
        func heroTransitionData() -> Any?
        func didFinishHeroTransition(
            at indexPath: IndexPath,
            with data: Any,
            animatedView: UIView,
            phase: HeroTransitionPhase
        )
    }
    
    typealias StackScreenCoordinatorDelegate =
    HeroDimissableStackScreen
    
    struct HeroTransitionContext {
        let fromViewController: HeroViewControllable
        let toViewController: HeroViewControllable
        let sourceIndexPath: IndexPath
        let destinationIndexPath: IndexPath
        let animatedView: UIView
        let transitionData: Any?
    }
    
    protocol CollectionViewContainer: AnyObject {
        var collectionView: UICollectionView { get }
    }
    
    final class NavigationStackCoordinator: StackScreenCoordinatorDelegate {
        
        typealias NavigationStackViewController = NavigationStackFeature.UI.NavigationStackViewController
        typealias NavigationStackGestureManager = NavigationStackFeature.UI.NavigationStackGestureManager
        
        // MARK: - Dependencies
        weak var presentingVC: UIViewController?
        var popContextProvider: (() -> HeroTransitionContext?)?
        
        private var transitionDelegate: UIViewControllerTransitioningDelegate?
        private var pushContexts: [UIViewController: HeroTransitionContext] = [:]
        
        // MARK: - State
        private(set) weak var stackViewController: NavigationStackViewController?
        
        init(presentingVC: UIViewController) {
            self.presentingVC = presentingVC
            self.popContextProvider = { nil }
        }
        
        func getContext(for viewController: UIViewController) -> HeroTransitionContext? {
            return pushContexts[viewController]
        }
        
        func pushViewControllerWithHeroTransition(_ context: HeroTransitionContext) {
            heroTransitionCore(context, phase: .push)
        }
        
        func popViewControllerWithHeroTransition(_ context: HeroTransitionContext) {
            heroTransitionCore(context, phase: .pop)
        }
        
        /// Push un nouvel écran générique (plein écran) dans la pile
        private func pushViewController(
            _ viewController: UIViewController,
            animated: Bool = true,
            customTransition: ((_ from: UIViewController, _ to: UIViewController, _ completion: @escaping () -> Void) -> Void)? = nil
        ) {
            guard let stackViewController else { return }
            
            if let customTransition {
                guard let fromVC = stackViewController.topViewController else { return }
                addViewController(viewController, to: stackViewController)
                customTransition(fromVC, viewController) {
                    stackViewController.push(viewController, animated: false)
                }
            } else {
                stackViewController.push(viewController, animated: animated)
            }
        }
        
        /// Pop le top de la stack
        func popViewController(animated: Bool = true) {
            guard let stackVC = debugUnwrap(stackViewController) else { return }
            stackVC.pop(animated: animated)
        }
        
        private func heroTransitionCore(_ context: HeroTransitionContext, phase: HeroTransitionPhase) {
            let fromVC = context.fromViewController
            let toVC = context.toViewController
            let animatedView = context.animatedView
            
            fromVC.view.layoutIfNeeded()
            toVC.view.layoutIfNeeded()
            
            guard
                let stackVC = self.stackViewController,
                let window = stackVC.view.window,
                let destinationView = context.toViewController.heroContainerView(at: context.destinationIndexPath),
                let data = context.transitionData
            else { return }
            
            var destFrame: CGRect
            
            
            
            // Préparer la vue animée dans la fenêtre
            let startFrame = animatedView.convert(animatedView.bounds, to: window)
            animatedView.removeFromSuperview()
            animatedView.frame = startFrame
            animatedView.clipsToBounds = true
            animatedView.translatesAutoresizingMaskIntoConstraints = true
            window.addSubview(animatedView)
            
            switch phase {
            case .push:
                self.pushViewController(toVC, animated: false)
                self.pushContexts[toVC] = context
                destFrame = destinationView.convert(destinationView.bounds, to: window)
                fromVC.view.layer.cornerRadius = UIConstant.device.cornerRadius
                toVC.view.alpha = 0
                
            case .pop:
                toVC.view.transform = CGAffineTransform(scaleX: UIConstant.view.zoomScale, y: UIConstant.view.zoomScale)
                destFrame = destinationView.ajustFrameInWindowForScale(UIConstant.view.zoomScale)
                animatedView.layer.cornerRadius = UIConstant.device.cornerRadius
                toVC.view.alpha = 1
                fromVC.view.alpha = 0
            }
            
            UIView.animate(
                withDuration: 0.65,
                delay: 0,
                usingSpringWithDamping: 0.9,
                initialSpringVelocity: 0.6,
                options: [.curveEaseOut],
                animations: {
                    animatedView.frame = destFrame
                    switch phase {
                    case .push:
                        animatedView.layer.cornerRadius = UIConstant.device.cornerRadius
                        fromVC.view.transform = CGAffineTransform(scaleX: UIConstant.view.zoomScale, y: UIConstant.view.zoomScale)
                    case .pop:
                        animatedView.layer.cornerRadius = 8
                        toVC.view.transform = .identity
                    }
                },
                completion: { _ in
                    destinationView.layer.borderWidth = 0
                    toVC.didFinishHeroTransition(
                        at: context.destinationIndexPath,
                        with: data,
                        animatedView: animatedView,
                        phase: phase
                    )
                    
                    switch phase {
                    case .push:
                        toVC.view.alpha = 1
                        fromVC.view.transform = .identity
                        animatedView.layer.cornerRadius = 0
                        self.attachGestureManager(to: toVC)
                    case .pop:
                        self.pushContexts.removeValue(forKey: toVC)
                        self.popViewController(animated: false)
                    }
                }
            )
        }
        
        /// Présente une nouvelle pile d'écrans, avec une `initial` viewController
//        func start(
//            screens: [UIViewController],
//            panGesture: UIPanGestureRecognizer? = nil,
//            didDismiss: (() -> Void)? = nil
//        ) {
//            guard let rootViewController = screens.first else { return }
//            
//            let container = NavigationStackViewController(rootViewController: rootViewController)
//            self.stackViewController = container
//            
//            let sideDelegate = SidePanelTransitioningDelegate()
//            let interactive = UIPercentDrivenInteractiveTransition()
//            sideDelegate.interactiveTransition = interactive
//            transitionDelegate = sideDelegate
//            
//            container.transitioningDelegate = sideDelegate
//            container.modalPresentationStyle = .custom
//            
//            container.onDismiss = { [weak self] in
//                self?.dismiss()
//                didDismiss?()
//            }
//            
//            presentingVC?.present(container, animated: true)
//            
//            // Stack les autres écrans
//            let otherScreens = screens.dropFirst()
//            for screen in otherScreens {
//                addViewController(screen, to: container)
//                container.push(screen, animated: false)
//            }
//            
//            // Gérer le geste s’il y a
//            if let pan = panGesture, let presentingView = presentingVC?.view {
//                let tx = -max(0, pan.translation(in: presentingView).x)
//                let percent = min(max(tx / presentingView.bounds.width, 0), 1)
//                interactive.update(max(percent, 0.001))
//            }
//        }
//        
//        func start(
//            screen: UIViewController,
//            panGesture: UIPanGestureRecognizer? = nil,
//            didDismiss: (() -> Void)? = nil
//        ) {
//            start(screens: [screen], panGesture: panGesture, didDismiss: didDismiss)
//        }
        
        /// Dismiss entièrement la stack
        func dismiss() {
            guard let stackVC = debugUnwrap(stackViewController) else { return }
            stackVC.dismiss(animated: true)
        }
        
        // MARK: - Helpers
        private func addViewController(_ vc: UIViewController, to container: UIViewController) {
            container.addChild(vc)
            container.view.addSubview(vc.view)
            vc.view.frame = container.view.bounds
            vc.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            vc.didMove(toParent: container)
        }
        
        private func attachGestureManager(to viewController: UIViewController) {
            if let stackVC = self.stackViewController {
                let gestureManager = NavigationStackGestureManager(coordinator: self)
                gestureManager.attach(controllable: stackVC)
                stackVC.gestureManagers.setObject(gestureManager, forKey: viewController)
            }
        }
    }
}

extension NavigationStackFeature.UI.NavigationStackCoordinator {
    // Pop le top de la stack
    func dismissTop() {
        guard let stackVC = stackViewController else { return }
        stackVC.pop(animated: true)
    }
    
    // MARK: - Panel droit (optionnel)
    func startRightPanel(from gesture: UIPanGestureRecognizer) {
        // Implémentation du lancement du panel droit
    }
    
    func updateRightPanel(percent: CGFloat) {
        // Mise à jour de la progression
    }
    
    func finishRightPanel() {
        // Validation du panel droit
    }
    
    func cancelRightPanel() {
        // Retour à l'état initial
    }
}
