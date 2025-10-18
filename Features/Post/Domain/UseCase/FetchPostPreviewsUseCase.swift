//
//  FetchPostPreviewsUseCase.swift
//  SocialMap
//
//  Created by Arnaud Maillet on 14/10/2025.
//

import Foundation

extension PostFeature.Domain.UseCase {
    
    public protocol FetchPostPreviewsUseCase {
        typealias PostPreview = PostFeature.Domain.Model.PostPreview
        typealias PostAnnotation = MapFeature.Domain.Model.PostAnnotation
        typealias Annotation = MapFeature.Domain.Model.Annotation
        
        func execute(from annotation: PostAnnotation, within annotations: [Annotation]) async throws -> [PostPreview]
    }
    
    public final class DefaultFetchPostPreviewsUseCase: FetchPostPreviewsUseCase {
        typealias PostPreview = PostFeature.Domain.Model.PostPreview
        typealias PostRepository = PostFeature.Data.Repository.PostRepository
        
        private let repository: PostRepository
        
        public init(repository: PostRepository) {
            self.repository = repository
        }
        
        func execute(from annotation: PostAnnotation, within annotations: [Annotation]) async throws -> [PostPreview] {
            let circle = annotations.enclosingGeoCircle()
            let posts = try await repository.fetchPostPreviews(in: circle)
            return posts
        }
    }
}
