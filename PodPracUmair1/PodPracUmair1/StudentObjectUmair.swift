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
    public  init(userId : String?, myQueue : String?, recipientId : String?, exchange : String?)
    {
        super.init()
        
        UserDefaults.standard.set("users", forKey: Constants.systemExchange)
        UserDefaults.standard.set(userId!, forKey: Constants.kChatUserId)
        UserDefaults.standard.set(myQueue!, forKey: Constants.myQueue)
        
        ChatDBManager.ChatDBManagerSharedInstance.myQueue = myQueue!
        ChatDBManager.ChatDBManagerSharedInstance.recipientId = recipientId!
        ChatDBManager.ChatDBManagerSharedInstance.subscribeToRabbitMQServer(exchangeName: "users", queueName: myQueue!)
        ChatDBManager.ChatDBManagerSharedInstance.exchange = exchange!
        
        let obj = ChatSdkStart()
        obj.printSomething()
        FrameWorkStarter.startRozeeFrameWork.setColorsOfApplication(applicationColors: [1:"#FFFFFF" , 2:"#FFFFFF" , 3:"#B4B4B4" , 4:"#F5F5F5" , 5:"#555555" , 6:"#dd594a" , 7:"#46b448"])
        ChatDBManager.ChatDBManagerSharedInstance.loadPersistantStorage()
    }
    public func startChat(refViewController : UIViewController?)
    {
        let bundle = Bundle(for: StudentObjectUmair.self)
        //let storyboard = UIStoryboard(name: "FrameworkMain", bundle: bundle)
        let storyboard = UIStoryboard(name: "Chatting", bundle: bundle)
        let vc  = storyboard.instantiateViewController(withIdentifier: "ChattingViewController") as! ChattingViewController
        vc.recipientId = ChatDBManager.ChatDBManagerSharedInstance.recipientId
        vc.exchangename = ChatDBManager.ChatDBManagerSharedInstance.exchange
        refViewController?.navigationController?.pushViewController(vc, animated: true)
        
    }
}

