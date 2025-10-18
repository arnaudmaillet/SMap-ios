//
//  MediaEntity+Mapper.swift
//  SocialMap
//
//  Created by Arnaud Maillet on 15/10/2025.
//

import CoreData

extension MediaFeature.Database.MediaEntity {
    typealias MediaEntity = MediaFeature.Database.MediaEntity
    typealias Media = MediaFeature.Domain.Entities.Media
    
    static func fromDomain(_ media: Media, in context: NSManagedObjectContext) -> MediaEntity {
        let entity = MediaEntity(context: context)
        entity.id = media.id.value
        entity.url = media.url
        entity.type = media.type.rawValue
        entity.width = Int32(media.dimensions.width)
        entity.height = Int32(media.dimensions.height)
        entity.duration = media.duration ?? 0
        return entity
    }

    func toDomain() -> Media {
        return Media(
            id: .init(self.id!),
            type: .init(rawValue: self.type ?? "image") ?? .image,
            url: self.url!,
            dimensions: .init(width: Int(self.width), height: Int(self.height)),
            duration: self.duration
        )
    }

    static func fetchRequest(for id: UUID) -> NSFetchRequest<MediaEntity> {
        let request = NSFetchRequest<MediaEntity>(entityName: "MediaEntity")
        request.predicate = NSPredicate(format: "id == %@", id as CVarArg)
        request.fetchLimit = 1
        return request
    }
}
