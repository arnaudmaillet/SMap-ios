//
//  HomeViewController+FeedDelegate.swift
//  SocialMap
//
//  Created by Arnaud Maillet on 18/04/2025.
//

import UIKit

// MARK: - FeedViewControllerDelegate

extension HomeViewController: FeedControllerDelegate {
    
    /// Called when the feed view requests to hide the selected annotation
    func feedViewShouldHideAnnotation() {
        hideSelectedAnnotation()
    }

    /// Called when the feed view is dismissed
    func feedDidDismiss() {
        self.setMapInteractionEnabled(true)
        refreshLastSelectedAnnotation()
        resetLastSelectedAnnotation()
    }
    
    func animateMapResetDuringDismiss(progress: CGFloat) {
        let minimumScale: CGFloat = 0.95
        let currentScale = minimumScale + (1.0 - minimumScale) * progress
        contentView.transform = CGAffineTransform(scaleX: currentScale, y: currentScale)
    }
}
