//
//  MediaCoreDataStack.swift
//  SocialMap
//
//  Created by Arnaud Maillet on 15/10/2025.
//

import CoreData

extension MediaFeature.Database {
    final class MediaCoreDataStack {
        let container: NSPersistentContainer
        
        init() {
            let model = MediaEntityModel.makeModel()
            container = NSPersistentContainer(name: "MediaModel", managedObjectModel: model)
            
            container.loadPersistentStores { _, error in
                if let error = error {
                    fatalError("Core Data stack error: \(error)")
                }
            }
        }
        
        var context: NSManagedObjectContext {
            container.viewContext
        }
    }
}
