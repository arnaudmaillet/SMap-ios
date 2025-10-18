//
//  FeedGestureManger.swift
//  SocialMap
//
//  Created by Arnaud Maillet on 21/07/2025.
//
import UIKit

final class FeedGestureManager: NSObject {
    private weak var container: FeedContainerControllable?
    
    private weak var coordinatorDelegate: FeedCoordinatorDelegate?
    private weak var coordinatorOnRightExit: FeedOnRightExitSide?
    private var gestureHandler: FeedGestureHandler?
    private var originalCenter: CGPoint = .zero
    
    private var feedPan: UIPanGestureRecognizer?
    private var containerPan: UIPanGestureRecognizer?

    init(coordinatorDelegate: FeedCoordinatorDelegate, coordinatorOnRightExit: FeedOnRightExitSide? = nil) {
        self.coordinatorDelegate = coordinatorDelegate
        self.coordinatorOnRightExit = coordinatorOnRightExit
        super.init()
    }

    func attach(container: FeedContainerControllable, post: Post.Model) {
        self.container = container
        
        guard let feedView = debugUnwrap(container.feedView) else { return }

        self.gestureHandler = FeedGestureHandler(
            visuals: HeroTransitionConfig.forPresentation(
                from: feedView,
                frame: feedView.frame,
                post: post,
                overlayView: container.overlayView
            )
        )
        
        guard let gestureHandler = debugUnwrap(gestureHandler) else { return }
        
        gestureHandler.gestureManager = self
        gestureHandler.container = container

        setupGestures()
    }

    private func setupGestures() {
        guard
            let container = debugUnwrap(container),
            let feedView = debugUnwrap(container.feedView),
            let containerView = debugUnwrap(container.containerView)
        else {
            return
        }

        let feedPan = UIPanGestureRecognizer(target: self, action: #selector(handleFeedPan(_:)))
        feedPan.delegate = self
        feedView.addGestureRecognizer(feedPan)
        self.feedPan = feedPan

        let containerPan = UIPanGestureRecognizer(target: self, action: #selector(handleContainerPan(_:)))
        containerPan.delegate = self
        containerView.addGestureRecognizer(containerPan)
        self.containerPan = containerPan
    }

    @objc private func handleFeedPan(_ gesture: UIPanGestureRecognizer) {
        guard
            let gestureHandler = debugUnwrap(gestureHandler)
        else {
            return
        }
        
        gestureHandler.handlePan(gesture)
    }

    @objc private func handleContainerPan(_ gesture: UIPanGestureRecognizer) {
        guard
            let container = debugUnwrap(container),
            let containerView = debugUnwrap(container.containerView)
        else {
            return
        }
        
        let translation = gesture.translation(in: containerView)

        switch gesture.state {
        case .began:
            originalCenter = containerView.center
            containerView.layer.masksToBounds = true
            containerView.layer.cornerRadius = UIConstant.device.cornerRadius
            container.scaleHomeView(to: UIConstant.view.zoomScale, animated: false)
        case .changed:
            applyTransformAndAlpha(to: containerView, translation: translation)
        case .ended, .cancelled:
            handlePanEnded(translation: translation, velocity: gesture.velocity(in: containerView))
        default:
            break
        }
    }

    private func handlePanEnded(translation: CGPoint, velocity: CGPoint) {
        guard
            let container = debugUnwrap(container),
            let containerView = debugUnwrap(container.containerView)
        else {
            return
        }

        let dismissDistance: CGFloat = 120
        let dismissVelocity: CGFloat = 900
        let shouldDismissRight = translation.x > dismissDistance || velocity.x > dismissVelocity

        if shouldDismissRight {
            coordinatorDelegate?.dismiss()
        } else {
            UIView.animate(withDuration: 0.25, animations: {
                containerView.transform = .identity
                containerView.layer.cornerRadius = 0
            }, completion: { _ in
                container.scaleHomeView(to: 1, animated: false)
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

extension FeedGestureManager: UIGestureRecognizerDelegate {
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        guard
            let container = debugUnwrap(container),
            let containerView = debugUnwrap(container.containerView)
        else {
            return false
        }

        if let pan = gestureRecognizer as? UIPanGestureRecognizer, gestureRecognizer.view === container.feedView {
            let velocity = pan.velocity(in: container.feedView)
            // Swipe vers le bas OU swipe vers la gauche
            if abs(velocity.y) > abs(velocity.x) && velocity.y > 0 {
                return true // Swipe bas (dismiss)
            } else if abs(velocity.x) > abs(velocity.y) && velocity.x < 0 {
                print("🎯 gestureRecognizerShouldBegin for \(gestureRecognizer.view) velocity: \(velocity)")
                return true // Swipe gauche (panel)
            }
            return false
        }

        if let pan = gestureRecognizer as? UIPanGestureRecognizer, gestureRecognizer.view === containerView {
            let velocity = pan.velocity(in: containerView)
            return abs(velocity.x) > abs(velocity.y) && velocity.x > 0
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
        coordinatorDelegate?.dismissFeedToGallery()
    }

    func resetDismiss(to position: CGPoint?) {
        guard
            let container = debugUnwrap(container)
        else { return }
        
        container.resetDismissAnimation(to: position)
    }

    func startRightPanel(from gesture: UIPanGestureRecognizer) {
        guard let coordinatorOnRightExit = debugUnwrap(coordinatorOnRightExit, level: .warning)
        else { return }
        coordinatorOnRightExit.presentUserProfile(from: gesture)
    }

    func updateRightPanel(percent: CGFloat) {
        guard
            let presentedVC = (container as? UIViewController)?.presentedViewController,
            let delegate = presentedVC.transitioningDelegate as? SidePanelTransitioningDelegate
        else { return }
        delegate.interactiveTransition?.update(percent)
    }

    func finishRightPanel() {
        guard
            let presentedVC = (container as? UIViewController)?.presentedViewController,
            let delegate = presentedVC.transitioningDelegate as? SidePanelTransitioningDelegate
        else { return }
        delegate.interactiveTransition?.finish()
        delegate.interactiveTransition = nil
    }

    func cancelRightPanel() {
        guard
            let presentedVC = (container as? UIViewController)?.presentedViewController,
            let delegate = presentedVC.transitioningDelegate as? SidePanelTransitioningDelegate
        else { return }
        delegate.interactiveTransition?.cancel()
        delegate.interactiveTransition = nil
    }
}
