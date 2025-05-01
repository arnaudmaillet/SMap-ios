//
//  HomeViewModel.swift
//  SocialMap
//
//  Created by Arnaud Maillet on 09/04/2025.
//


import Foundation

final class HomeViewModel {

    private(set) var posts: [Post.Model] = []

    /// Load all post one shot
    func loadMockPosts(completion: @escaping ([Post.Model]) -> Void) {
        let mockPosts = MockPostProvider.generateMockPosts(count: 100)
        self.posts = mockPosts
        completion(mockPosts)
    }
    
    /// Load post when ready
    func loadMockPosts(
        onPostReady: @escaping (Post.Model) -> Void
    ) -> [Post.Model] {
        return MockPostProvider.generateMockPosts(onPostReady: onPostReady)
    }
}
