//
//  ChatSDK.swift
//  ChattingApp
//
//  Created by Janbaz Ali on 4/16/18.
//  Copyright © 2018 Janbaz Ali. All rights reserved.
//

import Foundation
import UIKit

public class ChatSDK{
    
    public init (userId : String? , reciepientId : String?)
    {
        self.setChatData(userId: userId, recipientId: reciepientId, exchange: "", recipientName: "", recipientImage: "")
    }
    
    public init (userId : String? , reciepientId : String? , exchange : String )
    {
        self.setChatData(userId: userId, recipientId: reciepientId, exchange: exchange, recipientName: "", recipientImage: "")
    }
    
    public init (userId : String? , reciepientId : String? , exchange : String, reciientName : String? , recipientImageUrlString : String? )
    {
        self.setChatData(userId: userId, recipientId: reciepientId, exchange: exchange, recipientName: reciientName, recipientImage: recipientImageUrlString)
    }
    
   
    
    func setChatData(userId: String? , recipientId : String?, exchange :String? , recipientName : String?, recipientImage : String?) -> Void {
        
        ChatDBManager.ChatDBManagerSharedInstance.myId = userId
        ChatDBManager.ChatDBManagerSharedInstance.exchange = exchange
        ChatDBManager.ChatDBManagerSharedInstance.recipientId = recipientId
        ChatDBManager.ChatDBManagerSharedInstance.recipientName = recipientName
        ChatDBManager.ChatDBManagerSharedInstance.recipientImage = recipientImage
    }
    
}
