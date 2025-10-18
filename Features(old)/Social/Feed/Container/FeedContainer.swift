//
//  FeedContainer.swift
//  SocialMap
//
//  Created by Arnaud Maillet on 05/10/2025.
//

extension FeedFeature.Container {
    final class FeedContainer: FeatureContainer {
        // MARK: - Typealiases
        typealias Post = PostFeature.Domain.Model.Post
        
        typealias PostAnnotation = MapFeature.Domain.Model.PostAnnotation
        typealias Annotation = MapFeature.Domain.Model.Annotation
        
        typealias PostRepository = PostFeature.Data.Repository.PostRepository
        typealias LocalPostRepository = PostFeature.Data.Repository.LocalPostRepository
        typealias RemotePostRepository = PostFeature.Data.Repository.RemotePostRepository

        typealias FetchPostsUseCase = PostFeature.Domain.UseCase.FetchPostsUseCase
        typealias DefaultFetchPostsUseCase = PostFeature.Domain.UseCase.DefaultFetchPostsUseCase
        
        typealias FeedViewModel = FeedFeature.UI.ViewModel.FeedViewModel

        // MARK: - Properties
        private let postRepository: PostRepository

        // MARK: - Init
        init(env: AppEnvironment) {
            if env == .local {
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
