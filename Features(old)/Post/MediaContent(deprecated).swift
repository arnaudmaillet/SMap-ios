//
//  MediaContent.swift
//  SocialMap
//
//  Created by Arnaud Maillet on 16/04/2025.
//

import UIKit

class MediaContent: PostRenderable, Identifiable, Equatable {
    var id: UUID
    let mediaKey: String
    let url: URL?
    let isVideo: Bool
    let thumbnailURL: URL?
    let isVertical: Bool
    var thumbnailImage: UIImage?
    var isDark: Bool?

    init(
        postId: UUID,
        url: URL,
        isVideo: Bool,
        thumbnailURL: URL? = nil,
        isVertical: Bool = false
    ) {
        self.id = UUID()
        self.url = url
        self.isVideo = isVideo
        self.thumbnailURL = thumbnailURL ?? url
        self.isVertical = isVertical
        self.mediaKey = "\(postId.uuidString)-\(url.absoluteString)"
    }

    init(
        localImage: UIImage,
        isVideo: Bool = false,
        isVertical: Bool = false
    ) {
        let generatedId = UUID()
        self.id = generatedId
        self.mediaKey = generatedId.uuidString
        self.url = nil
        self.thumbnailURL = nil
        self.isVideo = isVideo
        self.isVertical = isVertical
        self.thumbnailImage = localImage
    }

    static func == (lhs: MediaContent, rhs: MediaContent) -> Bool {
        lhs.id == rhs.id
    }
}

extension MediaContent {
    func duplicatedWithNewId() -> MediaContent {
        var copy = self
        copy.id = UUID()
        return copy
    }
}
