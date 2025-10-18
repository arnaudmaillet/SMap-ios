//
//  MediaEntityModel.swift
//  SocialMap
//
//  Created by Arnaud Maillet on 15/10/2025.
//

import CoreData

enum MediaEntityModel {
    static func makeModel() -> NSManagedObjectModel {
        typealias MediaEntity = MediaFeature.Database.MediaEntity
        
        let model = NSManagedObjectModel()
        
        // Define entity
        let mediaEntity = NSEntityDescription()
        mediaEntity.name = "MediaEntity"
        mediaEntity.managedObjectClassName = NSStringFromClass(MediaEntity.self)
        
        // Attributes
        let id = NSAttributeDescription()
        id.name = "id"
        id.attributeType = .UUIDAttributeType
        id.isOptional = false

        let url = NSAttributeDescription()
        url.name = "url"
        url.attributeType = .URIAttributeType
        url.isOptional = false

        let type = NSAttributeDescription()
        type.name = "type"
        type.attributeType = .stringAttributeType
        type.isOptional = false

        let width = NSAttributeDescription()
        width.name = "width"
        width.attributeType = .integer32AttributeType
        width.isOptional = false

        let height = NSAttributeDescription()
        height.name = "height"
        height.attributeType = .integer32AttributeType
        height.isOptional = false

        let duration = NSAttributeDescription()
        duration.name = "duration"
        duration.attributeType = .doubleAttributeType
        duration.isOptional = true

        mediaEntity.properties = [id, url, type, width, height, duration]
        model.entities = [mediaEntity]

        return model
    }
}
