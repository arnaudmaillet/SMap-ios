//
//  PostAPIClient.swift
//  SocialMap
//
//  Created by Arnaud Maillet on 17/10/2025.
//

import Foundation

extension PostNamespace.Infrastructure.APIs {
    protocol PostAPIClient {
        typealias PostDTO = PostNamespace.Application.DTOs.PostDTO
        func fetchPost(id: String) async throws -> PostDTO
    }
}
