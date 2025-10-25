//
//  FeedContainer.swift
//  SocialMap
//
//  Created by Arnaud Maillet on 05/10/2025.
//

extension FeedFeature.Container {
    final class FeedContainer: FeatureContainer {
        // MARK: - Typealiases
        typealias Post = PostNamespace.Domain.Entities.Post
        
        typealias PostAnnotation = MapFeature.Domain.Model.PostAnnotation
        typealias Annotation = MapFeature.Domain.Model.Annotation
        
        typealias PostRepository = PostNamespace.Data.Repository.PostRepository
        typealias LocalPostRepository = PostNamespace.Data.Repository.LocalPostRepository
        typealias RemotePostRepository = PostNamespace.Data.Repository.RemotePostRepository

        typealias FetchPostsUseCase = PostNamespace.Application.UseCases.FetchPostsUseCase
        typealias DefaultFetchPostsUseCase = PostNamespace.Application.UseCases.DefaultFetchPostsUseCase
        
        typealias FeedViewModel = FeedFeature.UI.ViewModel.FeedViewModel

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

        // MARK: - Factories
        
        func makeFeedViewModelFromAnnotation(_ annotation: PostAnnotation, in annotations: [Annotation]) async throws -> FeedViewModel {
            let stubPosts = try await makeFetchPostsUseCase().execute(from: annotation, within: annotations)
            print("mapVC.makeFeedViewModelFromAnnotation annotation:", annotation.id)
            print("mapVC.makeFeedViewModelFromAnnotation stubPosts:", stubPosts[0].id)
            
            // ✅ Contrôle : vérifier si l'annotation.id est bien présent dans stubPosts
            let found = stubPosts.contains { $0.id == annotation.id }

            if !found {
                print("⚠️ Attention : annotation.id \(annotation.id) n'est pas dans stubPosts !")
            } else {
                print("✅ annotation.id est bien présent dans stubPosts")
            }
            let viewModel = await makeFeedViewModel()
            await viewModel.load(with: stubPosts)
            return viewModel
        }

        @MainActor func makeFeedViewModel() -> FeedViewModel {
            let fetchPostsUseCase = makeFetchPostsUseCase()
            return FeedViewModel(fetchPostsUseCase: fetchPostsUseCase)
        }

        func makeFetchPostsUseCase() -> FetchPostsUseCase {
            DefaultFetchPostsUseCase(repository: postRepository)
        }
    }
}
