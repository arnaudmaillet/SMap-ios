//
//  UserCoreDataMapper.swift
//  SocialMap
//
//  Created by Arnaud Maillet on 21/10/2025.
//

import Foundation

extension UserNamespace.Infrastructure.CoreData {
    
    struct UserCoreDataMapper {
        typealias Log = BaseLogger
        
        typealias Entity = UserNamespace.Infrastructure.CoreData.UserEntity
        typealias User = UserNamespace.Domain.Entities.User
        typealias UserID = UserNamespace.Domain.ValueObjects.UserID
        typealias Username = UserNamespace.Domain.ValueObjects.Username
        typealias DisplayName = UserNamespace.Domain.ValueObjects.DisplayName
        typealias AvatarURL = UserNamespace.Domain.ValueObjects.AvatarURL
        typealias Bio = UserNamespace.Domain.ValueObjects.Bio
        typealias FollowersCount = UserNamespace.Domain.ValueObjects.FollowersCount
        typealias FollowingCount = UserNamespace.Domain.ValueObjects.FollowingCount
        typealias PostCount = UserNamespace.Domain.ValueObjects.PostCount
        typealias AccountStatus = UserNamespace.Domain.ValueObjects.AccountStatus
        typealias Location = UserNamespace.Domain.ValueObjects.Location
        typealias WebsiteURL = UserNamespace.Domain.ValueObjects.WebsiteURL
        typealias CreatedAt = UserNamespace.Domain.ValueObjects.CreatedAt
        typealias UpdatedAt = UserNamespace.Domain.ValueObjects.UpdatedAt
        
        // MARK: - Entity → Domain
        static func toDomain(_ entity: Entity) -> User? {
            guard
                let id = UserID(entity.id),
                let username = Username(entity.username)
            else {
                Log.warn("❌ Invalid UserEntity: \(entity)")
                return nil
            }

            return User(
                id: id,
                username: username,
                displayName: DisplayName(entity.displayName),
                avatarURL: AvatarURL(entity.avatarURL),
                bio: Bio(entity.bio),
                followersCount: FollowersCount(Int(entity.followersCount)) ?? .init(0)!,
                followingCount: FollowingCount(Int(entity.followingCount)) ?? .init(0)!,
                postCount: PostCount(Int(entity.postCount)) ?? .init(0)!,
                isVerified: entity.isVerified,
                accountStatus: AccountStatus.from(entity.accountStatus),
                createdAt: CreatedAt(entity.createdAt),
                updatedAt: entity.updatedAt.flatMap { UpdatedAt($0) },
                location: Location(entity.location),
                websiteURL: WebsiteURL(entity.websiteURL)
            )
        }
        
        // MARK: - Domain → Entity
        static func updateEntity(_ entity: Entity, with user: User) {
            entity.id = user.id.value
            entity.username = user.username.value
            entity.displayName = user.displayName?.value ?? ""
            entity.avatarURL = user.avatarURL?.value.absoluteString
            entity.bio = user.bio?.value

            entity.followersCount = Int32(user.followersCount.value)
            entity.followingCount = Int32(user.followingCount.value)
            entity.postCount = Int32(user.postCount.value)
            entity.isVerified = user.isVerified
            entity.accountStatus = user.accountStatus.rawValue

            entity.location = user.location?.value
            entity.websiteURL = user.websiteURL?.value.absoluteString

            entity.createdAt = user.createdAt.value
            entity.updatedAt = user.updatedAt?.value
        }
    }
}
