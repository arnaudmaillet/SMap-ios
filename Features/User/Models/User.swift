//
//  User.swift
//  SocialMap
//
//  Created by Arnaud Maillet on 19/04/2025.
//

import Foundation
import CoreLocation

struct User: Identifiable, Equatable {
    var id: String
    var username: String
    var email: String?
    var avatarURL: URL?
    var bio: String?

    var createdAt: Date
    var lastActiveAt: Date?

    var location: CodableCoordinate?
    var following: [String]
    var followers: [String]

    var locale: String?
    var birthdate: Date?
}
