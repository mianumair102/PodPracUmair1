//
//  StudentObjectUmair.swift
//  PodPracUmair1
//
//  Created by Mian Umair Nadeem on 03/05/2018.
//  Copyright © 2018 Mian Umair Nadeem. All rights reserved.
//

import UIKit

public class StudentObjectUmair: NSObject {
    var name = ""
    var gender = ""
    public override init() {
        self.name = "No Name"
        self.gender = "No Preference"
    }
    
    public init(name:String , gender:String) {
        self.name = name
        self.gender = gender
    }
    
    public func printMySelf(){
        print("-    -   -   -   -    -")
        print("Name: \(self.name)")
        print("Gender: \(self.gender)")
    }
}
