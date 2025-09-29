//
//  FeedDismissGestureHandler.swift
//  SocialMap
//
//  Created by Arnaud Maillet on 27/04/2025.
//

import UIKit

final class FeedContainerDismissGestureHandler {

    // MARK: - Public Properties

    weak var delegate: FeedDismissControllable?
    weak var overlayView: UIView?
    weak var homeContainerView: UIView?
//    weak var backdropView: UIView?

    // MARK: - Private Properties

    private weak var view: UIView?
    private var isDragging = false
    private var originalPosition: CGPoint?
    private let visuals: HeroTransitionVisuals
    
    private let dismissThreshold: CGFloat = 160

    private var isPresentingRightPanel = false
    private var hasStartedRightPanelInteraction = false
    private var isVerticalDraggingDown = false

    // MARK: - Init

    init(view: UIView, overlayView: UIView?, homeContainerView: UIView?, visuals: HeroTransitionVisuals) {
        self.view = view
        self.overlayView = overlayView
        self.homeContainerView = homeContainerView
        self.visuals = visuals
    }
  

    // MARK: - Gesture Handling

    func handlePan(_ gesture: UIPanGestureRecognizer) {
        guard let view = view else { return }
        let translation = gesture.translation(in: view)
        let isAtOriginPosition = view.transform.isIdentity
        let isLeftwardDrag = translation.x < 0
        switch gesture.state {
        case .began:
            handlePanBegan(view: view)

        case .changed:
            // ---- UNIQUEMENT si swipe horizontal vers la droite (>0, et plus horizontal que vertical)
            let isSwipeRight = abs(translation.x) > abs(translation.y) && translation.x > 0
//            if isAtOriginPosition, isSwipeRight, let backdropView = backdropView, !backdropView.isHidden {
//                backdropView.isHidden = true
//            }

            // Swipe gauche / ouverture panel droit
            if isAtOriginPosition && isLeftwardDrag && !isPresentingRightPanel && !hasStartedRightPanelInteraction {
                hasStartedRightPanelInteraction = true
                isPresentingRightPanel = true
                delegate?.showRightPanelInteractive(from: gesture)
                return
            }
            if isPresentingRightPanel {
                if isLeftwardDrag {
                    let percent = min(max(-translation.x / view.bounds.width, 0), 1)
                    delegate?.updateRightPanelInteractiveTransition(percent: percent)
                }
                return
            }

            // Le reste (grab vertical, etc)
            handlePanChanged(view: view, translation: translation)

        case .ended, .cancelled:
            if isPresentingRightPanel {
                let percent = min(max(-translation.x / view.bounds.width, 0), 1)
                if percent > 0.3 {
                    delegate?.finishRightPanelInteractiveTransition()
                } else {
                    delegate?.cancelRightPanelInteractiveTransition()
                }
                isPresentingRightPanel = false
                hasStartedRightPanelInteraction = false
            } else {
                handlePanEnded(view: view, translation: translation)
            }

        default:
            break
        }
    }

    private func handlePanBegan(view: UIView) {
        originalPosition = view.center
        isDragging = false
        isPresentingRightPanel = false
        hasStartedRightPanelInteraction = false
        homeContainerView?.alpha = 0.6
    }

    private func handlePanChanged(view: UIView, translation: CGPoint) {
        if !isDragging {
            isDragging = true
            view.layer.cornerRadius = visuals.transitionCornerRadius
            view.layer.borderWidth = visuals.transitionBorderWidth
            view.layer.borderColor = visuals.transitionBorderColor
            view.clipsToBounds = true
        }
        
        // Drag XY libre avec effet scale/alpha
        applyTransformAndAlpha(view: view, translation: translation)
    }

    private func handlePanEnded(view: UIView, translation: CGPoint) {
        let isSwipeRight = abs(translation.x) > abs(translation.y) && translation.x > dismissThreshold
        let shouldDismissDown = translation.y > dismissThreshold
        
        if isSwipeRight {
            // Swipe horizontal droit = dismiss Hero vers carte
//            delegate?.triggerDismissByHeroToMap()
        } else if shouldDismissDown {
            // Swipe bas = dismiss classique vers Gallery
            delegate?.dimissFeedToGallery()
        } else {
            // Annule tout (reset)
            delegate?.resetDismissAnimation(to: originalPosition)
        }
        isDragging = false
    }

    // MARK: - Helpers

    private func applyTransformAndAlpha(view: UIView, translation: CGPoint) {
        let dampedX = damped(translation.x, factor: 200)
        let dampedY = damped(translation.y, factor: 200)
        let maxDrag: CGFloat = 300
        let distance = min(hypot(dampedX, dampedY), maxDrag)
        let progress = distance / maxDrag
        let scale = 1 - (0.5 * progress)
        let adjustedX = dampedX / scale
        let adjustedY = dampedY / scale

        view.transform = CGAffineTransform(translationX: adjustedX, y: adjustedY).scaledBy(x: scale, y: scale)
        overlayView?.alpha = .interpolate(from: 1.0, to: 0.4, progress: progress)
        homeContainerView?.alpha = .interpolate(from: 0.6, to: 1, progress: progress)
    }

    private func damped(_ value: CGFloat, factor: CGFloat) -> CGFloat {
        return value * factor / (abs(value) + factor)
    }
}

// Optionnel : pour vérifier transform == .identity
extension CGAffineTransform {
    var isIdentity: Bool { self == .identity }
}
