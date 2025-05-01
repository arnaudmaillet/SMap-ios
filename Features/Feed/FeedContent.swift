//
//  FeedContent.swift
//  SocialMap
//
//  Created by Arnaud Maillet on 19/04/2025.
//

import Foundation

enum FeedContent {
    case single(Post.Model)
    case multiple([Post.Model])

    var posts: [Post.Model] {
        switch self {
        case .single(let post):
            return [post]
        case .multiple(let posts):
            return posts.sorted(by: { $0.score > $1.score })
        }
    }
}
