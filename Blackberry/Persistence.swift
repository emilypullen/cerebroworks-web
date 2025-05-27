//
//  Persistence.swift
//  Blackberry
//
//  Created by Emily Pullen on 2025-04-20.
//

import CoreData

struct PersistenceController {
    static let shared = PersistenceController()

    // MARK: - Preview Instance for SwiftUI Previews

    @MainActor
    static let preview: PersistenceController = {
        let controller = PersistenceController(inMemory: true)
        let viewContext = controller.container.viewContext
        
        for _ in 0..<10 {
            let newItem = Item(context: viewContext)
            newItem.timestamp = Date()
        }
        
        do {
            try viewContext.save()
        } catch {
            let nsError = error as NSError
            fatalError("❌ Unresolved CoreData error (preview): \(nsError), \(nsError.userInfo)")
        }
        
        return controller
    }()

    // MARK: - Persistent Container

    let container: NSPersistentContainer

    init(inMemory: Bool = false) {
        container = NSPersistentContainer(name: "BlackberryModel")

        if inMemory {
            container.persistentStoreDescriptions.first?.url = URL(fileURLWithPath: "/dev/null")
        }

        container.loadPersistentStores { storeDescription, error in
            if let error = error as NSError? {
                fatalError("❌ Unresolved CoreData error: \(error), \(error.userInfo)")
            }
        }

        container.viewContext.automaticallyMergesChangesFromParent = true
    }
}

