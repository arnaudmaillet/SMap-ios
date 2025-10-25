//
//  PostID.swift
//  SocialMap
//
//  Created by Arnaud Maillet on 15/10/2025.
//

import Foundation

extension PostNamespace.Domain.ValueObjects {
    struct PostId: Equatable, Hashable {
        let value: UUID
        
        init(_ value: UUID) {
            self.value = value
        }
    }
}
