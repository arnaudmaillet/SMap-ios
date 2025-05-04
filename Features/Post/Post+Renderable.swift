//
//  Post+Renderable.swift
//  SocialMap
//
//  Created by Arnaud Maillet on 16/04/2025.
//

import Foundation

extension Post.Model {
    var mainRenderable: PostRenderable? {
        switch content {
        case .media(let media): return media
        case .gallery(let medias): return medias.first
        }
    }
}
