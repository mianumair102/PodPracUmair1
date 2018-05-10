//
//  Singleton.swift
//  NaseebNetworksInc
//
//  Created by Mian Umair Nadeem on 30/11/2016.
//  Copyright © 2016 Mian Umair Nadeem. All rights reserved.
//
import UIKit
import RMQClient

import Foundation
import SystemConfiguration
class DataManager
{
    
    public static let dataManagerSharedInstance = DataManager()
//    var conn:RMQConnection!
//    let exchangeName = "users"
    private init()
    {
        
    }
    
    var pushType:String = ""
    var pushData:Constants.jsonStandard = Constants.jsonStandard();
    var gotToPollsFrom = 0
    var rozee_app_url : String!
    var currentLat : String!
    var currentLon : String!
    var isCheckedIn : Bool = false
    
    var supportCellNumber = ""
    
//    let myUserId = "16"
//    let scduserId = "6"
    
    
    func isInternetAvailable() -> Bool
    {
        var zeroAddress = sockaddr_in()
        zeroAddress.sin_len = UInt8(MemoryLayout.size(ofValue: zeroAddress))
        zeroAddress.sin_family = sa_family_t(AF_INET)
        
        let defaultRouteReachability = withUnsafePointer(to: &zeroAddress) {
            $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {zeroSockAddress in
                SCNetworkReachabilityCreateWithAddress(nil, zeroSockAddress)
            }
        }
        
        var flags = SCNetworkReachabilityFlags()
        if !SCNetworkReachabilityGetFlags(defaultRouteReachability!, &flags) {
            return false
        }
        let isReachable = flags.contains(.reachable)
        let needsConnection = flags.contains(.connectionRequired)
        return (isReachable && !needsConnection)
    }
    
    func isValidEmail(testStr:String) -> Bool {
        // print("validate calendar: \(testStr)")
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: testStr)
    }
    
    func roundedCornerImage(image : UIImageView, radius : CGFloat) -> Void {
        image.layer.cornerRadius = CGFloat(radius)
        image.clipsToBounds = true
    }
    
    func roundedCornerSwitch(image : UISwitch, radius : CGFloat) -> Void {
        image.layer.cornerRadius = CGFloat(radius)
        image.clipsToBounds = true
    }
    func roundedCornerlabel(label : UILabel, radius : CGFloat) -> Void {
        label.layer.cornerRadius = CGFloat(radius)
        label.clipsToBounds = true
    }
    
    public  func PutSkillDbFiles() -> Void
    {
        print("Bismillah, The Path is :: \(FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first)")
        
        // creating source paths
        let bundlePath = Bundle.main.path(forResource: "RozeeEmployerLoadData", ofType: ".sqlite")
        let bundlePath2 = Bundle.main.path(forResource: "RozeeEmployerLoadData", ofType: ".sqlite-shm")
        let bundlePath3 = Bundle.main.path(forResource: "RozeeEmployerLoadData", ofType: ".sqlite-wal")
        
        let destPath = NSSearchPathForDirectoriesInDomains(.applicationSupportDirectory, .userDomainMask, true).first!
        
        let fullDestPath = NSURL(fileURLWithPath: destPath).appendingPathComponent("RozeeEmployerLoadData.sqlite")
        let fullDestPathString = fullDestPath?.path
        
        let fullDestPath2 = NSURL(fileURLWithPath: destPath).appendingPathComponent("RozeeEmployerLoadData.sqlite-shm")
        let fullDestPathString2 = fullDestPath2?.path
        
        let fullDestPath3 = NSURL(fileURLWithPath: destPath).appendingPathComponent("RozeeEmployerLoadData.sqlite-wal")
        let fullDestPathString3 = fullDestPath3?.path
        
        let fileManager = FileManager.default
        
        // check if already exists and delete previous one
        if (fileManager.fileExists(atPath: fullDestPathString!)) {
            do{
                try fileManager.removeItem(atPath : fullDestPathString!)
                print("success")
            }catch{
                print("\n")
                print(error)
            }
        }
        // copying new DB file
        do{
            try fileManager.copyItem(atPath: bundlePath!, toPath: fullDestPathString!)
            print("success")
        }catch{
            print("\n")
            print(error)
        }
        
        // check if already exists and delete previous one
        
        if (fileManager.fileExists(atPath: fullDestPathString2!)) {
            do{
                try fileManager.removeItem(atPath : fullDestPathString2!)
                print("success")
            }catch{
                print("\n")
                print(error)
            }
        }
        // copying new DB file
        do{
            try fileManager.copyItem(atPath: bundlePath2!, toPath: fullDestPathString2!)
            print("success")
        }catch{
            print("\n")
            print(error)
        }
        
        // check if already exists and delete previous one
        
        if (fileManager.fileExists(atPath: fullDestPathString3!)) {
            do{
                try fileManager.removeItem(atPath : fullDestPathString3!)
                print("success")
            }catch{
                print("\n")
                print(error)
            }
        }
        // copying new DB file
        do{
            try fileManager.copyItem(atPath: bundlePath3!, toPath: fullDestPathString3!)
            print("success")
        }catch{
            print("\n")
            print(error)
        }
        
    }
    
    public  func openRozeeApplication() -> Void
    {
       // let urlStr = self.rozee_app_url
        
        let urlStr = "https://itunes.apple.com/pk/app/rozee/id990916598?mt=8"
        if let url = URL(string: urlStr) {
            if #available(iOS 10, *) {
                UIApplication.shared.open(url, options: [:],
                                          completionHandler: {
                                            (success) in
                                            print("Open \(url): \(success)")
                })
            } else {
                let success = UIApplication.shared.openURL(url)
                print("Open \(url): \(success)")
            }
        }
    }
    
    public func addBlockedUsersToArray(array : NSArray)
    {
        let tempArr = NSMutableArray()
        for i in 0..<array.count
        {
            let dict = array[i] as! Constants.jsonStandard
            if dict["is_blocked"] as! String == "Y"
            {
                tempArr.add(dict)
            }
        }
        SingletonClassOfObjects.SharedInstance.blockedUsersArray = tempArr
    }
}

