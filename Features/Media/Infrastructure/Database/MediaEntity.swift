//
//  MediaEntity.swift
//  SocialMap
//
//  Created by Arnaud Maillet on 15/10/2025.
//

import CoreData
import Foundation

extension MediaFeature.Database {
    @objc(MediaEntity)
    final class MediaEntity: NSManagedObject {
        @NSManaged var id: UUID?
        @NSManaged var url: URL?
        @NSManaged var type: String?
        @NSManaged var width: Int32
        @NSManaged var height: Int32
        @NSManaged var duration: Double
    }
}
