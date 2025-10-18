//
//  NavigationStackViewOverlay.swift
//  SocialMap
//
//  Created by Arnaud Maillet on 13/10/2025.
//

import UIKit

extension NavigationStackFeature.UI.Overlay {
    protocol NavigationStackOverlayConfigurable {
        var navigationOverlay: NavigationStackOverlay { get }
    }

    struct NavigationStackOverlay {
        let navbar: NavbarConfig
        let toolbar: ToolbarConfig
        let interfaceStyle: UIUserInterfaceStyle

        static let `default` = NavigationStackOverlay(
            navbar: .default,
            toolbar: .default,
            interfaceStyle: .unspecified
        )
    }
}
