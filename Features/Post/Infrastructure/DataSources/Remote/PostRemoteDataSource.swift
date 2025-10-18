//
//  PostRemoteDataSource.swift
//  SocialMap
//
//  Created by Arnaud Maillet on 17/10/2025.
//

import Foundation

extension PostFeature.Infrastructure.DataSources {
    protocol PostRemoteDataSource {
        typealias Post = PostFeature.Domain.Entities.Post
        func getPost(by id: String) async throws -> Post
    }
}
