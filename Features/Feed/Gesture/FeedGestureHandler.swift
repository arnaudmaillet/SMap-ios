//
//  FeedPanGestureHandler.swift
//  SocialMap
//
//  Created by Arnaud Maillet on 27/04/2025.
//

import UIKit

final class FeedGestureHandler {

    // MARK: - Public Properties

    weak var gestureManager: FeedGestureManager?
    weak var overlayView: UIView?
    weak var feedView: UIView?
    weak var galleryView: UIView?
    weak var container: FeedContainerViewController?


    // MARK: - Private Properties

    private var isDragging = false
    private var originalPosition: CGPoint?
    private let visuals: HeroTransitionVisuals
    private let dismissThreshold: CGFloat = 160

    private var isPresentingRightPanel = false
    private var hasStartedRightPanelInteraction = false

    // MARK: - Init

    init(feedView: UIView, galleryView: UIView?, overlayView: UIView?, visuals: HeroTransitionVisuals, gestureManager: FeedGestureManager?) {
        self.feedView = feedView
        self.overlayView = overlayView
        self.galleryView = galleryView
        self.visuals = visuals
        self.gestureManager = gestureManager
        self.container = gestureManager?.container
    }

    // MARK: - Gesture Handling

    func handlePan(_ gesture: UIPanGestureRecognizer) {
        guard let view = feedView else { return }

        let translation = gesture.translation(in: view)
        let isAtOriginPosition = view.transform.isIdentity
        let isLeftwardDrag = translation.x < 0

        switch gesture.state {
        case .began:
            handlePanBegan(view: view)

        case .changed:
            // Swipe horizontal vers la droite
            let isSwipeRight = abs(translation.x) > abs(translation.y) && translation.x > 0
            if isAtOriginPosition, isSwipeRight {
                print("➡️ Swipe right in feed")
            }

            // Swipe gauche : ouverture panel droit
            if isAtOriginPosition && isLeftwardDrag && !isPresentingRightPanel && !hasStartedRightPanelInteraction {
                hasStartedRightPanelInteraction = true
                isPresentingRightPanel = true
                gestureManager?.startRightPanel(from: gesture)
                return
            }

            if isPresentingRightPanel {
                if isLeftwardDrag {
                    let percent = min(max(-translation.x / view.bounds.width, 0), 1)
                    gestureManager?.updateRightPanel(percent: percent)
                }
                return
            }

            // Drag libre vertical
            handlePanChanged(view: view, translation: translation)

        case .ended, .cancelled:
            if isPresentingRightPanel {
                let percent = min(max(-translation.x / view.bounds.width, 0), 1)
                if percent > 0.3 {
                    gestureManager?.finishRightPanel()
                } else {
                    gestureManager?.cancelRightPanel()
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

    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        if let pan = gestureRecognizer as? UIPanGestureRecognizer {
            let velocity = pan.velocity(in: feedView)
            return abs(velocity.y) > abs(velocity.x) && velocity.y > 0
        }
        return true
    }

    // MARK: - Private Helpers

    private func handlePanBegan(view: UIView) {
        if let post = container?.feedVC.currentPost {
            container?.coordinator.prepareGalleryForDismiss(for: post)
        }

        galleryView?.transform = CGAffineTransform(scaleX: UIConstant.view.zoomScale, y: UIConstant.view.zoomScale)
        originalPosition = view.center
        isDragging = false
        isPresentingRightPanel = false
        hasStartedRightPanelInteraction = false
    }

    private func handlePanChanged(view: UIView, translation: CGPoint) {
        if !isDragging {
            isDragging = true
            view.layer.cornerRadius = visuals.transitionCornerRadius
            view.layer.borderWidth = visuals.transitionBorderWidth
            view.layer.borderColor = visuals.transitionBorderColor
            view.clipsToBounds = true
        }

        applyTransformAndAlpha(view: view, translation: translation)
    }

    private func handlePanEnded(view: UIView, translation: CGPoint) {
        let shouldDismiss = translation.y > dismissThreshold
        if shouldDismiss {
            gestureManager?.dismissFeedToGallery()
        } else {
            gestureManager?.resetDismiss(to: originalPosition)
        }

        isDragging = false
    }

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
    }

    private func damped(_ value: CGFloat, factor: CGFloat) -> CGFloat {
        return value * factor / (abs(value) + factor)
    }
}
