//
//  MediaCoreData.swift
//  SocialMap
//
//  Created by Arnaud Maillet on 15/10/2025.
//

import CoreData

extension MediaFeature.Database {
    final class MediaCoreData {
        let container: NSPersistentContainer
        
        init() {
            let model = MediaEntityModel.makeModel()
            container = NSPersistentContainer(name: "MediaModel", managedObjectModel: model)
            
            container.loadPersistentStores { _, error in
                if let error = error {
                    assertionFailure("Failed to load Core Data stack: \(error.localizedDescription)")
                }
            }
        }
        
        var context: NSManagedObjectContext {
            container.viewContext
        }
    }
}
