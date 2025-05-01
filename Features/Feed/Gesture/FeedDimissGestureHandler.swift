//
//  FeedDismissGestureHandler.swift
//  SocialMap
//
//  Created by Arnaud Maillet on 27/04/2025.
//

import UIKit

final class FeedDismissGestureHandler {

    // MARK: - Public Properties

    weak var delegate: FeedDismissControllable?
    weak var overlayView: UIView?

    // MARK: - Private Properties

    private weak var view: UIView?
    private weak var background: UIView?

    private var hasLockedDirection = false
    private var isHorizontalSwipe = false
    private var isDragging = false
    private var originalPosition: CGPoint?

    // MARK: - Init

    init(view: UIView, background: UIView, overlayView: UIView?) {
        self.view = view
        self.background = background
        self.overlayView = overlayView
    }

    // MARK: - Gesture Handling

    func handlePan(_ gesture: UIPanGestureRecognizer) {
        guard let view = view else { return }
        let translation = gesture.translation(in: view)

        switch gesture.state {
        case .began:
            handlePanBegan(view: view)

        case .changed:
            handlePanChanged(view: view, translation: translation)

        case .ended, .cancelled:
            handlePanEnded(translation: translation)

        default:
            break
        }
    }

    private func handlePanBegan(view: UIView) {
        originalPosition = view.center
        isDragging = false
        hasLockedDirection = false
        isHorizontalSwipe = false
    }

    private func handlePanChanged(view: UIView, translation: CGPoint) {
        if !hasLockedDirection {
            if abs(translation.x) > 20 || abs(translation.y) > 20 {
                isHorizontalSwipe = abs(translation.x) > abs(translation.y)
                hasLockedDirection = true

                if isHorizontalSwipe {
                    if translation.x < 0 {
                        hasLockedDirection = false
                        isHorizontalSwipe = false
                        return
                    }
                } else {
                    return
                }
            } else {
                return
            }
        }

        guard isHorizontalSwipe else { return }

        if !isDragging {
            isDragging = true
            view.layer.cornerRadius = 55
            view.clipsToBounds = true
        }

        applyTransformAndAlpha(view: view, translation: translation)
    }

    private func handlePanEnded(translation: CGPoint) {
        if isDragging {
            let totalDrag = hypot(translation.x, translation.y)
            let dismissThreshold: CGFloat = 160

            if totalDrag > dismissThreshold {
                delegate?.triggerDismiss()
            } else {
                delegate?.resetDismissAnimation(to: originalPosition)
            }
            isDragging = false
        }

        hasLockedDirection = false
        isHorizontalSwipe = false
    }

    // MARK: - Private Helpers

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
        background?.alpha = .interpolate(from: 0.4, to: 0.2, progress: progress)
        overlayView?.alpha = .interpolate(from: 1.0, to: 0.4, progress: progress)
        delegate?.updateBackgroundDuringDismissGesture(progress: progress)
    }

    private func damped(_ value: CGFloat, factor: CGFloat) -> CGFloat {
        return value * factor / (abs(value) + factor)
    }
}
