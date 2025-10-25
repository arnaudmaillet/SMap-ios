//
//  UIStackView+Extensions.swift
//  SocialMap
//
//  Created by Arnaud Maillet on 18/05/2025.
//

import UIKit

extension UIStackView {
    func addArrangedSubviews(_ views: [UIView]) {
        views.forEach { addArrangedSubview($0) }
    }
    
    /// Anime la disparition (fade+zoom+spring) et retire la vue de la stack, puis du superview
    func animateSpringRemoval(of view: UIView, duration: TimeInterval = 0.3, scale: CGFloat = 0.7, damping: CGFloat = 0.7, interpolateFactor: CGFloat = 2, completion: (() -> Void)? = nil) {
        let superview = self.superview ?? self
        
        let layoutAnimator = UIViewPropertyAnimator(duration: duration, dampingRatio: damping) {
            self.removeArrangedSubview(view)
            view.removeFromSuperview()
            superview.layoutIfNeeded()
        }
        layoutAnimator.startAnimation()
    }
    

    /// Anime l'apparition (fade+zoom+spring) d'une vue ré-injectée dans la stack
    func animateSpringAppearance(of view: UIView, at index: Int, duration: TimeInterval = 0.22, damping: CGFloat = 0.7, completion: (() -> Void)? = nil) {
        view.alpha = 0
        view.transform = CGAffineTransform(scaleX: 0.7, y: 0.7)
        self.insertArrangedSubview(view, at: index)
        self.superview?.layoutIfNeeded()

        let animator = UIViewPropertyAnimator(duration: duration, dampingRatio: damping) {
            view.alpha = 1
            view.transform = .identity
            self.superview?.layoutIfNeeded()
        }
        animator.addCompletion { _ in completion?() }
        animator.startAnimation()
    }
}
