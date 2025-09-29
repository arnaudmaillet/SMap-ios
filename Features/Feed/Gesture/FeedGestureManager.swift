//
//  FeedGestureCoordinator.swift
//  SocialMap
//
//  Created by Arnaud Maillet on 21/07/2025.
//
import UIKit

final class FeedGestureCoordinator: NSObject {

    // MARK: - Properties

    weak var container: FeedContainerViewController?
    private weak var feedView: UIView?
    private weak var galleryView: UIView?
    private weak var overlayView: UIView?

    private let dismissHandler: FeedDismissGestureHandler
    private var containerPan: UIPanGestureRecognizer!
    private var originalCenter: CGPoint = .zero

    private let coordinator: FeedContainerCoordinatorProtocol
    
    // MARK: - Init

    init(container: FeedContainerViewController,
         coordinator: FeedContainerCoordinatorProtocol,
         feedView: UIView,
         galleryView: UIView,
         overlayView: UIView?,
         post: Post.Model) {

        self.container = container
        self.coordinator = coordinator
        self.feedView = feedView
        self.galleryView = galleryView
        self.overlayView = overlayView

        self.dismissHandler = FeedDismissGestureHandler(
            feedView: feedView,
            galleryView: galleryView,
            overlayView: overlayView,
            visuals: HeroTransitionConfig.forPresentation(
                from: feedView,
                frame: .zero,
                post: post,
                overlayView: overlayView
            ),
            coordinator: nil
        )

        super.init()

        dismissHandler.coordinator = self
        dismissHandler.container = container

        setupGestures()
    }

    // MARK: - Setup

    private func setupGestures() {
        let feedPan = UIPanGestureRecognizer(target: self, action: #selector(handleFeedPan(_:)))
        feedPan.delegate = self
        feedView?.addGestureRecognizer(feedPan)

        containerPan = UIPanGestureRecognizer(target: self, action: #selector(handleContainerPan(_:)))
        containerPan.delegate = self
        container?.view.addGestureRecognizer(containerPan)
    }

    // MARK: - Feed Pan (vertical)

    @objc private func handleFeedPan(_ gesture: UIPanGestureRecognizer) {
        dismissHandler.handlePan(gesture)
    }

    // MARK: - Container Pan (horizontal)

    @objc private func handleContainerPan(_ gesture: UIPanGestureRecognizer) {
        guard let containerView = container?.view else { return }
        let translation = gesture.translation(in: containerView)

        switch gesture.state {
        case .began:
            originalCenter = containerView.center
            containerView.layer.masksToBounds = true
            containerView.layer.cornerRadius = UIConstant.device.cornerRadius
            container?.scaleHomeView(to: UIConstant.view.zoomScale)
        case .changed:
            applyTransformAndAlpha(to: containerView, translation: translation)
        case .ended, .cancelled:
            handlePanEnded(translation: translation, velocity: gesture.velocity(in: containerView))
        default:
            break
        }
    }

    private func handlePanEnded(translation: CGPoint, velocity: CGPoint) {
        guard let container = container else { return }
        let dismissDistance: CGFloat = 120
        let dismissVelocity: CGFloat = 900

        let shouldDismissRight = translation.x > dismissDistance || velocity.x > dismissVelocity

        if shouldDismissRight {
            coordinator.dismissToMap()
        } else {
            UIView.animate(withDuration: 0.25, animations: {
                container.view.transform = .identity
                container.view.layer.cornerRadius = 0
            }, completion: { _ in
                container.scaleHomeView(to: 1)
            })
        }
    }

    private func applyTransformAndAlpha(to view: UIView, translation: CGPoint) {
        let dampedX = damped(translation.x, factor: 200)
        let dampedY = damped(translation.y, factor: 200)
        let maxDrag: CGFloat = 300
        let distance = min(hypot(dampedX, dampedY), maxDrag)
        let progress = distance / maxDrag
        let scale = 1 - (0.5 * progress)
        let adjustedX = dampedX / scale
        let adjustedY = dampedY / scale

        view.transform = CGAffineTransform(translationX: adjustedX, y: adjustedY).scaledBy(x: scale, y: scale)
    }

    private func damped(_ value: CGFloat, factor: CGFloat) -> CGFloat {
        return value * factor / (abs(value) + factor)
    }
}

// MARK: - UIGestureRecognizerDelegate

extension FeedGestureCoordinator: UIGestureRecognizerDelegate {
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        if gestureRecognizer === containerPan {
            let velocity = (gestureRecognizer as! UIPanGestureRecognizer).velocity(in: container?.view)
            return abs(velocity.x) > abs(velocity.y) && velocity.x > 0
        }

        if gestureRecognizer.view === feedView {
            let velocity = (gestureRecognizer as! UIPanGestureRecognizer).velocity(in: feedView)
            return abs(velocity.y) > abs(velocity.x) && velocity.y > 0
        }

        return true
    }

    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        if gestureRecognizer === containerPan || otherGestureRecognizer === containerPan {
            return false
        }
        return true
    }
    
    func dismissFeedToGallery() {
        coordinator.dismissFeedToGallery()
    }

    func resetDismiss(to position: CGPoint?) {
        container?.resetDismissAnimation(to: position)
    }

    func startRightPanel(from gesture: UIPanGestureRecognizer) {
//        container.delegate?.showRightPanelInteractive(from: gesture)
    }

    func updateRightPanel(percent: CGFloat) {
//        container.delegate?.updateRightPanelInteractiveTransition(percent: percent)
    }

    func finishRightPanel() {
//        container.delegate?.finishRightPanelInteractiveTransition()
    }

    func cancelRightPanel() {
//        container.delegate?.cancelRightPanelInteractiveTransition()
    }
}
