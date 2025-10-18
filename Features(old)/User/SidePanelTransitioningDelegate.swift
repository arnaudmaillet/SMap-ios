//
//  SidePanelTransitioningDelegate.swift
//  SocialMap
//
//  Created by Arnaud Maillet on 20/06/2025.
//

import UIKit

final class SidePanelTransitioningDelegate: NSObject, UIViewControllerTransitioningDelegate {
    var interactiveTransition: UIPercentDrivenInteractiveTransition?
    
    func animationController(forPresented presented: UIViewController,
                            presenting: UIViewController,
                            source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return SidePanelAnimator(isPresenting: true)
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return SidePanelAnimator(isPresenting: false)
    }
    
    func interactionControllerForPresentation(using animator: UIViewControllerAnimatedTransitioning)
        -> UIViewControllerInteractiveTransitioning? {
        return interactiveTransition
    }
    
    func interactionControllerForDismissal(using animator: UIViewControllerAnimatedTransitioning)
        -> UIViewControllerInteractiveTransitioning? {
        return interactiveTransition
    }
}
