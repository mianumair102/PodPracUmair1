//
//  SendingChatModel.swift
//  EventsApp
//
//  Created by Janbaz Ali on 12/29/17.
//  Copyright © 2017 Janbaz Ali. All rights reserved.
//

import UIKit

class SendingChatModel: NSObject {
    var idd:Int64!
    var message:String!
    var exchange:String!
    
init(info:Constants.jsonStandard)
{
    idd = 0
    message = ""
    exchange = ""
    
    if info["idd"] is NSNumber{
        self.idd = info["id"] as! Int64
        
    }
    else if info["id"] is String
    {
        let id = info["id"] as! String
    //Converting CityID into NSNUmber
        var id_s_number:Int64 = 0
        if let myInteger = Int64(id) {
            id_s_number = myInteger
        
        }
        self.idd = id_s_number
        
}
else
{
//    let idd = ChatDBManager.ChatDBManagerSharedInstance.fetchTheNextIdFor(table: "ChatThreads")            self.idd = idd
//
//    }
//    if info["lastmessage"] is String{
//        let lastmessage = info["lastmessage"] as! String
//        self.lastmessage = lastmessage
//
//    }
//    if info["lastmessagetype"] is String{
//        let lastmessageType = info["lastmessageType"] as! String
//        self.lastmessageType = lastmessageType
//
//    }
//    if info["exchange"] is String{
//        let exchange = info["exchange"] as! String
//        self.exchange = exchange
//
//    }
//    if info["senderImage"] is String{
//        let senderImage = info["senderImage"] as! String
//        self.senderImage = senderImage
//
//    }
//    if info["senderName"] is String{
//        let senderName = info["senderName"] as! String
//        self.senderName = senderName
//
//    }
//
//    }
//    func PrintMySelf(){
//        print("id: \(self.idd)")
//        print("name: \(self.exchange)")
//        print("senderID: \(self.senderId)")
//        print("exchange: \(self.exchange)")
//        print("chattimestamp: \(self.chattimestamp)")
//        print("--------------------------")
    
    }
    }
}
