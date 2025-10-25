//
//  StackScreenViewController.swift
//  SocialMap
//
//  Created by Arnaud Maillet on 18/08/2025.
//

import UIKit

final class StackScreenViewController: UIViewController {

    // MARK: - Stack State
    private var stack: [UIViewController] = []
    
    // MARK: - Hooks
    var onDismiss: (() -> Void)?
    
    // MARK: - Coordinator
    unowned let coordinator: StackScreenCoordinator
    
    // MARK: - Gestures
    var gestureManagers = NSMapTable<UIViewController, StackScreenGestureManager>(
        keyOptions: .weakMemory,
        valueOptions: .strongMemory
    )

    // MARK: - Init
    init(rootViewController: UIViewController, coordinator: StackScreenCoordinator) {
        self.coordinator = coordinator
        super.init(nibName: nil, bundle: nil)
        setInitial(rootViewController)
    }
    

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.clipsToBounds = true
        view.backgroundColor = .black
    }

    // MARK: - Public API

    var topViewController: UIViewController? {
        return stack.last
    }
    
    var viewControllers: [UIViewController] {
        return stack
    }

    /// Définit le premier écran de la stack
    func setInitial(_ viewController: UIViewController) {
        clearStack(animated: false)
        viewController.loadViewIfNeeded()
        addToHierarchy(viewController)
        stack.append(viewController)
        applyStackAppearancePolicy()
    }

    /// Push un nouvel écran
    func push(_ viewController: UIViewController, animated: Bool = true) {
        guard let fromVC = topViewController else {
            setInitial(viewController)
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

extension StackScreenViewController: StackScreenGestureControllable {
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
