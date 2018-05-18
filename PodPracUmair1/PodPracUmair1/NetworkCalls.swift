//
//  NetworkCalls.swift
//  SeekerSwift1
//
//  Created by Mian Umair Nadeem on 11/01/2017.
//  Copyright © 2017 Mian Umair Nadeem. All rights reserved.
//

import UIKit
import Alamofire

class NetworkCalls: NSObject {
    
    private var link:String = ""
    private var notificationName:String = ""
    private var params = [String : String]()
    private var header = [String : String]()
    private var arrayTag = -1
    
    init(link:String ,notificationName:String , params:[String : String] , header:[String : String] , addUSerID:Bool,  arrayTag:Int){
        
        self.link = link
        self.notificationName = notificationName
        self.params = params
        self.header = header
        self.arrayTag = arrayTag
        
        // Adding Generic Header Values
        self.header["appId"] = Constants.appId
        self.header["appKey"] = Constants.appKey
        if DataManager.dataManagerSharedInstance.currentLat != nil {
            self.header["lat"] = DataManager.dataManagerSharedInstance.currentLat
            self.header["lng"] = DataManager.dataManagerSharedInstance.currentLon
        }
        // self.header["authorization"] = "Basic bmFzZWViOm5hc2VlYjMyMQ=="
        if (addUSerID)
        {
            self.header["user_id"] = UserDefaults.standard.value(forKey: Constants.kUserId) as? String
            // self.header["user_id"] = "16"
            //self.header["event_id"] = UserDefaults.standard.value(forKey: Constants.kEventId) as? String
        }
        self.header["chatAppId"] = "1" as String
        self.header["Authorization"] = "Basic bmFzZWViOm5hc2VlYjMyMQ==" as String
        
    }
    
    init(link:String ,notificationName:String , params:[String : String] , header:[String : String] , addUSerID:Bool)
    {
        self.link = link
        self.notificationName = notificationName
        self.params = params
        self.header = header
        
        // Adding Generic Header Values
        self.header["appId"] = Constants.appId
        self.header["appKey"] = Constants.appKey
        if DataManager.dataManagerSharedInstance.currentLat != nil {
            self.header["lat"] = DataManager.dataManagerSharedInstance.currentLat
            self.header["lng"] = DataManager.dataManagerSharedInstance.currentLon
        }
       // self.header["authorization"] = "Basic bmFzZWViOm5hc2VlYjMyMQ=="
        if (addUSerID)
        {
            self.header["user_id"] = UserDefaults.standard.value(forKey: Constants.kUserId) as? String
           // self.header["user_id"] = "16"
           // self.header["event_id"] = UserDefaults.standard.value(forKey: Constants.kEventId) as? String
        }
        self.header["chatAppId"] = "1" as String
        self.header["Authorization"] = "Basic bmFzZWViOm5hc2VlYjMyMQ==" as String
        
        
    }
    
