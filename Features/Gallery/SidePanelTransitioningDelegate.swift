//
//  SidePanelTransitioningDelegate.swift
//  SocialMap
//
//  Created by Arnaud Maillet on 20/06/2025.
//

import UIKit

final class SidePanelTransitioningDelegate: NSObject, UIViewControllerTransitioningDelegate {
    var interactiveTransition: UIPercentDrivenInteractiveTransition?
    
    // Transition animator pour présentation
    func animationController(forPresented presented: UIViewController,
                            presenting: UIViewController,
                            source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return SidePanelAnimator(isPresenting: true)
    }
    
    // Transition animator pour dismiss
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return SidePanelAnimator(isPresenting: false)
    }
    
    // Transition interactive (présentation)
    func interactionControllerForPresentation(using animator: UIViewControllerAnimatedTransitioning)
        -> UIViewControllerInteractiveTransitioning? {
        return interactiveTransition
    }
}
