//
//  MediaSource.swift
//  SocialMap
//
//  Created by Arnaud Maillet on 07/10/2025.
//

import Foundation

extension MediaFeature.Domain.Model {

    public enum MediaSource: Equatable {
        case url(URL)
        case file(path: String)
        case asset(name: String)
    }
}
