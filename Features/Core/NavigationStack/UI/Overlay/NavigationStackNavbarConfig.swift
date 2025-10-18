//
//  NavigationStackNavbarConfig.swift
//  SocialMap
//
//  Created by Arnaud Maillet on 13/10/2025.
//

import UIKit

extension NavigationStackFeature.UI.Overlay {
    struct NavbarConfig {
        let title: String?
        let prefersLargeTitles: Bool
        let hidesNavbar: Bool
        let leftItems: [UIBarButtonItem]?
        let rightItems: [UIBarButtonItem]?
        
        static let `default` = NavbarConfig(
            title: nil,
            prefersLargeTitles: false,
            hidesNavbar: true,
            leftItems: nil,
            rightItems: nil
        )
    }
}
