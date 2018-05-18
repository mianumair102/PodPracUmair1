//
//  Members+CoreDataProperties.swift
//  
//
//  Created by Janbaz Ali on 5/14/18.
//
//

import Foundation
import CoreData


extension Members {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Members> {
        return NSFetchRequest<Members>(entityName: "Members")
    }

    @NSManaged public var exchange: String?
    @NSManaged public var idd: Int64
    @NSManaged public var name: String?
    @NSManaged public var senderImage: String?
    @NSManaged public var status: String?
    @NSManaged public var userId: String?

}
