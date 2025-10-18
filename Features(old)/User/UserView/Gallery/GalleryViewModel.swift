//
//  GalleryViewModel.swift
//  SocialMap
//
//  Created by Arnaud Maillet on 23/09/2025.
//

import Foundation

final class GalleryViewModel {
    private(set) var user: User
    // Observateur appelé quand un post est mis à jour
    var onPostUpdated: ((Post.Model) -> Void)?
    private(set) var posts: [Post.Model]

    init(user: User) {
        self.user = user
        self.posts = user.posts
    }
    
    func post(at index: Int) -> Post.Model? {
        guard posts.indices.contains(index) else { return nil }
        return posts[index]
    }
    
    func replacePost(at index: Int, with newPost: Post.Model) {
        guard posts.indices.contains(index) else { return }
        posts[index] = newPost
    }

    func post(forMediaId id: UUID) -> Post.Model? {
        return posts.first(where: { $0.content.containsMedia(withId: id) })
    }
}
