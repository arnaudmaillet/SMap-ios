//
//  UserMockFactory.swift
//  SocialMap
//
//  Created by Arnaud Maillet on 21/10/2025.
//

import Foundation

extension UserNamespace.Infrastructure.Factories {
    struct UserMockFactory {
        typealias User = UserNamespace.Domain.Entities.User

        typealias UserID = UserNamespace.Domain.ValueObjects.UserID
        typealias Username = UserNamespace.Domain.ValueObjects.Username
        typealias DisplayName = UserNamespace.Domain.ValueObjects.DisplayName
        typealias AvatarURL = UserNamespace.Domain.ValueObjects.AvatarURL
        typealias Bio = UserNamespace.Domain.ValueObjects.Bio

        typealias FollowersCount = UserNamespace.Domain.ValueObjects.FollowersCount
        typealias FollowingCount = UserNamespace.Domain.ValueObjects.FollowingCount
        typealias PostCount = UserNamespace.Domain.ValueObjects.PostCount

        typealias CreatedAt = UserNamespace.Domain.ValueObjects.CreatedAt
        typealias UpdatedAt = UserNamespace.Domain.ValueObjects.UpdatedAt

        typealias Location = UserNamespace.Domain.ValueObjects.Location
        typealias WebsiteURL = UserNamespace.Domain.ValueObjects.WebsiteURL

        typealias AccountStatus = UserNamespace.Domain.ValueObjects.AccountStatus

        static func generate(count: Int) -> [UserID: User] {
            var dict: [UserID: User] = [:]

            for i in 1...count {
                do {
                    let id = try makeUserID(i)
                    let user = try makeMockUser(for: id, index: i)
                    dict[id] = user
                } catch let error as MockFactoryError {
                    print("⚠️ UserMockFactory: \(error)")
                    continue
                } catch {
                    print("⚠️ UserMockFactory: Unexpected error: \(error)")
                    continue
                }
            }

            return dict
        }
    }
}

// MARK: - Helpers

private extension UserNamespace.Infrastructure.Factories.UserMockFactory {
    
    static func makeUserID(_ i: Int) throws -> UserID {
        guard let id = UserID("user-\(i)") else {
            throw MockFactoryError.invalidValue(field: "id", value: "user-\(i)")
        }
        return id
    }

    static func makeMockUser(for id: UserID, index i: Int) throws -> User {
        guard let username = Username("user\(i)") else {
            throw MockFactoryError.invalidValue(field: "username", value: "user\(i)")
        }

        guard let avatarURL = AvatarURL("https://picsum.photos/id/\(i + 30)/100") else {
            throw MockFactoryError.invalidValue(field: "avatarURL", value: "https://picsum.photos/id/\(i + 30)/100")
        }

        let displayName = DisplayName("User \(i)")
        let bio = Bio("Bio de l'utilisateur \(i)")

        // MARK: - Validation stricte des compteurs
        let randomFollowers = Int.random(in: 100...1000)
        let randomFollowing = Int.random(in: 10...300)
        let randomPosts = Int.random(in: 0...50)

        guard let followersCount = FollowersCount(randomFollowers) else {
            throw MockFactoryError.invalidValue(field: "followersCount", value: randomFollowers)
        }
        guard let followingCount = FollowingCount(randomFollowing) else {
            throw MockFactoryError.invalidValue(field: "followingCount", value: randomFollowing)
        }
        guard let postCount = PostCount(randomPosts) else {
            throw MockFactoryError.invalidValue(field: "postCount", value: randomPosts)
        }

        // MARK: - Dates
        let createdAt = CreatedAt(Date(timeIntervalSinceNow: -Double.random(in: 10_000...500_000)))
        let updatedAt: UpdatedAt? = nil

        return User(
            id: id,
            username: username,
            displayName: displayName,
            avatarURL: avatarURL,
            bio: bio,
            followersCount: followersCount,
            followingCount: followingCount,
            postCount: postCount,
            isVerified: Bool.random(),
            accountStatus: .active,
            createdAt: createdAt,
            updatedAt: updatedAt,
            location: nil,
            websiteURL: nil
        )
    }
}
