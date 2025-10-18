//
//  PostAPIClient.swift
//  SocialMap
//
//  Created by Arnaud Maillet on 17/10/2025.
//

import Foundation

protocol PostAPIClient {
    typealias PostDTO = PostFeature.Application.DTOs.PostDTO
    func fetchPost(id: String) async throws -> PostDTO
}
