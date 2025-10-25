//
//  PostDTO.swift
//  SocialMap
//
//  Created by Arnaud Maillet on 17/10/2025.
//

import Foundation

extension PostNamespace.Application.DTOs {
    struct PostDTO: Decodable {
        let id: String
        let authorId: String
        let caption: String?
        let mediaIds: [String]
        let score: Int
        let createdAt: String
    }
}
