//
//  UserMock.swift
//  SocialMap
//
//  Created by Arnaud Maillet on 15/10/2025.
//

import Foundation

extension UserFeature.Support.Mocks {
    struct UserMockFactory {
        typealias UserDTO = UserFeature.Application.DTOs.UserDTO
        typealias PostDTO = PostNamespace.Data.DTO.PostDTO

        static func makeCollection(from posts: [PostDTO]) -> [UserDTO] {
            // On regroupe les posts par auteur
            let grouped = Dictionary(grouping: posts, by: \.authorId)

            return grouped.map { (authorId, posts) in
                let username = MockNames.usernames.randomElement()!
                let avatar = MockAssets.avatars.randomElement()
                let bio = MockText.randomBio()

                return UserDTO(
                    id: authorId, // ✅ cohérent avec les posts
                    username: username,
                    avatar: avatar,
                    bio: bio,
                    followers: Int.random(in: 100...2000),
                    following: Int.random(in: 10...1000),
                    postCount: posts.count
                )
            }
        }
    }

    enum MockNames {
        static let usernames = [
            "arnaudmlt", "nina.art", "lucasphoto", "dreamy42", "matt.dev", "explora_x", "wild.heart"
        ]
    }

    enum MockAssets {
        static let avatars = [
            "avatar_1", "avatar_2", "avatar_3", "avatar_4", "avatar_5"
        ]
    }

    enum MockText {
        static let bios = [
            "Lover of sunsets 🌅",
            "Sharing moments from life",
            "Tech & coffee addict ☕️💻",
            "Follow my travels 🌍✈️",
            "Capturing emotions 🎞️"
        ]

        static func randomBio() -> String {
            bios.randomElement()!
        }
    }
}
