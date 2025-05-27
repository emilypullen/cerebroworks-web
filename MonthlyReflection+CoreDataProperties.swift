//
//  MonthlyReflection+CoreDataProperties.swift
//  Blackberry
//
//  Created by Emily Pullen on 2025-05-03.
//
//

import Foundation
import CoreData


extension MonthlyReflection {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<MonthlyReflection> {
        return NSFetchRequest<MonthlyReflection>(entityName: "MonthlyReflection")
    }

    @NSManaged public var refID: UUID?
    @NSManaged public var refDate: Date?
    @NSManaged public var refPrompt: String?
    @NSManaged public var refResponse: String?
    @NSManaged public var refMood: String?

}

extension MonthlyReflection : Identifiable {

}
