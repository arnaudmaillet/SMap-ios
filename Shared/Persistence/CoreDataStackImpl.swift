//
//  CoreDataStack.swift
//  SocialMap
//
//  Created by Arnaud Maillet on 20/10/2025.
//

import CoreData

final class CoreDataStack {
    static let shared = CoreDataStack()

    private init() {}

    lazy var managedObjectModel: NSManagedObjectModel = {
        let model = NSManagedObjectModel()

        // 🔹 Collecte des entités de chaque Feature
        var entities: [NSEntityDescription] = []

        entities.append(PostNamespace.Infrastructure.CoreData.PostCoreDataModel.makeEntityDescription())
        entities.append(UserNamespace.Infrastructure.CoreData.UserCoreDataModel.makeEntityDescription())

        // (ex: plus tard tu pourras ajouter `UserCoreDataModel`, `MediaCoreDataModel`, etc.)

        model.entities = entities
        return model
    }()

    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "App", managedObjectModel: managedObjectModel)

        container.loadPersistentStores { _, error in
            if let error = error {
                fatalError("❌ CoreData failed to load: \(error)")
            }
        }

        return container
    }()

    var context: NSManagedObjectContext {
        persistentContainer.viewContext
    }

    func saveContext() {
        guard context.hasChanges else { return }
        do {
            try context.save()
        } catch {
            print("❌ CoreData save error:", error)
        }
    }
}
