//
//  UIViewController+Extensions.swift
//  SocialMap
//
//  Created by Arnaud Maillet on 07/10/2025.
//

import UIKit

extension UIViewController {
    func cleanupController() {
        willMove(toParent: nil)
        view.removeFromSuperview()
        removeFromParent()
    }
}
