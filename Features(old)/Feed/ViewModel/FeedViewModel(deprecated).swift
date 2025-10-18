//
//  FeedViewModel.swift
//  SocialMap
//
//  Created by Arnaud Maillet on 30/09/2025.
//

import Foundation

final class FeedViewModel {
    private(set) var posts: [Post.Model]
    var onPostsUpdated: (() -> Void)?

    init(posts: [Post.Model]) {
        self.posts = posts
    }

    // MARK: - Public API

    func post(at index: Int) -> Post.Model? {
        posts[safe: index]
    }

    func numberOfPosts() -> Int {
        posts.count
    }

    func replacePost(at index: Int, with post: Post.Model) {
        guard posts.indices.contains(index) else {
            print("⚠️ [FeedViewModel] Aucun post à remplacer à l'index \(index)")
            return
        }
        posts[index] = post
        onPostsUpdated?()
    }

    func insertPost(_ post: Post.Model, at index: Int) {
        guard index <= posts.count && index >= 0 else {
            print("⚠️ [FeedViewModel] Index \(index) invalide pour insertion")
            return
        }
        posts.insert(post, at: index)
        onPostsUpdated?()
    }

    func removePost(at index: Int) {
        guard posts.indices.contains(index) else { return }
        posts.remove(at: index)
        onPostsUpdated?()
    }

    func removeAllPosts() {
        posts.removeAll()
        onPostsUpdated?()
    }

    func containsPost(withId id: UUID) -> Bool {
        return posts.contains(where: { $0.id == id })
    }

    func indexOfPost(withId id: UUID) -> Int? {
        return posts.firstIndex(where: { $0.id == id })
    }
}
