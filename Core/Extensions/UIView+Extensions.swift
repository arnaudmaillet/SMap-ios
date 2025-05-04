//
//  UIView+Extensions.swift
//  SocialMap
//
//  Created by Arnaud Maillet on 16/04/2025.
//

import UIKit

extension UIView {
    
    /// Finds the nearest parent view controller in the responder chain.
    var parentViewController: UIViewController? {
        var responder: UIResponder? = self
        while let currentResponder = responder {
            if let viewController = currentResponder as? UIViewController {
                return viewController
            }
            responder = currentResponder.next
        }
        return nil
    }
}
