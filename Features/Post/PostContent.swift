//
//  PostContent.swift
//  SocialMap
//
//  Created by Arnaud Maillet on 16/04/2025.
//

enum PostContent: Equatable {
    case media(MediaContent)
    case gallery([MediaContent])
}

