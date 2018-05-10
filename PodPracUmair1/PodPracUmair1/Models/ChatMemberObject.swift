//
//  ChatMemberObject.swift
//  EventsApp
//
//  Created by Mian Umair Nadeem on 18/07/2017.
//  Copyright © 2017 Janbaz Ali. All rights reserved.
//

import UIKit

class ChatMemberObject: NSObject {
    
    var idd:Int64!
    var name:String!
    var userId:String!
    var exchange:String!
    var status:String!
    var senderImage:String!
   
    
    init(info:Constants.jsonStandard) {
        
        if info["id"] is NSNumber{
            
            self.idd = info["id"] as! Int64
            
        }
        else if info["id"] is String{
            
            let id = info["id"] as! String
            
            // Converting CityID into NSNUmber
            var id_s_number:Int64 = 0
            if let myInteger = Int64(id) {
                id_s_number = myInteger
            }
            
            self.idd = id_s_number
            
        }
        else
        {
            let idd = ChatDBManager.ChatDBManagerSharedInstance.fetchTheNextIdFor(table: "Members")
            self.idd = idd
        }
       
        
        if info["name"] is String{
            let name = info["name"] as! String
            self.name = name
        }
        if info["userId"] is String{
            let userId = info["userId"] as! String
            self.userId = userId
        }
        
        if info["exchange"] is String{
            let exchange = info["exchange"] as! String
            self.exchange = exchange
        }
        
        if info["senderImage"] is String{
            let senderImage = info["senderImage"] as! String
            self.senderImage = senderImage
        }
        if info["status"] is String{
            let status = info["status"] as! String
            self.status = status
        }
       
        
        
        
    }

}
