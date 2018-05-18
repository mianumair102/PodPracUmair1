//
//  ChatHistory+CoreDataProperties.swift
//  
//
//  Created by Janbaz Ali on 5/14/18.
//
//

import Foundation
import CoreData


extension ChatHistory {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<ChatHistory> {
        return NSFetchRequest<ChatHistory>(entityName: "ChatHistory")
    }

    @NSManaged public var exchange: String?
    @NSManaged public var idd: Int64
    @NSManaged public var image64: String?
    @NSManaged public var message: String?
    @NSManaged public var originalId: Int64
    @NSManaged public var recieverId: String?
    @NSManaged public var senderId: String?
    @NSManaged public var status: String?
    @NSManaged public var timestamp: Int64
    @NSManaged public var type: String?

}
