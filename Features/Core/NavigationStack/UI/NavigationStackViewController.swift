//
//  StackNavigationViewController.swift
//  SocialMap
//
//  Created by Arnaud Maillet on 13/10/2025.
//

import UIKit

extension NavigationStackFeature.UI {
    final class NavigationStackViewController: UIViewController {
        typealias NavigationStackGestureManager = NavigationStackFeature.UI.NavigationStackGestureManager
        typealias NavigationStackOverlay = NavigationStackFeature.UI.Overlay.NavigationStackOverlay
        typealias NavigationStackOverlayConfigurable = NavigationStackFeature.UI.Overlay.NavigationStackOverlayConfigurable
        
        // MARK: - Stack State
        private var stack: [UIViewController] = []
        
        // MARK: - Hooks
        var onDismiss: (() -> Void)?
        
        
        // MARK: - Gestures
        var gestureManagers = NSMapTable<UIViewController, NavigationStackGestureManager>(
            keyOptions: .weakMemory,
            valueOptions: .strongMemory
        )
        
        // MARK: - Init
        init(viewControllers: [UIViewController]) {
            super.init(nibName: nil, bundle: nil)
            setInitialStack(viewControllers)
        }
        
        required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
        
        // MARK: - Lifecycle
        override func viewDidLoad() {
            super.viewDidLoad()
            view.clipsToBounds = true
            view.backgroundColor = .black
        }
        
        func configureNavigationOverlay() {
            let overlay: NavigationStackOverlay
            if let configurable = topViewController as? NavigationStackOverlayConfigurable {
                overlay = configurable.navigationOverlay
            } else {
                overlay = .default
            }

            navigationItem.backBarButtonItem = UIBarButtonItem(
                image: UIImage(systemName: "chevron.left"),
                style: .plain,
                target: nil,
                action: nil
            )

            let navbar = overlay.navbar
            let toolbar = overlay.toolbar

            navigationItem.title = navbar.title
            
            navigationItem.setRightBarButtonItems(navbar.rightItems, animated: true)
            navigationItem.setLeftBarButtonItems(navbar.leftItems, animated: true)

            navigationController?.navigationBar.prefersLargeTitles = navbar.prefersLargeTitles
            navigationController?.setNavigationBarHidden(navbar.hidesNavbar, animated: true)

            self.setToolbarItems(toolbar.items, animated: true)
            navigationController?.setToolbarHidden(toolbar.hidesToolbar, animated: true)
            
            navigationController?.overrideUserInterfaceStyle = overlay.interfaceStyle
        }
        
        @objc private func didTapPlay() {
            print("▶️ Play tapped")
        }

        @objc private func didTapPause() {
            print("⏸ Pause tapped")
        }
        
        @objc private func handleToolbarPlay() {
            print("▶️ Play tapped")
        }

        @objc private func handleToolbarPause() {
            print("⏸ Pause tapped")
        }

        @objc private func handleToolbarShare() {
            print("📤 Share tapped")
        }
        
        @objc private func closeStack() {
            triggerDismiss()
        }
        
        // MARK: - Public API
        
        var topViewController: UIViewController? {
            return stack.last
        }
        
        var viewControllers: [UIViewController] {
            return stack
        }
        
        func setInitialStack(_ viewControllers: [UIViewController]) {
            clearStack(animated: false)
            guard !viewControllers.isEmpty else { return }
            
            for (index, viewController) in viewControllers.enumerated() {
                viewController.loadViewIfNeeded()
                addToHierarchy(viewController)
                
                if index < viewControllers.count - 1 {
                    viewController.view.isUserInteractionEnabled = false
                    viewController.view.alpha = 0
                    viewController.view.isHidden = true
                }
                
                stack.append(viewController)
            }
            
            applyStackAppearancePolicy()
        }
        
