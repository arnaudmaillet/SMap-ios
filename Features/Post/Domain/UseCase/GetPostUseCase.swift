//
//  GetPostUseCase.swift
//  SocialMap
//
//  Created by Arnaud Maillet on 17/10/2025.
//

extension PostNamespace.Application.UseCases {
    final class GetPostUseCase {
        typealias PostRepository = PostNamespace.Domain.Repositories.PostRepository
        typealias Post = PostNamespace.Domain.Entities.Post
        
        private let repository: PostRepository
        
        init(repository: PostRepository) {
            self.repository = repository
        }
        
        func execute(id: String) async throws -> Post {
            try await repository.getPost(by: id)
        }
    }
}
