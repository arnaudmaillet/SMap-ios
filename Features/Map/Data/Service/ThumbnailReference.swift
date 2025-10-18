//
//  ThumbnailReference.swift
//  SocialMap
//
//  Created by Arnaud Maillet on 04/10/2025.
//

import Foundation

enum ThumbnailReference: Codable {
    case remote(URL)
    case asset(name: String)
    
    private enum CodingKeys: String, CodingKey {
        case type
        case value
    }
    
    private enum ReferenceType: String, Codable {
        case remote
        case asset
    }
    
    // MARK: - Encodable
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        switch self {
        case .remote(let url):
            try container.encode(ReferenceType.remote, forKey: .type)
            try container.encode(url.absoluteString, forKey: .value)
        case .asset(let name):
            try container.encode(ReferenceType.asset, forKey: .type)
            try container.encode(name, forKey: .value)
        }
    }
    
    // MARK: - Decodable
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let type = try container.decode(ReferenceType.self, forKey: .type)
        switch type {
        case .remote:
            let urlString = try container.decode(String.self, forKey: .value)
            guard let url = URL(string: urlString) else {
                throw DecodingError.dataCorruptedError(forKey: .value, in: container, debugDescription: "Invalid URL string.")
            }
            self = .remote(url)
        case .asset:
            let name = try container.decode(String.self, forKey: .value)
            self = .asset(name: name)
        }
    }
}
