//
//  FeedViewModel.swift
//  SocialMap
//
//  Created by Arnaud Maillet on 05/10/2025.
//

import Foundation

extension FeedFeature.UI.ViewModel {

    @MainActor
    final class FeedViewModel: ObservableObject {
        // MARK: - Typealiases
        typealias Post = PostNamespace.Domain.Entities.Post
        typealias FetchPostsUseCase = PostNamespace.Application.UseCases.FetchPostsUseCase

        // MARK: - Published properties
        @Published private(set) var posts: [Post] = []
        @Published private(set) var isLoading: Bool = false
        @Published private(set) var errorMessage: String?

        // MARK: - Dependencies
        private let fetchPostsUseCase: FetchPostsUseCase

        // MARK: - Init
        init(fetchPostsUseCase: FetchPostsUseCase) {
            self.fetchPostsUseCase = fetchPostsUseCase
        }

        // MARK: - Public methods

        /// Charge les posts fournis par le container au moment de l'initialisation
        func load(with posts: [Post]) {
            self.isLoading = false
            self.errorMessage = nil
            self.posts = posts
        }

        /// Charge un post complet si celui-ci est partiel
        func loadIfNeeded(for id: UUID) async {
            guard let index = posts.firstIndex(where: { $0.id == id }) else { return }
            guard posts[index].isFull == false else { return }

            isLoading = true
            defer { isLoading = false }

            do {
                let results = try await fetchPostsUseCase.execute(ids: [id])
                if let fullPost = results.first {
                    posts[index] = fullPost
                }
            } catch {
                errorMessage = "Impossible de charger le post : \(error.localizedDescription)"
            }
        }

        /// Recharge tous les posts partiels (`isFull == false`)
        func loadIncompletePosts() async {
            isLoading = true
            defer { isLoading = false }

            let incompleteIDs = posts.filter { !$0.isFull }.map(\.id)
            guard !incompleteIDs.isEmpty else { return }

            do {
                let fullPosts = try await fetchPostsUseCase.execute(ids: incompleteIDs)
                for post in fullPosts {
                    if let idx = posts.firstIndex(where: { $0.id == post.id }) {
                        posts[idx] = post
                    }
                }
            } catch {
                errorMessage = "Erreur lors du chargement des posts : \(error.localizedDescription)"
            }
        }

        func post(at index: Int) -> Post? {
            guard posts.indices.contains(index) else { return nil }
            return posts[index]
        }

        var totalCount: Int {
            posts.count
        }
    }
}
