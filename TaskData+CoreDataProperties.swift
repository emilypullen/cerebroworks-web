//
//  TaskData+CoreDataProperties.swift
//  Blackberry
//
//  Created by Emily Pullen on 2025-04-23.
//
//

import Foundation
import CoreData


extension TaskData {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<TaskData> {
        return NSFetchRequest<TaskData>(entityName: "TaskData")
    }

    @NSManaged public var taskId: UUID?
    @NSManaged public var isCompleted: Bool
    @NSManaged public var taskJob: String?
    @NSManaged public var taskName: String?
    @NSManaged public var timestamp: Date?

}

extension TaskData : Identifiable {

}
