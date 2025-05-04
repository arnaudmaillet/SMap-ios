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
    }

    func resetDismissAnimation(to position: CGPoint?) {
        resetContentViewPosition(to: position)
    }
}

