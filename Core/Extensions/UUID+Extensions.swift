//
//  UUID+Extensions.swift
//  SocialMap
//
//  Created by Arnaud Maillet on 07/10/2025.
//

import Foundation
import CryptoKit

extension UUID {
    static func namespaced(from base: UUID, namespace: String) -> UUID {
        let baseString = "\(namespace)_\(base.uuidString)"
        let hash = SHA256.hash(data: Data(baseString.utf8))
        let bytes = Array(hash)

        // Utiliser les 16 premiers octets pour créer un UUID valide
        return UUID(uuid: (
            bytes[0], bytes[1], bytes[2], bytes[3],
            bytes[4], bytes[5], bytes[6], bytes[7],
            bytes[8], bytes[9], bytes[10], bytes[11],
            bytes[12], bytes[13], bytes[14], bytes[15]
        ))
    }
}
