//
//  Caption.swift
//  SocialMap
//
//  Created by Arnaud Maillet on 15/10/2025.
//

import Foundation

extension PostNamespace.Domain.ValueObjects {
    struct Caption: Equatable {
        let value: String

        init(_ value: String) {
            self.value = value.trimmingCharacters(in: .whitespacesAndNewlines)
        }

        var isEmpty: Bool {
            return value.isEmpty
        }
    }
}
