//
//  HomeViewModel.swift
//  SocialMap
//
//  Created by Arnaud Maillet on 09/04/2025.
//


import Foundation

final class HomeViewModel {

    private(set) var posts: [Post.Model] = []

    func loadMockPosts(
        offline: Bool = false,
        videoOnly: Bool = false,
        completion: @escaping ([Post.Model]) -> Void
    ) {
        let mockPosts = MockPostProvider.generateMockPosts(count: 100, offline: offline, videoOnly: videoOnly)
        self.posts = mockPosts
        completion(mockPosts)
    }

    func loadMockPosts(
        offline: Bool = false,
        videoOnly: Bool = false,
        onPostReady: @escaping (Post.Model) -> Void
    ) -> [Post.Model] {
        return MockPostProvider.generateMockPosts(offline: offline, videoOnly: videoOnly, onPostReady: onPostReady)
    }
    
    func loadMockPostsSync(offline: Bool = false) -> [Post.Model] {
        let mockPosts = MockPostProvider.generateMockPosts(count: 100, offline: offline)
        self.posts = mockPosts
        return mockPosts
    }
}
