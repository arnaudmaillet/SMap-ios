//
//  FeedViewController+FeedDimissControllable.swift
//  SocialMap
//
//  Created by Arnaud Maillet on 28/04/2025.
//

import Foundation

extension FeedViewController: FeedDismissControllable {
    func triggerDismiss() {
        dismissToOrigin()
        delegate?.resetMapAppearance()
    }

    func resetDismissAnimation(to position: CGPoint?) {
        resetContentViewPosition(to: position)
    }

    func updateBackgroundDuringDismissGesture(progress: CGFloat) {
        delegate?.updateBackgroundDuringDismissGesture(progress: progress)
    }
}

