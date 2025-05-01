//
//  NavigationPresentTransitionDelegate.swift
//  SocialMap
//
//  Created by Arnaud Maillet on 18/04/2025.
//

import UIKit

final class NavigationTransitionDelegate: NSObject, UIViewControllerTransitioningDelegate {
    private let originFrame: CGRect
    private let image: UIImage

    init(originFrame: CGRect, image: UIImage) {
        self.originFrame = originFrame
        self.image = image
    }

    func animationController(forPresented presented: UIViewController,
                             presenting: UIViewController,
                             source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return NavigationTransition(originFrame: originFrame, image: image, isPresenting: true)
    }

    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return NavigationTransition(originFrame: originFrame, image: image, isPresenting: false)
    }
}
