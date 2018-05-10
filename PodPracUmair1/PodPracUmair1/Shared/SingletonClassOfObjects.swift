//
//  Singleton.swift
//  NaseebNetworksInc
//
//  Created by Mian Umair Nadeem on 30/11/2016.
//  Copyright © 2016 Mian Umair Nadeem. All rights reserved.
//

import UIKit

class SingletonClassOfObjects
{
    var blockedUsersArray : NSMutableArray!
    var userObject : UserObject!
    
    public static let SharedInstance = SingletonClassOfObjects()
    
    private init()
    {
        blockedUsersArray = NSMutableArray()
        userObject = UserObject()
    }
    
    
    
}
