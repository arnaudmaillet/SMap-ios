//
//  MockUserProvider.swift
//  SocialMap
//
//  Created by Arnaud Maillet on 20/04/2025.
//

import Foundation

final class MockUserProvider {
    
    static func generateUsers(count: Int = 10) -> [User] {
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
        
        return names.prefix(count).enumerated().map { (index, item) in
            let (username, bio) = item
            let id = UUID().uuidString
            let avatarURL = URL(string: "https://i.pravatar.cc/150?u=\(id)")!
            
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
                birthdate: nil
            )
        }
    }
}
