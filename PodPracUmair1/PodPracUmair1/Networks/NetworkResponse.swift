//
//  NetworkResponse.swift
//  SeekerSwift1
//
//  Created by Mian Umair Nadeem on 11/01/2017.
//  Copyright © 2017 Mian Umair Nadeem. All rights reserved.
//

import UIKit

class NetworkResponse: NSObject {

    public var status:Bool = false
    public var response:Any = ""
    
    init(status:Bool , response:Any)
    {
        self.status = status
        self.response = response
    }
    
}
