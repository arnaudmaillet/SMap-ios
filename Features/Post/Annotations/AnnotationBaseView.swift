//
//  BaseAnnotationView.swift
//  SocialMap
//
//  Created by Arnaud Maillet on 26/04/2025.
//

import UIKit
import MapKit

extension Post.Annotation {
    class AnnotationBaseView: MKAnnotationView, UIGestureRecognizerDelegate {
        
        // MARK: - Properties
        
        var preview: Post.PreviewView?
        private var initialTouchPoint: CGPoint?
        private var isMultiTouchInteraction = false
        
        /// Returns the layer used for drawing borders (typically the preview layer)
        var borderLayer: CALayer? {
            return preview?.layer
        }
        
        // MARK: - Initializers
        
        override init(annotation: MKAnnotation?, reuseIdentifier: String?) {
            super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
            setupGestureRecognizer()
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        // MARK: - Setup
        
        /// Sets up the preview view with a given post and size.
        func setupPreview(with post: Post.Model, size: CGFloat = 72) {
            // Remove existing preview if any
            preview?.removeFromSuperview()
            
            let newPreview = Post.PreviewView(size: size)
            newPreview.configure(with: post, size: size)
            newPreview.isUserInteractionEnabled = true
            
            addSubview(newPreview)
            preview = newPreview
            
            frame = CGRect(origin: .zero, size: newPreview.bounds.size)
            newPreview.center = CGPoint(x: bounds.midX, y: bounds.midY)
        }
        
        // MARK: - Gesture Handling
        
        private func setupGestureRecognizer() {
            let gesture = UILongPressGestureRecognizer(target: self, action: #selector(handleInteraction(_:)))
            gesture.minimumPressDuration = 0
            gesture.delegate = self
            gesture.cancelsTouchesInView = false
            self.addGestureRecognizer(gesture)
        }
        
        /// Handles the interaction (tap, drag, multitouch) on the preview.
        @objc private func handleInteraction(_ gesture: UILongPressGestureRecognizer) {
            
            switch gesture.state {
            case .began:
                animateScale(0.95)
            case .ended:
                animateScale(1.0)
                handleTap()
            case .cancelled, .failed:
                animateScale(1.0)
                
            default:
                break
            }
        }
        
        /// Handles tap action on the annotation view.
        func handleTap() {
            
        }
        
        // MARK: - Animations
        
        /// Animates the scale transformation of the annotation view.
        func animateScale(_ scale: CGFloat) {
            UIView.animate(withDuration: 0.2, delay: 0, options: [.curveEaseOut]) {
                self.transform = CGAffineTransform(scaleX: scale, y: scale)
            }
        }
        
        // MARK: - UIGestureRecognizerDelegate
        
        /// Allows simultaneous recognition with other gestures.
        func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
            return true
        }
    }
}
