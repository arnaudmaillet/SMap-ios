//
//  MediaSourceResolving.swift
//  SocialMap
//
//  Created by Arnaud Maillet on 07/10/2025.
//

extension MediaFeature.Domain.Contract {
    public protocol MediaSourceResolving {
        typealias MediaSource = MediaFeature.Domain.Model.MediaSource
        func resolveSource(from rawPath: String) -> MediaSource?
    }

}
