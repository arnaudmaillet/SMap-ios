//
//  UIApplication+Extensions.swift
//  SocialMap
//
//  Created by Arnaud Maillet on 21/04/2025.
//

import UIKit

extension UIApplication {
    static var globalSafeAreaInsets: UIEdgeInsets {
        UIApplication.shared
            .connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .flatMap { $0.windows }
            .first { $0.isKeyWindow }?
            .safeAreaInsets ?? .zero
    }
}
