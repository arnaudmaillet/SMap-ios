//
//  UserMockFactory.swift
//  SocialMap
//
//  Created by Arnaud Maillet on 21/10/2025.
//

import Foundation

extension UserNamespace.Infrastructure.DataSources.FakeUserRemoteDataSource {
    static func generateMockUsers(count: Int) -> [UserID: User] {
        typealias User = UserNamespace.Domain.Entities.User
        typealias UserID = UserNamespace.Domain.ValueObjects.UserID
        
        var dict: [UserID: User] = [:]
        for i in 1...count {
            let id = UserID("user-\(i)")!
            let user = User(
                id: id,
                username: .init("user\(i)")!,
                displayName: .init("User \(i)"),
                avatarURL: .init("https://picsum.photos/id/\(i + 30)/100")!,
                bio: .init("Bio de l'utilisateur \(i)"),
                followersCount: .init(Int.random(in: 100...1000))!,
                followingCount: .init(Int.random(in: 10...300))!,
                postCount: .init(Int.random(in: 0...50))!,
                isVerified: Bool.random(),
                accountStatus: .active,
                createdAt: .init(Date(timeIntervalSinceNow: -Double.random(in: 10000...500000))),
                updatedAt: nil,
                location: nil,
                websiteURL: nil
            )
            dict[id] = user
        }
        return dict
    }
}
