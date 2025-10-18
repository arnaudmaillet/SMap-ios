//
//  NavigationStackFlow.swift
//  SocialMap
//
//  Created by Arnaud Maillet on 13/10/2025.
//

import UIKit

extension NavigationStackFeature.Flow {
    
    final class NavigationStackFlow {
        typealias StackViewController = NavigationStackFeature.UI.NavigationStackViewController

        // MARK: - References

        private weak var navigationController: UINavigationController?
        private let containers: [FeatureContainer]

        private var stackViewController: StackViewController?

        // MARK: - Init

        init(
            navigationController: UINavigationController,
            containers: [FeatureContainer]
        ) {
            self.navigationController = navigationController
            self.containers = containers
        }

        // MARK: - Flow Entry Point

        func start(with viewControllers: [UIViewController], animated: Bool = true) {
            let stackVC = StackViewController(viewControllers: viewControllers)
            self.stackViewController = stackVC
            navigationController?.pushViewController(stackVC, animated: animated)
            stackVC.configureNavigationOverlay()
        }

        // MARK: - Navigation API

        func push(_ viewController: UIViewController, animated: Bool = true) {
            stackViewController?.push(viewController, animated: animated)
            // TODO: Analytics, logging, etc. possible ici
        }

        func push(_ viewControllers: [UIViewController], animated: Bool = true) {
            for (index, vc) in viewControllers.enumerated() {
                push(vc, animated: animated && index == viewControllers.count - 1)
            }
        }

        @discardableResult
        func pop(animated: Bool = true) -> UIViewController? {
            return stackViewController?.pop(animated: animated)
        }

        func popToRoot(animated: Bool = true) {
            stackViewController?.popToRoot(animated: animated)
        }

        func replaceTop(with viewController: UIViewController, animated: Bool = true) {
            guard stackViewController?.pop(animated: false) != nil else { return }
            push(viewController, animated: animated)
        }

        func dismissStack() {
            stackViewController?.triggerDismiss()
        }

        // MARK: - Accessors (en lecture seule)

        var topViewController: UIViewController? {
            return stackViewController?.topViewController
        }

        var allViewControllers: [UIViewController] {
            return stackViewController?.viewControllers ?? []
        }
    }
}
