//
//  Constants.swift
//  SeekerSwift1
//
//  Created by Mian Umair Nadeem on 11/01/2017.
//  Copyright © 2017 Mian Umair Nadeem. All rights reserved.
//

import Foundation

public struct Constants
{
    public static let baseUrl:String = "https://www.evento.pk/rest/api/"
    
    public static let appKey:String = "c9f0f895fb98ab9159f51fd0297e236d"
    public static let appId:String = "8"
    
    public typealias jsonStandard = [String : AnyObject]
    public typealias dictionaryStandard = [String : String]
    
    public static let whichApp = 1
    
    public static let kUserId:String = "user_id"
    public static let kChatUserId:String = "chatUserId"
    
    
    public static let appName:String = "Evento.pk"
    public static let isFirstExchange = "isFirstExchange"
    public static let isFirstMember = "isFirstMember"
    
    public static let myQueue = "myQueue"
    public static let systemExchange = "systemExchange"
    
}