    public func getAPICall1() ->Void
    {
        print("Link : \(link)")
        print("header : \(header)")
        print("params : \(params)")
        
        Alamofire.request(link, method: .get, parameters: params, headers: header).response
            {
                response in
                
                print("Request: \(String(describing: response.request))")
                print("Response: \(String(describing: response.response))")
                print("Error: \(String(describing: response.error))")
                print("Data: \(String(describing: response.data))")
                
                if((response.error) != nil){
                    var finalJSON = Constants.jsonStandard()
                    var responseJSON = Constants.jsonStandard()
                    responseJSON["msg"] = "Something went wrong while fetching data from server." as AnyObject
                    responseJSON["code"] = "00" as AnyObject
                    let errorString = response.error?.localizedDescription
                    if((errorString?.characters.count)! > 0){
                        responseJSON["message"] = errorString! as AnyObject
                    }
                    finalJSON["response"] = responseJSON as AnyObject
                    NotificationCenter.default.post(name: Notification.Name(self.notificationName), object: nil , userInfo: finalJSON)
                    
                }else{
                    
                    let statusCode = (response.response?.statusCode)!
                    print("         ----------------    The Status Code     --------    \(statusCode)")
                    
                    do
                    {
                        //var responseJSON = try JSONSerialization.jsonObject(with: response.data!, options: JSONSerialization.ReadingOptions)
                        let resstr = NSString(data: response.data!, encoding: String.Encoding.utf8.rawValue)
                        print("Bismillah, Simple Server String :: \(String(describing: resstr))")
                        let responseJSON = try JSONSerialization.jsonObject(with: response.data!, options: .mutableContainers) as! Constants.jsonStandard
                        print("The Original Data is :: \(responseJSON)")
                        let response = responseJSON["response"] as! Constants.jsonStandard
                        let code = response["code"] as! String
                        if code == "51"
                        {
                            UserDefaults.standard.set("", forKey: Constants.kUserId)
                            UserDefaults.standard.set("", forKey: Constants.kChatUserId)
                            ChatDBManager.ChatDBManagerSharedInstance.closeConnection()
                            ChatDBManager.ChatDBManagerSharedInstance.DeleteEverThing()
                            //let appDelegate = UIApplication.shared.delegate as! AppDelegate
                           // appDelegate.userSessionExpired()
                        }
                        else
                        {
                             NotificationCenter.default.post(name: Notification.Name(self.notificationName), object: nil , userInfo: responseJSON)
                        }
                       
                    }
                    catch
                    {
                        print(error)
                    }
                    
                }
                
                
        }
        
        
        
    }
    
   
    public func postAPICall() ->Void
    {
        print("Link : \(link)")
        print("header : \(header)")
        print("params : \(params)")
        let request = Alamofire.request(link, method: .post, parameters: params, encoding: JSONEncoding.default, headers: header)
         //   let validation = request.validate()
        print("\(params)")
            request.response
            {
                response in
                
        //       print("Request: \(response.response!)")
//                print("Response: \(response.response)")
//                print("Error: \(response.error)")
//                print("Data: \(response.data)")
                if response.error == nil
                {
                    let statusCode = (response.response?.statusCode)!
                    print("         ----------------    The Status Code     --------    \(statusCode)")
                    
                    do
                    {
                        var responseJSON = try JSONSerialization.jsonObject(with: response.data!, options: .mutableContainers) as! Constants.jsonStandard
                        print("The Original Data is :: \(responseJSON)")
                        var response = responseJSON["response"] as! Constants.jsonStandard
                        if(self.arrayTag != -1){
                            responseJSON["tag"] = self.arrayTag as AnyObject
                        }
                        let code = response["code"] as! String
                        if code == "51"
                        {
                            UserDefaults.standard.set("", forKey: Constants.kUserId)
                            UserDefaults.standard.set("", forKey: Constants.kChatUserId)
                            ChatDBManager.ChatDBManagerSharedInstance.closeConnection()
                            ChatDBManager.ChatDBManagerSharedInstance.DeleteEverThing()
                            //let appDelegate = UIApplication.shared.delegate as! AppDelegate
                           // appDelegate.userSessionExpired()
                        }
                        else
                        {
                            NotificationCenter.default.post(name: Notification.Name(self.notificationName), object: nil , userInfo: responseJSON)
                        }
                        
                    }
                    catch
                    {
                        print(error)
                        
                        let code = "00"
                        let message = "Something went wrong with server, please check your internet connection and try again."
                        var response = Constants.jsonStandard()
                        response["code"] = code as AnyObject?
                        response["message"] = message as AnyObject?
                        response["msg"] = message as AnyObject?
                        
                        var data = Constants.jsonStandard()
                        data["response"] = response as AnyObject?
                        NotificationCenter.default.post(name: Notification.Name(self.notificationName), object: nil , userInfo: data)
                    }
                }
                else
                {
                    let code = "00"
                    let message = "Something went wrong, please check your internet connection and try again."
                    var response = Constants.jsonStandard()
                    response["code"] = code as AnyObject?
                    response["message"] = message as AnyObject?
                    response["msg"] = message as AnyObject?
                    
                    var data = Constants.jsonStandard()
                    data["response"] = response as AnyObject?
                    NotificationCenter.default.post(name: Notification.Name(self.notificationName), object: nil , userInfo: data)
                    
                }
                
        }
        
    }

}
