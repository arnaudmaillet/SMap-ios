//
//  MediaContent.swift
//  SocialMap
//
//  Created by Arnaud Maillet on 16/04/2025.
//

import UIKit


class MediaContent: PostRenderable {
    let url: URL
    let isVideo: Bool
    let thumbnailURL: URL
    let isVertical: Bool
    var thumbnailImage: UIImage?
    
    // case image
    var isDark: Bool?
    

    init(url: URL, isVideo: Bool, thumbnailURL: URL? = nil, isVertical: Bool = false) {
        self.url = url
        self.isVideo = isVideo
        self.thumbnailURL = thumbnailURL ?? url
        self.isVertical = isVertical
    }
}

extension MediaContent: Equatable {
    static func == (lhs: MediaContent, rhs: MediaContent) -> Bool {
        lhs.url == rhs.url &&
        lhs.thumbnailURL == rhs.thumbnailURL &&
        lhs.isVideo == rhs.isVideo &&
        lhs.isVertical == rhs.isVertical
    }
}
