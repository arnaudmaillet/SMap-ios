//
//  ProfileContainer.swift
//  SocialMap
//
//  Created by Arnaud Maillet on 14/10/2025.
//

extension ProfileFeature.Container {
    final class ProfileContainer: FeatureContainer {
        // MARK: - Typealiases
        typealias PostPreview = PostNamespace.Domain.Entities.PostPreview

        typealias PostRepository = PostNamespace.Data.Repository.PostRepository
        typealias LocalPostRepository = PostNamespace.Data.Repository.LocalPostRepository
        typealias RemotePostRepository = PostNamespace.Data.Repository.RemotePostRepository
        
        typealias PostAnnotation = MapFeature.Domain.Model.PostAnnotation
        typealias Annotation = MapFeature.Domain.Model.Annotation

        typealias FetchPostPreviewsUseCase = PostNamespace.Application.UseCases.FetchPostPreviewsUseCase
        typealias DefaultFetchPostPreviewsUseCase = PostNamespace.Application.UseCases.DefaultFetchPostPreviewsUseCase

        typealias ProfileViewModel = ProfileFeature.UI.ViewModel.ProfileViewModel

        // MARK: - Properties
        private let postRepository: PostRepository

        // MARK: - Init
        init(env: AppEnvironment) {
            if env == .mock {
                self.postRepository = LocalPostRepository()
            } else {
                let apiClient = DefaultAPIClient(env: env)
                self.postRepository = RemotePostRepository(apiClient: apiClient)
            }
        }

        // MARK: - Factory
        
        func makeProfileViewModelFromAnnotation(_ annotation: PostAnnotation, in annotations: [Annotation]) async throws -> ProfileViewModel {
            let authorId = annotation.authorId

            // 1. Extraire tous les PostAnnotations visibles du même auteur
            let filteredAnnotations = annotations.compactMap { $0 as? PostAnnotation }
                .filter { $0.authorId == authorId }

            // 2. Extraire les postIds correspondants
            let postIds = filteredAnnotations.map(\.id)

            // 3. Charger les posts complets
            let posts = try await postRepository.fetchPosts(ids: postIds)

            // 4. Mapper en PostPreview
            let previews: [PostPreview] = posts.compactMap { post in
                guard let media = post.media.first else { return nil }

                return PostPreview(
                    id: post.id,
                    authorId: post.authorId,
                    caption: post.caption,
                    mediaPreview: media,
                    score: post.score,
                    createdAt: post.createdAt
                )
            }

            let viewModel = await makeProfileViewModel()
            await viewModel.load(with: previews)
            return viewModel
        }

        @MainActor func makeProfileViewModel() -> ProfileViewModel {
            let fetchUseCase: FetchPostPreviewsUseCase = makeFetchPostPreviewsUseCase()
            return ProfileViewModel(fetchPreviewsUseCase: fetchUseCase)
        }

        func makeFetchPostPreviewsUseCase() -> FetchPostPreviewsUseCase {
            DefaultFetchPostPreviewsUseCase(repository: postRepository)
        }
    }
}
