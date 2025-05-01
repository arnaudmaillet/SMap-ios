//
//  FeedViewControllerDelegate.swift
//  SocialMap
//
//  Created by Arnaud Maillet on 19/04/2025.
//

import UIKit

protocol FeedViewControllerDelegate: AnyObject {
    func feedViewShouldHideAnnotation()
    func feedDidDismiss()
}
