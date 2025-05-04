//
//  NavigationPresentTransitionDelegate.swift
//  SocialMap
//
//  Created by Arnaud Maillet on 18/04/2025.
//

import UIKit

final class NavigationTransitionDelegate: NSObject, UIViewControllerTransitioningDelegate {
    private let originView: UIView
    private let originFrame: CGRect
    private let post: Post.Model

    init(originView: UIView, originFrame: CGRect, post: Post.Model) {
        self.originView = originView
        self.originFrame = originFrame
        self.post = post
    }

    func animationController(forPresented presented: UIViewController,
                             presenting: UIViewController,
                             source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return HeroPresentAnimator(originView: originView, originFrame: originFrame, post: post, isPresenting: true)
    }
}
