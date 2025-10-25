//
//  MediaId.swift
//  SocialMap
//
//  Created by Arnaud Maillet on 15/10/2025.
//

import Foundation

extension MediaNamespace.Domain.ValueObjects {
    struct MediaId: Hashable, Equatable {
        let value: UUID
        init(_ value: UUID) { self.value = value }
    }
}
