//
//  FeedViewControllerDelegate.swift
//  SocialMap
//
//  Created by Arnaud Maillet on 19/04/2025.
//

import UIKit

protocol FeedControllerDelegate: AnyObject {
    func feedViewShouldHideAnnotation()
    func feedDidDismiss()
    func currentAnnotationFrameInWindow() -> CGRect?
    func animateMapResetDuringDismiss(progress: CGFloat)
}