        /// Push un nouvel écran
        func push(_ viewController: UIViewController, animated: Bool = true) {
            guard let fromVC = topViewController else {
                setInitialStack([viewController])
                return
            }
            
            addChild(viewController)
            viewController.view.frame = view.bounds
            viewController.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            view.addSubview(viewController.view)
            
            stack.append(viewController)
            
            if animated {
                viewController.view.alpha = 0
                UIView.animate(withDuration: 0.3, animations: {
                    viewController.view.alpha = 1
                    fromVC.view.alpha = 0
                }, completion: { _ in
                    fromVC.view.isHidden = true
                    viewController.didMove(toParent: self)
                    self.applyStackAppearancePolicy()
                })
            } else {
                viewController.didMove(toParent: self)
                applyStackAppearancePolicy()
            }
        }
        
        /// Pop le dernier écran
        @discardableResult
        func pop(animated: Bool = true) -> UIViewController? {
            guard stack.count > 1 else { return nil }
            
            let topVC = stack.removeLast()
            let belowVC = stack.last!
            
            addChild(belowVC)
            belowVC.view.frame = view.bounds
            belowVC.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            view.insertSubview(belowVC.view, belowSubview: topVC.view)
            
            if animated {
                UIView.animate(withDuration: 0.3, animations: {
                    topVC.view.alpha = 0
                    belowVC.view.alpha = 1
                }, completion: { _ in
                    topVC.view.removeFromSuperview()
                    topVC.removeFromParent()
                    belowVC.didMove(toParent: self)
                    self.applyStackAppearancePolicy()
                })
            } else {
                topVC.view.removeFromSuperview()
                topVC.removeFromParent()
                belowVC.didMove(toParent: self)
                applyStackAppearancePolicy()
            }
            
            return topVC
        }
        
        func popToRoot(animated: Bool = true) {
            while stack.count > 1 {
                _ = pop(animated: animated)
            }
        }
        
        func clearStack(animated: Bool = false) {
            for vc in stack {
                vc.willMove(toParent: nil)
                vc.view.removeFromSuperview()
                vc.removeFromParent()
            }
            stack.removeAll()
        }
        
        func triggerDismiss() {
            onDismiss?()
        }
        
        // MARK: - Helper
        private func addToHierarchy(_ vc: UIViewController) {
            addChild(vc)
            view.addSubview(vc.view)
            vc.view.frame = view.bounds
            vc.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            vc.didMove(toParent: self)
        }
        
        private func applyStackAppearancePolicy() {
            for (index, vc) in stack.enumerated() {
                switch index {
                case stack.count - 1:
                    // Top VC — actif
                    vc.view.isUserInteractionEnabled = true
                    vc.view.alpha = 1
                    vc.view.isHidden = false
                    
                case stack.count - 2:
                    // Juste en dessous — visible mais désactivé (pour scale ou blur)
                    vc.view.isUserInteractionEnabled = false
                    vc.view.alpha = 1
                    vc.view.isHidden = false
                    
                default:
                    // Les autres — complètement invisibles
                    vc.view.isUserInteractionEnabled = false
                    vc.view.alpha = 0
                    vc.view.isHidden = true
                }
            }
        }
    }
}

extension NavigationStackFeature.UI.NavigationStackViewController: NavigationStackFeature.UI.NavigationStackGestureControllable {
    var gestureView: UIView? {
        guard let topVC = stack.last else { return nil }
        topVC.loadViewIfNeeded()
        return topVC.view
    }
    
    func resetDismissAnimation(to position: CGPoint?) {
        guard let topView = view else { return }
        UIView.animate(withDuration: 0.3,
                       delay: 0,
                       usingSpringWithDamping: 0.96,
                       initialSpringVelocity: 0.5,
                       options: [.curveEaseOut],
                       animations: {
            topView.transform = .identity
            topView.center = position ?? topView.center
            topView.layer.cornerRadius = 0
        })
    }
    
    func scaleUnderlyingView(to scale: CGFloat, animated: Bool) {
        guard let belowTopView = stack.dropLast().last?.view else { return }
        if let vc = belowTopView.parentViewController {
            print("📦 belowTopView appartient à un view controller de type : \(type(of: vc))")
        } else {
            print("❗️Aucun view controller parent trouvé pour belowTopView")
        }
        let transform = CGAffineTransform(scaleX: scale, y: scale)
        if animated {
            UIView.animate(withDuration: 0.25) {
                belowTopView.transform = transform
            }
        } else {
            belowTopView.transform = transform
        }
    }
}
