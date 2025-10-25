//
//  MockUserProvider.swift
//  SocialMap
//
//  Created by Arnaud Maillet on 20/04/2025.
//

import Foundation

final class MockUserProvider {
    static func generateUsers(count: Int = 10, offline: Bool = false, includePosts: Bool = false) -> [User] {
        let names = [
            ("emma", "🌻 Aime la photo"),
            ("leo", "🚴 Toujours en mouvement"),
            ("lucie", "🧘‍♀️ Zen attitude"),
            ("nathan", "🌍 Explorateur urbain"),
            ("ines", "🎨 Crée tous les jours"),
            ("mika", "📸 Capture l’instant"),
            ("julie", "☕️ Fan de latte art"),
            ("sacha", "🎧 Musique en boucle"),
            ("mathis", "🐶 Adores les chiens"),
            ("claire", "🌊 Mer > Montagne")
        ]
        
        var users: [User] = names.prefix(count).map { item in
            let (username, bio) = item
            let id = UUID()
            let avatarURL: URL? = offline ? nil : URL(string: "https://i.pravatar.cc/150?u=\(id)")
            return User(
                id: id,
                username: username.capitalized,
                email: nil,
                avatarURL: avatarURL,
                bio: bio,
                createdAt: Date(),
                lastActiveAt: Date(),
                location: nil,
                following: [],
                followers: [],
                locale: "fr-FR",
                birthdate: nil,
                posts: [] // 👈 pas de posts par défaut
            )
        }
        
        return users
    }
    
    static func generateUsersWithPosts(userCount: Int = 10, postCount: Int = 50, offline: Bool = false, completion: @escaping ([User]) -> Void) {
        var users = generateUsers(count: userCount, offline: offline)
        var postsReady: [Post.Model] = []
        
        let posts = MockPostProvider.generateMockPosts(count: postCount, offline: offline, videoOnly: true) { post in
            postsReady.append(post)
            if postsReady.count == postCount { // quand toutes les vignettes sont prêtes
                for post in postsReady {
                    if let index = users.indices.randomElement() {
                        users[index].posts.append(post)
                    }
                }
                for i in users.indices {
                    if let randomBanner = users[i].posts.randomElement() {
                        users[i].banner = randomBanner
                    }
                }
                completion(users) // ✅ On renvoie seulement quand tout est prêt
            }
        }
    }
}
