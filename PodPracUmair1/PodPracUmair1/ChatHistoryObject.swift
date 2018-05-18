//
//  ChatHistoryObject.swift
//  EventsApp
//
//  Created by Janbaz Ali on 7/18/17.
//  Copyright © 2017 Janbaz Ali. All rights reserved.
//

import UIKit

class ChatHistoryObject: NSObject
{
    var idd:Int64!
    var originalId:Int64!
    var message:String!
    var image64:String!
    var exchange:String!
    var recieverId:String!
    var senderId:String!
    var status:String!
    var type:String!
    var chattimestamp:NSNumber!
    
    // 1 => Save in DB (Insert)
    // 2 => Update in DB
    var dbAction:String!
    
    init(info:Constants.jsonStandard)
    {
        self.type = ""
        self.image64 = ""
        self.message = ""
    
        if info["message"] is String{
            let message = info["message"] as! String
            self.message = message
        }
        if info["image64"] is String{
            let image64 = info["image64"] as! String
            self.image64 = image64
        }
        if info["type"] is String{
            let type = info["type"] as! String
            self.type = type
        }
        if info["serverID"] is String{
            let senderID = info["serverID"] as! String
            self.senderId = senderID
        }
        if info["exchange"] is String{
            let exchange = info["exchange"] as! String
            self.exchange = exchange
        }
        if info["receiver_id"] is String{
            let recieverId = info["receiver_id"] as! String
            self.recieverId = recieverId
        }
        if info["sender_id"] is String{
            let senderId = info["sender_id"] as! String
            self.senderId = senderId
        }
        if info["status"] is String{
            let status = info["status"] as! String
            self.status = status
        }
        if info["image"] is UIImage{
            let image  = info["image"] as! UIImage
           /// self.image = image
        }
        if info["timestamp"] is NSNumber{
            
            self.chattimestamp = info["timestamp"] as! NSNumber
            
        }else if info["timestamp"] is String{
            
            let timestamp = info["timestamp"] as! String
            
            // Converting CityID into NSNUmber
            var id_s_number:NSNumber = 0
            if let myInteger = Int(timestamp) {
                id_s_number = NSNumber(value:myInteger)
            }
            
            self.chattimestamp = id_s_number
            
        }
        
        if info["originalId"] is NSNumber{
            
            self.originalId = info["originalId"] as! Int64
            
        }
        else if info["originalId"] is String
        {
            
            let originalId = info["originalId"] as! String?
            
            if originalId!.isEmpty {
                let originalId = ChatDBManager.ChatDBManagerSharedInstance.fetchTheNextIdFor(table: "ChatHistory")
                self.originalId = originalId
            }
            else
            {
                var id_s_number:Int64  = 0
                if let myInteger = Int64(originalId!) {
                    id_s_number = Int64(myInteger)
                }
                
                self.originalId = id_s_number
            }
            
            
        }
        else
        {
            
          //  self.originalId = info["originalId"] as! Int64
        }
        
       // if self.senderId == UserDefaults.standard.value(forKey: Constants.kChatUserId) as? String {
            if info["id"] is NSNumber{
                
                self.idd = info["id"] as! Int64
                
            }
            else if info["id"] is String
            {
                
                let id = info["id"] as! String?
                
                if id!.isEmpty {
                    let idd = ChatDBManager.ChatDBManagerSharedInstance.fetchTheNextIdFor(table: "ChatHistory")
                    self.idd = idd
                }
                else
                {
                    var id_s_number:Int64  = 0
                    if let myInteger = Int64(id!) {
                        id_s_number = Int64(myInteger)
                    }
                    
                    self.idd = id_s_number
                }
                
                
            }
            else
            {
                let idd = ChatDBManager.ChatDBManagerSharedInstance.fetchTheNextIdFor(table: "ChatHistory")
                self.idd = idd
            }
//        }
//        else
//        {
//            let idd = ChatDBManager.ChatDBManagerSharedInstance.fetchTheNextIdFor(table: "ChatHistory")
//            self.idd = idd
//        }
    
        
    }
    init(data:ChatHistory)
    {
         idd = data.idd
         originalId = data.originalId
         message = data.message
         image64 = data.image64
         exchange = data.exchange
         recieverId = data.recieverId
         senderId = data.senderId
         status = data.status
         type = data.type
         chattimestamp = data.timestamp as NSNumber
    }
    func PrintMySelf(){
        print("id: \(self.idd)")
        print("message: \(self.message)")
        print("type: \(self.type)")
        print("senderID: \(self.senderId)")
        print("exchange: \(self.exchange)")
        print("chattimestamp: \(self.chattimestamp)")
        
        print("originalId: \(self.originalId)")
        print("image64: \(self.image64)")
        print("recieverId: \(self.recieverId)")
        print("status: \(self.status)")
       // print("image: \(self.image)")
        print("--------------------------")
        
        
    }
}
