//
//  MediaMapper.swift
//  SocialMap
//
//  Created by Arnaud Maillet on 15/10/2025.
//


import Foundation

extension MediaNamespace.Application.Mappers {
    struct MediaMapper {
        typealias MediaDTO = MediaNamespace.Application.DTOs.MediaDTO
        typealias Media = MediaNamespace.Domain.Entities.Media
        typealias MediaId = MediaNamespace.Domain.ValueObjects.MediaId
        typealias MediaType = MediaNamespace.Domain.ValueObjects.MediaType
        typealias MediaDimensions = MediaNamespace.Domain.ValueObjects.MediaDimensions
        typealias MediaEntity = MediaNamespace.Infrastructure.Database.MediaEntity
        

        static func map(_ dto: MediaDTO) -> Media {
            let id = MediaId(UUID(uuidString: dto.id) ?? UUID())
            let type = MediaType(rawValue: dto.type.lowercased()) ?? .image
            let url = URL(string: dto.url) ?? URL(fileURLWithPath: "/invalid-path")
            let dimensions = MediaDimensions(width: dto.width, height: dto.height)

            return .init(
                id: id,
                type: type,
                url: url,
                dimensions: dimensions,
                duration: dto.duration
            )
        }

        static func map(_ domain: Media) -> MediaDTO {
            return .init(
                id: domain.id.value.uuidString,
                type: domain.type.rawValue,
                url: domain.url.absoluteString,
                width: Int(domain.dimensions.width),
                height: Int(domain.dimensions.height),
                duration: domain.duration,
                createdAt: ISO8601DateFormatter().string(from: Date())
            )
        }
        
        static func map(_ entity: MediaEntity) -> Media {
            return .init(
                id: .init(entity.id ?? UUID()),
                type: .init(rawValue: entity.type ?? "image") ?? .image,
                url: URL(string: entity.urlString ?? "") ?? URL(fileURLWithPath: "/invalid-path"),
                dimensions: .init(width: Int(entity.width), height: Int(entity.height)),
                duration: entity.duration?.doubleValue
            )
        }
        
        static func fill(entity: MediaEntity, from media: Media) {
            entity.id = media.id.value
            entity.type = media.type.rawValue
            entity.urlString = media.url.absoluteString
            entity.width = Int32(media.dimensions.width)
            entity.height = Int32(media.dimensions.height)
            entity.duration = media.duration.map(NSNumber.init(value:))
        }
    }
}
