//
//  FeedGestureHandler.swift
//  SocialMap
//
//  Created by Arnaud Maillet on 27/04/2025.
//

import UIKit

final class FeedGestureHandler {
    weak var gestureManager: FeedGestureManager?
    weak var container: FeedContainerControllable?

    private var originalPosition: CGPoint?
    private var isDragging = false
    private var isPresentingRightPanel = false
    private var hasStartedRightPanelInteraction = false

    private let visuals: HeroTransitionVisuals
    private let dismissThreshold: CGFloat = 160

    init(visuals: HeroTransitionVisuals) {
        self.visuals = visuals
    }

    func handlePan(_ gesture: UIPanGestureRecognizer) {
        guard
            let container = debugUnwrap(container),
            let feedView = debugUnwrap(container.feedView)
        else {
            return
        }

        let translation = gesture.translation(in: feedView)
        let isAtOrigin = feedView.transform.isIdentity
        let isLeftward = translation.x < 0

        switch gesture.state {
        case .began:
            beginInteraction(on: feedView)

        case .changed:
            if isLeftward && isAtOrigin && !isPresentingRightPanel && !hasStartedRightPanelInteraction {
                print("🚀 startRightPanelInteraction triggered")
                startRightPanelInteraction(from: gesture)
            } else if isPresentingRightPanel {
                updateRightPanelProgress(translationX: translation.x, in: feedView)
            } else {
                updateDismissInteraction(on: feedView, translation: translation)
            }

        case .ended, .cancelled:
            if isPresentingRightPanel {
                finishOrCancelRightPanel(translationX: translation.x, in: feedView)
            } else {
                finishDismissInteraction(on: feedView, translation: translation)
            }

        default:
            break
        }
    }

    func gestureRecognizerShouldBegin(_ gesture: UIGestureRecognizer) -> Bool {
        guard
            let pan = debugUnwrap(gesture as? UIPanGestureRecognizer, "gesture is not UIPanGestureRecognizer"),
            let container = debugUnwrap(container),
            let feedView = debugUnwrap(container.feedView)
        else {
            return false
        }

        let velocity = pan.velocity(in: feedView)
        return abs(velocity.y) > abs(velocity.x) && velocity.y > 0
    }

    private func beginInteraction(on view: UIView) {
        guard
            let container = debugUnwrap(container),
            let galleryView = debugUnwrap(container.galleryView)
        else {
            return
        }
        
        if let post = container.currentPost {
            container.coordinatorDelegate?.prepareGalleryForDismiss(for: post)
        }
        
        galleryView.transform = CGAffineTransform(scaleX: UIConstant.view.zoomScale, y: UIConstant.view.zoomScale)
        originalPosition = view.center
        isDragging = false
    }

    private func updateDismissInteraction(on view: UIView, translation: CGPoint) {
        if !isDragging {
            isDragging = true
            view.layer.cornerRadius = visuals.transitionCornerRadius
            view.layer.borderWidth = visuals.transitionBorderWidth
            view.layer.borderColor = visuals.transitionBorderColor
            view.clipsToBounds = true
        }
        applyTransformAndAlpha(to: view, translation: translation)
    }

    private func finishDismissInteraction(on view: UIView, translation: CGPoint) {
        guard
            let manager = debugUnwrap(gestureManager),
            let container = debugUnwrap(container)
        else {
            return
        }
        
        let shouldDismiss = translation.y > dismissThreshold
        if shouldDismiss {
            manager.dismissFeedToGallery()
        } else {
            container.resetDismissAnimation(to: originalPosition)
        }
        
        isDragging = false
    }

    private func applyTransformAndAlpha(to view: UIView, translation: CGPoint) {
        guard
            let container = debugUnwrap(container),
            let overlayView = debugUnwrap(container.overlayView)
        else {
            return
        }
        
        let dampedX = damped(translation.x, factor: 200)
        let dampedY = damped(translation.y, factor: 200)
        let maxDrag: CGFloat = 300
        let distance = min(hypot(dampedX, dampedY), maxDrag)
        let progress = distance / maxDrag
        let scale = 1 - (0.5 * progress)

        let adjustedX = dampedX / scale
        let adjustedY = dampedY / scale

        view.transform = CGAffineTransform(translationX: adjustedX, y: adjustedY).scaledBy(x: scale, y: scale)
        overlayView.alpha = .interpolate(from: 1.0, to: 0.4, progress: progress)
    }

    private func damped(_ value: CGFloat, factor: CGFloat) -> CGFloat {
        return value * factor / (abs(value) + factor)
    }

    private func startRightPanelInteraction(from gesture: UIPanGestureRecognizer) {
        guard
            let manager = debugUnwrap(gestureManager)
        else { return }
        
        hasStartedRightPanelInteraction = true
        isPresentingRightPanel = true
        manager.startRightPanel(from: gesture)
    }

    private func updateRightPanelProgress(translationX: CGFloat, in view: UIView) {
        guard
            let manager = debugUnwrap(gestureManager),
            let container = debugUnwrap(container)
        else { return }
        guard translationX < 0 else { return }

        let progress = min(max(-translationX / view.bounds.width, 0), 1)
        manager.updateRightPanel(percent: progress)
        
        let scale = 1 - (1 - UIConstant.view.zoomScale) * progress
        container.containerView?.transform = CGAffineTransform(scaleX: scale, y: scale)
    }

    private func finishOrCancelRightPanel(translationX: CGFloat, in view: UIView) {
        guard
            let manager = debugUnwrap(gestureManager),
            let containerView = debugUnwrap(container?.containerView)
        else { return }
        
        let progress = min(max(-translationX / view.bounds.width, 0), 1)
        if progress > 0.3 {
            manager.finishRightPanel()
        } else {
            manager.cancelRightPanel()
    
            UIView.animate(
                withDuration: 0.25,
                delay: 0,
                usingSpringWithDamping: 0.8,
                initialSpringVelocity: 0.5,
                options: [.curveEaseOut]
            ) {
                containerView.transform = .identity
            }
        }
        isPresentingRightPanel = false
        hasStartedRightPanelInteraction = false
    }
}
