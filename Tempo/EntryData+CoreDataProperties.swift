//
//  EntryData+CoreDataProperties.swift
//  Blackberry
//
//  Created by Emily Pullen on 2025-04-23.
//
//

import Foundation
import CoreData


extension EntryData {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<EntryData> {
        return NSFetchRequest<EntryData>(entityName: "EntryData")
    }

    @NSManaged public var breakDuration: Int16
    @NSManaged public var breakTime: Int16
    @NSManaged public var completedTasks: String?
    @NSManaged public var date: Date?
    @NSManaged public var endTime: Date?
    @NSManaged public var id: UUID?
    @NSManaged public var isCompleted: Bool
    @NSManaged public var job: String?
    @NSManaged public var manualDuration: Int16
    @NSManaged public var name: String?
    @NSManaged public var notes: String?
    @NSManaged public var startTime: Date?
    @NSManaged public var tasks: String?

}

extension EntryData : Identifiable {

}
