//
//  FeedDismissControllable.swift
//  SocialMap
//
//  Created by Arnaud Maillet on 27/04/2025.
//

import UIKit

protocol FeedDismissControllable: AnyObject {
    func triggerDismiss()
    func resetDismissAnimation(to position: CGPoint?)
    func updateBackgroundDuringDismissGesture(progress: CGFloat)
}
