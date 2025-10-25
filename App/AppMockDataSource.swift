//
//  AppMockDataSource.swift
//  SocialMap
//
//  Created by Arnaud Maillet on 05/10/2025.
//

import Foundation

final class AppMockDataSource {
    typealias PostDTO = PostNamespace.Data.DTO.PostDTO
    typealias UserDTO = UserFeature.Application.DTOs.UserDTO
    typealias AnnotationDTO = MapFeature.Data.DTO.AnnotationDTO

    static let shared = AppMockDataSource()

    // MARK: - Source principale
    let posts: [PostDTO]

    // MARK: - Dérivés
    let users: [UserDTO]
    let annotations: [AnnotationDTO]

    private init() {
        // 1️⃣ Posts = source de vérité
        posts = PostNamespace.Data.Mock.PostMockFactory.makeCollection(count: 30)

        // 2️⃣ Users générés à partir des posts (en fonction des authorId)
        users = UserFeature.Support.Mocks.UserMockFactory.makeCollection(from: posts)

        // 3️⃣ Annotations dérivées des posts
        annotations = MapFeature.Data.Mock.MapAnnotationMockFactory.makeCollection(from: posts)
    }
}
