//
//  Utilities.swift
//  Peawell
//
//  Created by Dennis on 25.05.25.
//

import CoreData

// Utility function to delete an item by its NSManagedObjectID
func trashItem(objectID: NSManagedObjectID) {
    let viewContext = PersistenceController.shared.container.viewContext
    if let object = try? viewContext.existingObject(with: objectID) {
        viewContext.delete(object)
        do {
            try viewContext.save()
        } catch {
            NSLog("Error deleting object: \(error.localizedDescription)")
        }
    }
}
