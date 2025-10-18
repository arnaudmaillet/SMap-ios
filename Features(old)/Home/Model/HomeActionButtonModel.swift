//
//  HomeActionButtonModel.swift
//  SocialMap
//
//  Created by Arnaud Maillet on 21/06/2025.
//

import UIKit

struct HomeActionButtonModel {
    let iconName: String?
    let title: String?

    init(iconName: String? = nil, title: String? = nil) {
        self.iconName = iconName
        self.title = title
    }
}
