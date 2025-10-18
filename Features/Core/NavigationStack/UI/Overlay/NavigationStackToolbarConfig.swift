//
//  NavigationStackToolbarConfig.swift
//  SocialMap
//
//  Created by Arnaud Maillet on 13/10/2025.
//

import UIKit

extension NavigationStackFeature.UI.Overlay {
    struct ToolbarConfig {
        let hidesToolbar: Bool
        let items: [UIBarButtonItem]?
        
        static let `default` = ToolbarConfig(
            hidesToolbar: true,
            items: nil
        )
    }
}
