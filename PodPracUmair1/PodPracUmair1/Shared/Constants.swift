//
//  Constants.swift
//  SeekerSwift1
//
//  Created by Mian Umair Nadeem on 11/01/2017.
//  Copyright © 2017 Mian Umair Nadeem. All rights reserved.
//

import Foundation

struct Constants
{
    static let baseUrl:String = "https://www.evento.pk/rest/api/"
    
    static let appKey:String = "c9f0f895fb98ab9159f51fd0297e236d"
    static let appId:String = "8"
    
    typealias jsonStandard = [String : AnyObject]
    typealias dictionaryStandard = [String : String]
    
    static let whichApp = 1
    
    static let kUserId:String = "user_id"
    static let kChatUserId:String = "chatUserId"
    
    
    static let appName:String = "Evento.pk"
    static let isFirstExchange = "isFirstExchange"
    static let isFirstMember = "isFirstMember"
    
    static let myQueue = "myQueue"
    static let systemExchange = "systemExchange"
    
}
