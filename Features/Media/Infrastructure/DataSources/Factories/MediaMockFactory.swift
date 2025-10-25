//
//  MediaMockFactory.swift
//  SocialMap
//
//  Created by Arnaud Maillet on 22/10/2025.
//
import UIKit

extension MediaNamespace.Infrastructure.Factories {
    struct MediaMockFactory {
        typealias Media = MediaNamespace.Domain.Entities.Media

        typealias MediaID = MediaNamespace.Domain.ValueObjects.MediaID
        typealias MediaType = MediaNamespace.Domain.ValueObjects.MediaType
        typealias MediaURL = MediaNamespace.Domain.ValueObjects.MediaURL
        typealias MediaDimensions = MediaNamespace.Domain.ValueObjects.MediaDimensions
        typealias MediaDuration = MediaNamespace.Domain.ValueObjects.MediaDuration
        typealias MediaFilesize = MediaNamespace.Domain.ValueObjects.MediaFilesize
        typealias MediaFormat = MediaNamespace.Domain.ValueObjects.MediaFormat
        typealias MediaCodec = MediaNamespace.Domain.ValueObjects.MediaCodec
        typealias MediaBlurHash = MediaNamespace.Domain.ValueObjects.MediaBlurHash
        typealias MediaStorageRef = MediaNamespace.Domain.ValueObjects.MediaStorageRef

        static func generate() -> [MediaID: Media] {
            let imageNames = Bundle.main.paths(forResourcesOfType: "png", inDirectory: nil)
                .map { URL(fileURLWithPath: $0).lastPathComponent }
                .filter { $0.hasPrefix("mock_image_") }
                .map { $0.replacingOccurrences(of: ".png", with: "") }

            var dict: [MediaID: Media] = [:]

            for name in imageNames {
                guard let media = try? makeMockMedia(named: name) else {
                    print("⚠️ MediaMockFactory: Failed to create media for asset named \(name)")
                    continue
                }
                dict[media.id] = media
            }

            return dict
        }
    }
}

private extension MediaNamespace.Infrastructure.Factories.MediaMockFactory {
    static func makeMockMedia(named imageName: String) throws -> Media {
        // 1. ID
        guard let id = MediaID(imageName) else {
            throw MockFactoryError.invalidValue(field: "id", value: imageName)
        }

        // 2. Fake URL (juste un nom de ressource interne)
        guard let url = MediaURL("asset://\(imageName)") else {
            throw MockFactoryError.invalidValue(field: "url", value: imageName)
        }

        // 3. Récupération taille de l’image
        guard let image = UIImage(named: imageName) else {
            throw MockFactoryError.invalidValue(field: "image", value: imageName)
        }

        let size = image.size
        guard let dimensions = MediaDimensions(width: Int(size.width), height: Int(size.height)) else {
            throw MockFactoryError.invalidValue(field: "dimensions", value: "\(size.width)x\(size.height)")
        }

        // 4. Construction finale
        return Media(
            id: id,
            type: .image,
            url: url,
            cdnURL: nil,
            thumbnailURL: nil,
            dimensions: dimensions,
            duration: nil,
            filesize: nil,
            isNSFW: false,
            isModerated: false,
            format: nil,
            codec: nil,
            blurHash: nil,
            storageRef: nil
        )
    }
}
