//
//  ChatThreads+CoreDataProperties.swift
//  
//
//  Created by Janbaz Ali on 5/14/18.
//
//

import Foundation
import CoreData


extension ChatThreads {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<ChatThreads> {
        return NSFetchRequest<ChatThreads>(entityName: "ChatThreads")
    }

    @NSManaged public var exchange: String?
    @NSManaged public var idd: Int64
    @NSManaged public var lastmessage: String?
    @NSManaged public var lastMsgTime: Int64
    @NSManaged public var senderImage: String?
    @NSManaged public var senderName: String?

}
