//
//  Singleton.swift
//  NaseebNetworksInc
//
//  Created by Mian Umair Nadeem on 30/11/2016.
//  Copyright © 2016 Mian Umair Nadeem. All rights reserved.
//

import CoreData
import INSPersistentContainer
import RMQClient

class ChatDBManager: NSObject, RMQConnectionDelegate
{
    public static let ChatDBManagerSharedInstance = ChatDBManager()
    
    var isOurQueueInProcess = false
    var isProccessing = false
    var arrayChatQueue = [ChatHistoryObject]()
    
    typealias NSPersistentContainer         = INSPersistentContainer
    typealias NSPersistentStoreDescription  = INSPersistentStoreDescription
    let contextNew =  NSPersistentContainer(name: "ChatDBModel")
    public var conn = RMQConnection()
    
    var lastSyncTime = Date()
    var arrayForImageMsgs = Array<ChatHistoryObject>()
    static var chatIdForUpdate : Int64!
    var fetchedResultsController: NSFetchedResultsController<ChatHistory>!
    
    public var myId : String!
    public var myQueue : String!
    public var systemExchange : String!
    public var exchange : String!
    public var recipientId : String!
    public var recipientName : String!
    public var recipientImage : String!
    

    
    
    
    private override init()
    {
      //  contextNew = self.persistentContainer.viewContext
       // self.setUpFetchRequestCoreData()
        
    }
    
    
    public var isPresistanceOfChatLoaded = false
    
    // MARK: - CoreData
    
//    lazy var persistentContainer: NSPersistentContainer = {
//
//        let container = NSPersistentContainer(name: "ChatDBModel")
//        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
//            if let error = error as NSError? {
//                fatalError("Unresolved error \(error), \(error.userInfo)")
//            }
//        })
//        return container
//    }()
    
   public func loadPersistantStorage() -> Void {
        //contextNew.viewContext.parent = privateMOC
        ChatDBManager.ChatDBManagerSharedInstance.contextNew.loadPersistentStores { (persistentStoreDescription, error) in
            if let error = error {
                print("Unable to Load Persistent Store")
                print("\(error), \(error.localizedDescription)")
                ChatDBManager.ChatDBManagerSharedInstance.isPresistanceOfChatLoaded = false
                
            } else
            {
                // self.setupView()
                ChatDBManager.ChatDBManagerSharedInstance.isPresistanceOfChatLoaded = true
//                do {
//                    try self.fetchedResultsController.performFetch()
//                } catch {
//                    let fetchError = error as NSError
//                    print("Unable to Perform Fetch Request")
//                    print("\(fetchError), \(fetchError.localizedDescription)")
//                }
            }
            
        }
    
    }
    
    func saveContext () {
        let context = contextNew.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
    func isStringEmpty(string:String) -> Bool
    {
        var returnValue = false
        if string.isEmpty
        {
            returnValue = true
        }
        
        return returnValue
    }
    
    //MARK:- My Functions
    
    public func sendDeliveryStatus(chatObj : ChatHistoryObject) -> Void
   {
        var msg = ""
        var dic = Constants.jsonStandard()
        
    
        dic["type"] = "chat" as AnyObject
        dic["subtype"] = "message_status" as AnyObject
        dic["application_name"] = "Evento" as AnyObject
        dic["exchange"] = chatObj.exchange as AnyObject
        dic["senderNumber"] = "988347928429" as AnyObject
        dic["queue"] = self.myQueue as AnyObject
        var chat = Constants.jsonStandard()
        chat["status"] = chatObj.status as AnyObject
        if chatObj.senderId != UserDefaults.standard.value(forKey: Constants.kChatUserId) as? String
        {
            if chatObj.status == "sending" {
                chat["status"] = "delivered" as AnyObject
            }
            if chatObj.status == "failed" {
                chat["status"] = "delivered" as AnyObject
            }
        
            chat["id"] = chatObj.idd as AnyObject
            chat["exchange"] = chatObj.exchange as AnyObject
            chat["timestamp"] = chatObj.chattimestamp as AnyObject
            chat["message"] = chatObj.message as AnyObject
            chat["receiver_id"] = chatObj.recieverId as AnyObject
            chat["sender_id"] = chatObj.senderId as AnyObject
            chat["originalId"] = chatObj.originalId as AnyObject
            chat["type"] = chatObj.type as AnyObject
           // chat["image64"] = chatObj.image64 as AnyObject
            chat["image64"] = "" as AnyObject
            
            dic["chatHistory"] = chat as AnyObject
           // NotificationCenter.default.post(name: Notification.Name("chatnotification"), object: nil , userInfo: chat)
            
            do {
                let data = try JSONSerialization.data(withJSONObject:dic, options:[])
                msg = String(data: data, encoding: String.Encoding.utf8)!
                // print(msg)
                
            } catch {
                print("JSON serialization failed:  \(error)")
            }
            
            
            
            ChatDBManager.ChatDBManagerSharedInstance.sendMessageToExchange(exchangeName: chatObj.exchange, queue: myQueue!, message: msg)
        }
    }
    public func sendOnlineStatus(statusObj : Constants.jsonStandard!) -> Void
    {
        var msg = ""
        var dic = Constants.jsonStandard()
        let exchange = statusObj["exchange"] as! String
        
        dic["type"] = "chat" as AnyObject
        dic["subtype"] = "user_status" as AnyObject
        dic["exchange"] = statusObj["exchange"] as AnyObject
        dic["userId"] = UserDefaults.standard.value(forKey: Constants.kChatUserId) as AnyObject
        var chat = Constants.jsonStandard()
        chat["status"] = "online" as AnyObject
        if statusObj["exchange"] as? String != UserDefaults.standard.value(forKey: Constants.kChatUserId) as? String
        {
          
            do {
                let data = try JSONSerialization.data(withJSONObject:dic, options:[])
                msg = String(data: data, encoding: String.Encoding.utf8)!
                // print(msg)
                
            } catch {
                print("JSON serialization failed:  \(error)")
            }
            
            ChatDBManager.ChatDBManagerSharedInstance.sendMessageToExchange(exchangeName: exchange, queue: myQueue!, message: msg)
        }
    }
    func syncUserLastSeen(userId : String!) -> Void
    {
        var dict = Constants.jsonStandard()
        let date = Date()
        let timeInterval = date.timeIntervalSince1970
        let timeInLongInt : Int = Int(timeInterval)
        let strTimeStamp = String(timeInLongInt)
        dict["last_seen_time"] = strTimeStamp as AnyObject
        dict["member_id"] =  userId as AnyObject
        
        var insertionArray = [[String : AnyObject]]()
        insertionArray.append(dict)
        
        if userId != UserDefaults.standard.value(forKey: Constants.kChatUserId)as? String {
            let cur = Date()
            let elapsed = cur.timeIntervalSince(lastSyncTime)
            let duration = Int(elapsed)
            if duration > 60 {
                lastSyncTime = Date()
                self.updateLastSeenStatusStatus(data: insertionArray)
            }
        }
    }
    
    func KeepReadingOurQueue(){
        
        if(self.arrayChatQueue.count > 0)
        {
            if !self.isProccessing
            {
                self.isOurQueueInProcess = true
                self.isProccessing = true
                let cObj = self.arrayChatQueue[0]
                if cObj.dbAction == "2"{
                    self.updateChatStatusNew(status: cObj.status, chatId: cObj.originalId)
                }else if cObj.dbAction == "1"{
                    // Insert Action
                    self.saveChatMessagesInDataBaseNew(cData: cObj)
                }
            }
            else
            {
                self.KeepReadingOurQueue()
            }
            
        }
        else
        {
            self.isOurQueueInProcess = false
        }
    }
    
    // MARK: Database Insertion
    public func saveThreadsInDataBase(data:[ChatThreadModel]) ->Void
    {
        for i in 0 ..< data.count
        {
            let thread :ChatThreadModel  = data[i] as ChatThreadModel
            var aaray = NSArray()
            if !UserDefaults.standard.bool(forKey: Constants.isFirstExchange) {
                 UserDefaults.standard.set(false, forKey: Constants.isFirstExchange)
                aaray = self.fetchThreadWithName(name: thread.exchange!) as NSArray
            }
            if aaray.count == 0
            {
                let cData = data[i]
                let context = self.contextNew.viewContext
                let newInsertion = NSEntityDescription.insertNewObject(forEntityName: "ChatThreads", into: context)
                newInsertion.setValue(cData.idd, forKey: "idd")
                newInsertion.setValue(cData.senderImage, forKey: "senderImage")
               // newInsertion.setValue(cData.isOnline, forKey: "isOnline")
                newInsertion.setValue(cData.lastmessage, forKey: "lastmessage")
                newInsertion.setValue(cData.exchange, forKey: "exchange")
                newInsertion.setValue(cData.senderName, forKey: "senderName")
            
                do {
                    try context.save()
                   // print("Chat Thread Saved Sucessfully")
                } catch {
                   // print("Error in Saving Chat Thread Saved")
                }
            }
            else
            {
               // self.updateThreadWithName(name: thread.exchange, lastMessage: thread.lastmessage)
            }
        }
    }
    
    public func saveMembersInDataBase(data:[ChatMemberObject]) ->Void{
        
        for i in 0 ..< data.count
        {
            let member :ChatMemberObject  = data[i] as ChatMemberObject
            var aaray = NSArray()
            if !UserDefaults.standard.bool(forKey: Constants.isFirstMember) {
                UserDefaults.standard.set(false, forKey: Constants.isFirstMember)
               aaray = self.fetchMemberWithExchange(exchange: member.exchange, userId: member.userId) as NSArray
            }
            
            //let aaray = NSArray()
            if aaray.count == 0
            {
                let cData = data[i]
                let context = self.contextNew.viewContext
                let newInsertion = NSEntityDescription.insertNewObject(forEntityName: "Members", into: context)//senderImage
                newInsertion.setValue(cData.idd, forKey: "idd")
                newInsertion.setValue(cData.name, forKey: "name")
                newInsertion.setValue(cData.userId, forKey: "userId")
                newInsertion.setValue(cData.exchange, forKey: "exchange")
                newInsertion.setValue(cData.senderImage, forKey: "senderImage")
                newInsertion.setValue(cData.status, forKey: "status")
                
                
                do {
                    try context.save()
                   // print("Member Saved Sucessfully")
                } catch {
                  //  print("Error in Saving Members")
                }
            }
            
        }
        
    }
    public func saveChatMessagesInDataBase(data:[ChatHistoryObject], chatData : Constants.jsonStandard!) ->Void{
        
        DispatchQueue.global(qos: .userInitiated).async {
            // 1
            //let overlayImage = self.faceOverlayImageFromImage(self.image)
            
            for i in 0 ..< data.count {
                
                let cData = data[i]
                
                cData.PrintMySelf()
                var msgArray = [ChatHistoryObject]()
                //            if cData.senderId  == UserDefaults.standard.value(forKey: Constants.kChatUserId) as! String
                //            {
                msgArray = self.fetchChatMessagesWithId(msgId: cData.idd)
                //  }
                
                if msgArray.count > 0
                {
                    
                    //self.updateChatStatusNew(status: cData.status, chatId: cData.originalId)
                   self.updateChatStatus(status: cData.status, chatId: cData.originalId)
                    
                }
                else
                {
                    let context = self.contextNew.viewContext
                    let newInsertion = NSEntityDescription.insertNewObject(forEntityName: "ChatHistory", into: context)
                    let idd = ChatDBManager.ChatDBManagerSharedInstance.fetchTheNextIdFor(table: "ChatHistory")
                    newInsertion.setValue(idd, forKey: "idd")
                    newInsertion.setValue(cData.originalId, forKey: "originalId")
                    newInsertion.setValue(cData.message, forKey: "message")
                    newInsertion.setValue(cData.exchange, forKey: "exchange")
                    newInsertion.setValue(cData.chattimestamp, forKey: "timestamp")
                    newInsertion.setValue(cData.recieverId, forKey: "recieverId")
                    newInsertion.setValue(cData.senderId, forKey: "senderId")
                    newInsertion.setValue(cData.status, forKey: "status")
                    newInsertion.setValue(cData.type, forKey: "type")
                    newInsertion.setValue(cData.image64, forKey: "image64")
                    
                    do {
                        try context.save()
                        NotificationCenter.default.post(name: Notification.Name("systemNotificationGenerated"), object: nil , userInfo: chatData)
                      //  print("Member Saved Sucessfully")
                    } catch {
                      //  print("Error in Saving Members")
                    }
                    
                    
                }
                
                
                
            }
            
            
            DispatchQueue.main.async { // 2
                //self.fadeInNewImage(overlayImage) // 3
            }
            
        }
        
        
        
    }
    public func saveChatMessagesInDataBaseNew(cData:ChatHistoryObject!) ->Void{
        
        DispatchQueue.global(qos: .userInitiated).async {
            // 1
            //let overlayImage = self.faceOverlayImageFromImage(self.image)
            
            //for i in 0 ..< data.count {
                
              //  let cData = data[i]
                
            var msgArray = [ChatHistoryObject]()
            
//             msgArray = self.fetchChatMessagesWithId(msgId: cData.originalId)
//            if(msgArray.count > 0)
//            {
//                return
//            }
              //  msgArray = self.fetchChatMessagesWithId(msgId: cData.originalId) // this wa id changed to originalId
                //  }
            let timeStamp = cData.chattimestamp as! Int64
            msgArray = self.fetchChatMessagesWithIdAndTimeStamp(msgId: cData.originalId, timestamp: timeStamp)
                if msgArray.count > 0
                {
                    self.isProccessing = false
                    cData.dbAction = "2"
                    self.arrayChatQueue.append(cData)
                   // if(!self.isOurQueueInProcess){
                        
                        self.KeepReadingOurQueue()
                  //  }
                    //self.updateChatStatusNew(status: cData.status, chatId: cData.originalId)
                }
                else
                {
                    self.setUpFetchRequestCoreData()
                    let context = self.contextNew.viewContext
                    
                    // Create Quote
                    let chat = ChatHistory(context: context)
                    
                    chat.idd = cData.idd
                    chat.originalId = cData.originalId
                    chat.message = cData.message
                    chat.image64 = cData.image64
                    chat.exchange = cData.exchange
                    chat.recieverId = cData.recieverId
                    chat.senderId = cData.senderId
                    chat.status = cData.status
                    chat.type = cData.type
                    chat.timestamp = cData.chattimestamp as! Int64
                    do {
                        try context .save()
                        
                        //  print("Member Saved Sucessfully")
                    } catch {
                        //  print("Error in Saving Members")
                    }
                //}
                    self.isProccessing = false
                    self.arrayChatQueue.remove(at: 0)
                    self.KeepReadingOurQueue()
            }
            // cur change
            
        }
        
        
    }
    
    public func insertSendingMessagesToDB(message:String!, exchange : String!) ->Void{
        
        DispatchQueue.global(qos: .userInitiated).async {
            // 1
            //let overlayImage = self.faceOverlayImageFromImage(self.image)
            
            
            
                    let context = self.contextNew.viewContext
                    let newInsertion = NSEntityDescription.insertNewObject(forEntityName: "ChatHistory", into: context)
                    let idd = ChatDBManager.ChatDBManagerSharedInstance.fetchTheNextIdFor(table: "SendingChat")
                    newInsertion.setValue(idd, forKey: "idd")
                    newInsertion.setValue(message, forKey: "message")
                    newInsertion.setValue(exchange, forKey: "exchange")
                    do {
                        try context.save()
                        
                    } catch {
                        //  print("Error in Saving Members")
                    }
        }
    }
    //MARK:- Fetch From DataBase
    
    func fetchThreads() ->[ChatThreadModel]{
        
        var returnArray = [ChatThreadModel]()
        
        let context = self.contextNew.viewContext
        let request = NSFetchRequest<NSFetchRequestResult>(entityName : "ChatThreads")
        //request.predicate = NSPredicate(format: "country_id == %@",country)
        
        do
        {
            let results = try context.fetch(request)
            if results.count > 0
            {
                for result in results as! [NSManagedObject]
                {
                    var fetchValue = Constants.jsonStandard()
                    let idd = result.value(forKey: "idd")
                    let chatImage = result.value(forKey: "senderImage")
                  //  let isOnline = result.value(forKey: "isOnline")
                    let lastmessage = result.value(forKey: "lastmessage")
                    let name = result.value(forKey: "exchange")
                    let senderName = result.value(forKey: "senderName")
                    
                    fetchValue["id"] = idd as AnyObject
                    fetchValue["senderImage"] = chatImage as AnyObject
                   // fetchValue["isOnline"] = isOnline as AnyObject
                    fetchValue["lastmessage"] = lastmessage as AnyObject
                    fetchValue["exchange"] = name as AnyObject
                    fetchValue["senderName"] = senderName as AnyObject
                    
                    let obj = ChatThreadModel(info:fetchValue)
                    
                    returnArray.append(obj)
                    
                }
            }
            
        }
        catch
        {
            print("Error in Feching The ChatThreads")
        }
        
        return returnArray
        
    }
    
    func fetchThreadWithName(name : String!) ->[ChatThreadModel]{
        
        var returnArray = [ChatThreadModel]()
        
        let context = self.contextNew.viewContext
        let request = NSFetchRequest<NSFetchRequestResult>(entityName : "ChatThreads")
        request.predicate = NSPredicate(format: "exchange == %@",name)
        
        do
        {
            let results : Array? = try context.fetch(request)
            if (results?.count)! > 0
            {
                for result in results as! [NSManagedObject]
                {
                    var fetchValue = Constants.jsonStandard()
                    let idd = result.value(forKey: "idd")
                    let chatImage = result.value(forKey: "senderImage")
                    //  let isOnline = result.value(forKey: "isOnline")
                    let lastmessage = result.value(forKey: "lastmessage")
                    let name = result.value(forKey: "exchange")
                    let senderName = result.value(forKey: "senderName")
                    
                    fetchValue["id"] = idd as AnyObject
                    fetchValue["senderImage"] = chatImage as AnyObject
                    // fetchValue["isOnline"] = isOnline as AnyObject
                    fetchValue["lastmessage"] = lastmessage as AnyObject
                    fetchValue["exchange"] = name as AnyObject
                    fetchValue["senderName"] = senderName as AnyObject
                    
                    let obj = ChatThreadModel(info:fetchValue)
                    
                    returnArray.append(obj)
                    
                }
            }
            
        }
        catch
        {
            print("Error in Feching The ChatThreads")
        }
        
        return returnArray
        
    }
    
    func fetchMemberWithExchange(exchange : String!, userId : String!) ->[ChatMemberObject]{
        
        var returnArray = [ChatMemberObject]()
        
        let context = self.contextNew.viewContext
        let request = NSFetchRequest<NSFetchRequestResult>(entityName : "Members")
        request.predicate = NSPredicate(format: "exchange == %@ AND userId == %@",exchange,userId)
        
        do
        {
            let results : Array? = try context.fetch(request)
            if (results?.count)! > 0
            {
                for result in results as! [NSManagedObject]
                {
                    
                    // fetching from DB
                    var fetchValue = Constants.jsonStandard()
                    let idd = result.value(forKey: "idd")
                    let name = result.value(forKey: "name")
                    let userId = result.value(forKey: "userId")
                    let exchange = result.value(forKey: "exchange")
                    let senderImage = result.value(forKey: "senderImage")
                    let status = result.value(forKey: "status")
                    
                    
                    // Adding to Chat Object
                    fetchValue["id"] = idd as AnyObject
                    fetchValue["name"] = name as AnyObject
                    fetchValue["userId"] = userId as AnyObject
                    fetchValue["exchange"] = exchange as AnyObject
                    fetchValue["senderImage"] = senderImage as AnyObject
                    fetchValue["status"] = status as AnyObject
                    
                    
                    let obj = ChatMemberObject(info:fetchValue)
                    
                    returnArray.append(obj)
                    
                }
            }
            
        }
        catch
        {
            print("Error in Feching The ChatThreads")
        }
        
        return returnArray
        
    }
    func fetchMemberWithUserId(userId : String!) ->[ChatMemberObject]{
        
        var returnArray = [ChatMemberObject]()
        
        let context = self.contextNew.viewContext
        let request = NSFetchRequest<NSFetchRequestResult>(entityName : "Members")
        request.predicate = NSPredicate(format: "userId == %@",userId)
        
        do
        {
            let results : Array? = try context.fetch(request)
            if (results?.count)! > 0
            {
                for result in results as! [NSManagedObject]
                {
                    
                    // fetching from DB
                    var fetchValue = Constants.jsonStandard()
                    let idd = result.value(forKey: "idd")
                    let name = result.value(forKey: "name")
                    let userId = result.value(forKey: "userId")
                    let exchange = result.value(forKey: "exchange")
                    let senderImage = result.value(forKey: "senderImage")
                    let status = result.value(forKey: "status")
                    
                    
                    // Adding to Chat Object
                    fetchValue["id"] = idd as AnyObject
                    fetchValue["name"] = name as AnyObject
                    fetchValue["userId"] = userId as AnyObject
                    fetchValue["exchange"] = exchange as AnyObject
                    fetchValue["senderImage"] = senderImage as AnyObject
                    fetchValue["status"] = status as AnyObject
                    
                    
                    let obj = ChatMemberObject(info:fetchValue)
                    
                    returnArray.append(obj)
                    
                }
            }
            
        }
        catch
        {
            print("Error in Feching The ChatThreads")
        }
        
        return returnArray
        
    }
//    func fetchMemberWithUserId(exchange : String!) ->[ChatMemberObject]{
//        
//        var returnArray = [ChatMemberObject]()
//        
//        let context = self.contextNew.viewContext
//        let request = NSFetchRequest<NSFetchRequestResult>(entityName : "Members")
//        request.predicate = NSPredicate(format: "exchange == %@",exchange)
//        
//        do
//        {
//            let results : Array? = try context.fetch(request)
//            if (results?.count)! > 0
//            {
//                for result in results as! [NSManagedObject]
//                {
//                    
//                    // fetching from DB
//                    var fetchValue = Constants.jsonStandard()
//                    let idd = result.value(forKey: "idd")
//                    let name = result.value(forKey: "name")
//                    let userId = result.value(forKey: "userId")
//                    let exchange = result.value(forKey: "exchange")
//                    let senderImage = result.value(forKey: "senderImage")
//                    let status = result.value(forKey: "status")
//                    
//                    
//                    // Adding to Chat Object
//                    fetchValue["id"] = idd as AnyObject
//                    fetchValue["name"] = name as AnyObject
//                    fetchValue["userId"] = userId as AnyObject
//                    fetchValue["exchange"] = exchange as AnyObject
//                    fetchValue["senderImage"] = senderImage as AnyObject
//                    fetchValue["status"] = status as AnyObject
//                    
//                    
//                    let obj = ChatMemberObject(info:fetchValue)
//                    
//                    if userId as! String != UserDefaults.standard.value(forKey: Constants.kUserId) as! String
//                    {
//                        returnArray.append(obj)
//                    }
//                    
//                    
//                }
//            }
//            
//        }
//        catch
//        {
//            print("Error in Feching The ChatThreads")
//        }
//        
//        return returnArray
//        
//    }
    
    func fetchChatMessages(threadId : String!) ->[ChatHistoryObject]{
        
        var returnArray = [ChatHistoryObject]()
        
        let context = self.contextNew.viewContext
        let request = NSFetchRequest<NSFetchRequestResult>(entityName : "ChatHistory")
        request.predicate = NSPredicate(format: "exchange == %@",threadId)
        
        do
        {
            let results = try context.fetch(request)
            if results.count > 0
            {
                for result in results as! [NSManagedObject]
                {
                    // fetching from DB
                    var fetchValue = Constants.jsonStandard()
                    let idd = result.value(forKey: "idd")
                    let originalId = result.value(forKey: "originalId")
                    let chatImage = result.value(forKey: "message")
                    let senderId = result.value(forKey: "senderId")
                    let lastmessage = result.value(forKey: "exchange")
                    let name = result.value(forKey: "timestamp")
                    let recieverId = result.value(forKey: "recieverId")
                    let status = result.value(forKey: "status")
                    let type = result.value(forKey: "type")
                    let image64 = result.value(forKey: "image64")
                    
                    // Adding to Chat Object
                    fetchValue["id"] = idd as AnyObject
                    fetchValue["originalId"] = idd as AnyObject
                    fetchValue["message"] = chatImage as AnyObject
                    fetchValue["sender_id"] = senderId as AnyObject
                    fetchValue["exchange"] = lastmessage as AnyObject
                    fetchValue["timestamp"] = name as AnyObject
                    fetchValue["receiver_id"] = recieverId as AnyObject
                    fetchValue["status"] = status as AnyObject
                    fetchValue["type"] = type as AnyObject
                    fetchValue["image64"] = image64 as AnyObject
                    
                    let obj = ChatHistoryObject(info:fetchValue)
                    
                    returnArray.append(obj)
                    
                }
            }
            
        }
        catch
        {
            print("Error in Feching The Chat History")
        }
        
        return returnArray
        
    }
    func fetchLastChatMessages(threadId : String!) ->[ChatHistoryObject]{
        
        var returnArray = [ChatHistoryObject]()
        
        let context = self.contextNew.viewContext
        let request = NSFetchRequest<NSFetchRequestResult>(entityName : "ChatHistory")
        request.predicate = NSPredicate(format: "exchange == %@",threadId)
        let idDescriptor: NSSortDescriptor = NSSortDescriptor(key: "idd", ascending: false)
        request.sortDescriptors = [idDescriptor] // Note this is a array, you can put multiple sort conditions if you want
        
        request.fetchLimit = 1
        
        do
        {
            let results = try context.fetch(request)
            if results.count > 0
            {
                for result in results as! [NSManagedObject]
                {
                    // fetching from DB
                    var fetchValue = Constants.jsonStandard()
                    let idd = result.value(forKey: "idd")
                    let originalId = result.value(forKey: "originalId")
                    let chatImage = result.value(forKey: "message")
                    let senderId = result.value(forKey: "senderId")
                    let lastmessage = result.value(forKey: "exchange")
                    let name = result.value(forKey: "timestamp")
                    let recieverId = result.value(forKey: "recieverId")
                    let status = result.value(forKey: "status")
                    let type = result.value(forKey: "type")
                    let image64 = result.value(forKey: "image64")
                    
                    // Adding to Chat Object
                    fetchValue["id"] = idd as AnyObject
                    fetchValue["originalId"] = idd as AnyObject
                    fetchValue["message"] = chatImage as AnyObject
                    fetchValue["sender_id"] = senderId as AnyObject
                    fetchValue["exchange"] = lastmessage as AnyObject
                    fetchValue["timestamp"] = name as AnyObject
                    fetchValue["receiver_id"] = recieverId as AnyObject
                    fetchValue["status"] = status as AnyObject
                    fetchValue["type"] = type as AnyObject
                    fetchValue["image64"] = image64 as AnyObject
                    
                    let obj = ChatHistoryObject(info:fetchValue)
                    
                    returnArray.append(obj)
                    
                }
            }
            
        }
        catch
        {
            print("Error in Feching The Chat History")
        }
        
        return returnArray
        
    }
    func fetchChatMessagesWithId(msgId : Int64) ->[ChatHistoryObject]{
        
        var returnArray = [ChatHistoryObject]()
        
        let context = self.contextNew.viewContext
        let request = NSFetchRequest<NSFetchRequestResult>(entityName : "ChatHistory")
        request.predicate = NSPredicate(format: "idd == %d",msgId)
        
        do
        {
            let results = try context.fetch(request)
            if results.count > 0
            {
                for result in results as! [NSManagedObject]
                {
                    // fetching from DB
                    var fetchValue = Constants.jsonStandard()
                    let idd = result.value(forKey: "idd")
                    let originalId = result.value(forKey: "originalId")
                    let chatImage = result.value(forKey: "message")
                    let senderId = result.value(forKey: "senderId")
                    let lastmessage = result.value(forKey: "exchange")
                    let name = result.value(forKey: "timestamp")
                    let recieverId = result.value(forKey: "recieverId")
                    let status = result.value(forKey: "status")
                    let type = result.value(forKey: "type")
                    let image64 = result.value(forKey: "image64")
                    
                    // Adding to Chat Object
                    fetchValue["id"] = idd as AnyObject
                    fetchValue["originalId"] = originalId as AnyObject
                    fetchValue["message"] = chatImage as AnyObject
                    fetchValue["sender_id"] = senderId as AnyObject
                    fetchValue["exchange"] = lastmessage as AnyObject
                    fetchValue["timestamp"] = name as AnyObject
                    fetchValue["receiver_id"] = recieverId as AnyObject
                    fetchValue["status"] = status as AnyObject
                    fetchValue["type"] = type as AnyObject
                    fetchValue["image64"] = image64 as AnyObject
                    
                    let obj = ChatHistoryObject(info:fetchValue)
                    
                    returnArray.append(obj)
                    
                }
            }
            
        }
        catch
        {
            print("Error in Feching The Chat History")
        }
        
        return returnArray
        
    }
    func fetchChatMessagesWithIdAndTimeStamp(msgId : Int64 , timestamp : Int64) ->[ChatHistoryObject]{
        
        var returnArray = [ChatHistoryObject]()
        
        let context = self.contextNew.viewContext
        let request = NSFetchRequest<NSFetchRequestResult>(entityName : "ChatHistory")
        request.predicate = NSPredicate(format: "originalId == %d AND timestamp == %d",msgId,timestamp)
        
        do
        {
            let results = try context.fetch(request)
            if results.count > 0
            {
                for result in results as! [NSManagedObject]
                {
                    // fetching from DB
                    var fetchValue = Constants.jsonStandard()
                    let idd = result.value(forKey: "idd")
                    let originalId = result.value(forKey: "originalId")
                    let chatImage = result.value(forKey: "message")
                    let senderId = result.value(forKey: "senderId")
                    let lastmessage = result.value(forKey: "exchange")
                    let name = result.value(forKey: "timestamp")
                    let recieverId = result.value(forKey: "recieverId")
                    let status = result.value(forKey: "status")
                    let type = result.value(forKey: "type")
                    let image64 = result.value(forKey: "image64")
                    
                    // Adding to Chat Object
                    fetchValue["id"] = idd as AnyObject
                    fetchValue["originalId"] = originalId as AnyObject
                    fetchValue["message"] = chatImage as AnyObject
                    fetchValue["sender_id"] = senderId as AnyObject
                    fetchValue["exchange"] = lastmessage as AnyObject
                    fetchValue["timestamp"] = name as AnyObject
                    fetchValue["receiver_id"] = recieverId as AnyObject
                    fetchValue["status"] = status as AnyObject
                    fetchValue["type"] = type as AnyObject
                    fetchValue["image64"] = image64 as AnyObject
                    
                    let obj = ChatHistoryObject(info:fetchValue)
                    
                    returnArray.append(obj)
                    
                }
            }
            
        }
        catch
        {
            print("Error in Feching The Chat History")
        }
        
        return returnArray
        
    }
    func fetchAllDelivereChatMsgsWithSenderId(exchange: String!, status : String!, senderId : String!) ->[ChatHistoryObject]{
        
        var returnArray = [ChatHistoryObject]()
        
        let context = self.contextNew.viewContext
        let request = NSFetchRequest<NSFetchRequestResult>(entityName : "ChatHistory")
        request.predicate = NSPredicate(format: "status == %@ AND exchange == %@ AND recieverId == %@",status,exchange,(UserDefaults.standard.value(forKey: Constants.kChatUserId) as? String)!)
        
        do
        {
            let results = try context.fetch(request)
            if results.count > 0
            {
                for result in results as! [NSManagedObject]
                {
                    // fetching from DB
                    var fetchValue = Constants.jsonStandard()
                    let idd = result.value(forKey: "idd")
                    let originalId = result.value(forKey: "originalId")
                    let chatImage = result.value(forKey: "message")
                    let senderId = result.value(forKey: "senderId")
                    let lastmessage = result.value(forKey: "exchange")
                    let name = result.value(forKey: "timestamp")
                    let recieverId = result.value(forKey: "recieverId")
                    let type = result.value(forKey: "type")
                    
                    
                    // Adding to Chat Object
                    fetchValue["id"] = idd as AnyObject
                    fetchValue["originalId"] = originalId as AnyObject
                    fetchValue["message"] = chatImage as AnyObject
                    fetchValue["sender_id"] = senderId as AnyObject
                    fetchValue["exchange"] = lastmessage as AnyObject
                    fetchValue["timestamp"] = name as AnyObject
                    fetchValue["receiver_id"] = recieverId as AnyObject
                    fetchValue["type"] = type as AnyObject
                    fetchValue["status"] = "read" as AnyObject
                    
                    
                    let obj = ChatHistoryObject(info:fetchValue)
                    
                    returnArray.append(obj)
                    
                }
            }
            
        }
        catch
        {
            print("Error in Feching The Chat History")
        }
        
        return returnArray
        
    }
    func fetchAllDelivereChatMsgs(exchange: String!, status : String!) ->[ChatHistoryObject]{
        
        var returnArray = [ChatHistoryObject]()
        
        let context = self.contextNew.viewContext
        let request = NSFetchRequest<NSFetchRequestResult>(entityName : "ChatHistory")
        request.predicate = NSPredicate(format: "status == %@ AND exchange == %@",status,exchange)
        
        do
        {
            let results = try context.fetch(request)
            if results.count > 0
            {
                for result in results as! [NSManagedObject]
                {
                    // fetching from DB
                    var fetchValue = Constants.jsonStandard()
                    let idd = result.value(forKey: "idd")
                    let originalId = result.value(forKey: "originalId")
                    let chatImage = result.value(forKey: "message")
                    let senderId = result.value(forKey: "senderId")
                    let lastmessage = result.value(forKey: "exchange")
                    let name = result.value(forKey: "timestamp")
                    let recieverId = result.value(forKey: "recieverId")
                    let type = result.value(forKey: "type")
                    
                    
                    // Adding to Chat Object
                    fetchValue["id"] = idd as AnyObject
                    fetchValue["originalId"] = originalId as AnyObject
                    fetchValue["message"] = chatImage as AnyObject
                    fetchValue["sender_id"] = senderId as AnyObject
                    fetchValue["exchange"] = lastmessage as AnyObject
                    fetchValue["timestamp"] = name as AnyObject
                    fetchValue["receiver_id"] = recieverId as AnyObject
                    fetchValue["type"] = type as AnyObject
                    fetchValue["status"] = "read" as AnyObject
                    
                    
                    let obj = ChatHistoryObject(info:fetchValue)
                    
                    returnArray.append(obj)
                    
                }
            }
            
        }
        catch
        {
            print("Error in Feching The Chat History")
        }
        
        return returnArray
        
    }
    func fetchAllChatMsgsWithStatus(exchange: String!, status : String!) ->[ChatHistoryObject]{
        
        var returnArray = [ChatHistoryObject]()
        
        let context = self.contextNew.viewContext
        let request = NSFetchRequest<NSFetchRequestResult>(entityName : "ChatHistory")
        request.predicate = NSPredicate(format: "status == %@ AND exchange == %@",status,exchange)
        
        do
        {
            let results = try context.fetch(request)
            if results.count > 0
            {
                for result in results as! [NSManagedObject]
                {
                    // fetching from DB
                    var fetchValue = Constants.jsonStandard()
                    let idd = result.value(forKey: "idd")
                    let originalId = result.value(forKey: "originalId")
                    let chatImage = result.value(forKey: "message")
                    let senderId = result.value(forKey: "senderId")
                    let lastmessage = result.value(forKey: "exchange")
                    let name = result.value(forKey: "timestamp")
                    let recieverId = result.value(forKey: "recieverId")
                    let status = result.value(forKey: "status")
                    
                    
                    // Adding to Chat Object
                    fetchValue["id"] = idd as AnyObject
                    fetchValue["originalId"] = originalId as AnyObject
                    fetchValue["message"] = chatImage as AnyObject
                    fetchValue["sender_id"] = senderId as AnyObject
                    fetchValue["exchange"] = lastmessage as AnyObject
                    fetchValue["timestamp"] = name as AnyObject
                    fetchValue["receiver_id"] = recieverId as AnyObject
                    fetchValue["status"] = status as AnyObject
                    
                    
                    let obj = ChatHistoryObject(info:fetchValue)
                    
                    returnArray.append(obj)
                    
                }
            }
            
        }
        catch
        {
            print("Error in Feching The Chat History")
        }
        
        return returnArray
        
    }
    
    func fetchAllSendingChatMessages(status: String!) ->[ChatHistoryObject]{
        
        var returnArray = [ChatHistoryObject]()
        
        let context = self.contextNew.viewContext
        let request = NSFetchRequest<NSFetchRequestResult>(entityName : "ChatHistory")
        request.predicate = NSPredicate(format: "status == %@",status)
        
        do
        {
            let results = try context.fetch(request)
            if results.count > 0
            {
                for result in results as! [NSManagedObject]
                {
                    // fetching from DB
                    var fetchValue = Constants.jsonStandard()
                    let idd = result.value(forKey: "idd")
                    let originalId = result.value(forKey: "originalId")
                    let chatImage = result.value(forKey: "message")
                    let senderId = result.value(forKey: "senderId")
                    let lastmessage = result.value(forKey: "exchange")
                    let name = result.value(forKey: "timestamp")
                    let recieverId = result.value(forKey: "recieverId")
                    let status = result.value(forKey: "status")
                    let image64 = result.value(forKey: "image64")
                    let type = result.value(forKey: "type")
                    
                    // Adding to Chat Object
                    fetchValue["id"] = idd as AnyObject
                    fetchValue["originalId"] = originalId as AnyObject
                    fetchValue["message"] = chatImage as AnyObject
                    fetchValue["sender_id"] = senderId as AnyObject
                    fetchValue["exchange"] = lastmessage as AnyObject
                    fetchValue["timestamp"] = name as AnyObject
                    fetchValue["receiver_id"] = recieverId as AnyObject
                    fetchValue["status"] = status as AnyObject
                    fetchValue["image64"] = image64 as AnyObject
                    fetchValue["type"] = type as AnyObject
                    
                    
                    let obj = ChatHistoryObject(info:fetchValue)
                    
                    returnArray.append(obj)
                    
                }
            }
            
        }
        catch
        {
            print("Error in Feching The Chat History")
        }
        
        return returnArray
        
    }
    
    func fetchMembersFromDB(exchange : String!) ->[ChatMemberObject]{
        
        var returnArray = [ChatMemberObject]()
        
        let context = self.contextNew.viewContext
        let request = NSFetchRequest<NSFetchRequestResult>(entityName : "Members")
        request.predicate = NSPredicate(format: "exchange == %@",exchange)
        
        do
        {
            let results = try context.fetch(request)
            if results.count > 0
            {
                for result in results as! [NSManagedObject]
                {
                    // fetching from DB
                    var fetchValue = Constants.jsonStandard()
                    let idd = result.value(forKey: "idd")
                    let name = result.value(forKey: "name")
                    let userId = result.value(forKey: "userId")
                    let exchange = result.value(forKey: "exchange")
                    let senderImage = result.value(forKey: "senderImage")
                    let status = result.value(forKey: "status")
                    
                    
                    // Adding to Chat Object
                    fetchValue["id"] = idd as AnyObject
                    fetchValue["name"] = name as AnyObject
                    fetchValue["userId"] = userId as AnyObject
                    fetchValue["exchange"] = exchange as AnyObject
                    fetchValue["senderImage"] = senderImage as AnyObject
                    fetchValue["status"] = status as AnyObject
                    
                    
                    let obj = ChatMemberObject(info:fetchValue)
                    
                    if userId as! String != UserDefaults.standard.value(forKey: Constants.kChatUserId) as! String
                    {
                        returnArray.append(obj)
                    }
                    
                }
            }
            
        }
        catch
        {
            print("Error in Feching The Chat History")
        }
        
        return returnArray
        
    }
    func fetchTheNextIdFor(table : String) -> Int64 {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: table)
        let context = self.contextNew.viewContext
        // Sort Descriptor
        let idDescriptor: NSSortDescriptor = NSSortDescriptor(key: "idd", ascending: false)
        fetchRequest.sortDescriptors = [idDescriptor] // Note this is a array, you can put multiple sort conditions if you want
        
        fetchRequest.fetchLimit = 1
        
        var newId : Int64 = 0; // Default to 0, so that you can check if do catch block went wrong later
        
        do {
             let results = try context.fetch(fetchRequest)
            //Compute the id
            if results.count > 0
            {
                for result in results as! [NSManagedObject]
                {
                    // fetching from DB
                    let idd : Int = result.value(forKey: "idd") as! Int
                    newId = Int64(idd + 1)
                }
            }
            else
            {
                newId = 1
            }
        }
        catch {
            let fetchError = error as NSError
            print(fetchError)
        }
    return newId
    }
    
    //MARK:- ReSending Messages Functionality
    func  fetchSendingMsgsAndResend() -> Void {
        
//        ChatDBManager.ChatDBManagerSharedInstance.myQueue = UserDefaults.standard.value(forKey: Constants.myQueue) as! String
//        ChatDBManager.ChatDBManagerSharedInstance.subscribeToRabbitMQServer(exchangeName: UserDefaults.standard.value(forKey: Constants.systemExchange) as! String, queueName: UserDefaults.standard.value(forKey: Constants.myQueue) as! String )
        
        let arrayMsgs = ChatDBManager.ChatDBManagerSharedInstance.fetchAllSendingChatMessages(status: "sending")
        for  i in 0..<arrayMsgs.count
        {
            let  msgObj = arrayMsgs[i]
            let senderId = msgObj.senderId
            
            if senderId == UserDefaults.standard.value(forKey: Constants.kChatUserId) as? String
            {
                self.retrySendingMessage(msgObj: msgObj)
            }
            
        }
    }
    func  fetchSendingMsgsAndMarkFailed() -> Void {
        let arrayMsgs = ChatDBManager.ChatDBManagerSharedInstance.fetchAllSendingChatMessages(status: "sending")
        for  i in 0..<arrayMsgs.count
        {
            let  msgObj = arrayMsgs[i]
            let senderId = msgObj.senderId

            if senderId == UserDefaults.standard.value(forKey: Constants.kChatUserId) as? String
            {
                ChatDBManager.ChatDBManagerSharedInstance.updateChatSendingStatusToFailed(status: msgObj.status, chatId: msgObj.idd)
            }

        }
        self.fetchFailedMessagesAndResend()
    }
    func  fetchFailedMessagesAndResend() -> Void {
        let arrayMsgs = ChatDBManager.ChatDBManagerSharedInstance.fetchAllSendingChatMessages(status: "failed")
        for  i in 0..<arrayMsgs.count
        {
            let  msgObj = arrayMsgs[i]
            let senderId = msgObj.senderId
            
            if senderId == UserDefaults.standard.value(forKey: Constants.kChatUserId) as? String
            {
                self.retrySendingMessage(msgObj: msgObj)
            }
            
        }
    }
    func fetchMsgObjFromLocalArray(tag: Int, url : String!) -> Void
    {
        
        let msgObj = arrayForImageMsgs[tag]
        msgObj.message = url
        retrySendingMessage(msgObj: msgObj)
        
    }
    func retrySendingMessage(msgObj: ChatHistoryObject!)
    {
        var dic = Constants.jsonStandard()
        dic["type"] = "chat" as AnyObject
        dic["subtype"] = "message" as AnyObject
        dic["application_name"] = "Evento" as AnyObject
        dic["exchange"] = msgObj.exchange as AnyObject
        dic["senderNumber"] = "988347928429" as AnyObject
        dic["queue"] = self.myQueue as AnyObject
        dic["senderName"] = "\(SingletonClassOfObjects.SharedInstance.userObject.first_name!) \(SingletonClassOfObjects.SharedInstance.userObject.last_name!)"  as AnyObject
        dic["senderImage"] = SingletonClassOfObjects.SharedInstance.userObject.image_name as AnyObject
        dic["userId"] = UserDefaults.standard.value(forKey: Constants.kChatUserId) as AnyObject
        
        var chat = Constants.jsonStandard()
        chat["id"] = msgObj.idd as AnyObject
        chat["originalId"] = msgObj.originalId as AnyObject
        chat["message"] = msgObj.message as AnyObject
        chat["sender_id"] = msgObj.senderId as AnyObject
        chat["exchange"] = msgObj.exchange as AnyObject
        chat["timestamp"] = msgObj.chattimestamp as AnyObject
        chat["receiver_id"] = msgObj.recieverId as AnyObject
        chat["status"] = msgObj.status as AnyObject
        chat["type"] = msgObj.type as AnyObject
        //chat["status"] = "failed" as AnyObject
        chat["image64"] = msgObj.image64 as AnyObject
        
       // if ((msgObj.message.isEmpty || msgObj.message == nil) && msgObj.type == "image")
        if (msgObj.message.isEmpty || msgObj.message == nil) 
        {
            arrayForImageMsgs.append(msgObj)
            self.apiCallForUploadImaget(imageData: msgObj.image64, tag: arrayForImageMsgs.count - 1)
            return
        }
        
        dic["chatHistory"] = chat as AnyObject
        
        var msg = ""
        do {
            let data = try JSONSerialization.data(withJSONObject:dic, options:[])
            msg = String(data: data, encoding: String.Encoding.utf8)!
            
        } catch {
            print("JSON serialization failed:  \(error)")
        }
        // send msg with blured image
        
        ChatDBManager.ChatDBManagerSharedInstance.sendMessageToExchange(exchangeName: msgObj.exchange, queue: self.myQueue, message: msg)
        
    }
    
    //MARK:- Update DB
    
    func DeleteEverThing() -> Void {
        let fetch = NSFetchRequest<NSFetchRequestResult>(entityName: "ChatHistory")
        let request = NSBatchDeleteRequest(fetchRequest: fetch)
        let context = self.contextNew.viewContext
        do {
            _ = try context.execute(request)
        }
        
        catch {
            print("Error with request: \(error)")
        }
        
        let fetch1 = NSFetchRequest<NSFetchRequestResult>(entityName: "Members")
        let request1 = NSBatchDeleteRequest(fetchRequest: fetch1)
        let context1 = self.contextNew.viewContext
        do {
            _ = try context1.execute(request1)
        }
            
        catch {
            print("Error with request: \(error)")
        }
        
        let fetch2 = NSFetchRequest<NSFetchRequestResult>(entityName: "ChatThreads")
        let request2 = NSBatchDeleteRequest(fetchRequest: fetch2)
        let context2 = self.contextNew.viewContext
        do {
            _ = try context2.execute(request2)
        }
            
        catch {
            print("Error with request: \(error)")
        }
        
    }
    
    func updateChatStatus (status:String! , chatId:Int64) {
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "ChatHistory")
        let context = self.contextNew.viewContext
        fetchRequest.predicate = NSPredicate(format: "originalId == %d",chatId)
        
        var fetchValue = Constants.jsonStandard()
        var idddd : Int64!
        do {
        
            let results = try context.fetch(fetchRequest)
            
            if results.count > 0
            {
                for result in results as! [NSManagedObject]
                {
                    
                   var sattus = status
                    if sattus == "sending" {
                        sattus = "sent"
                    }
                    if sattus == "failed" {
                        sattus = "sent"
                    }
                    
                    let status1 = result.value(forKey: "status") as! String
                    if status1 != "read" {
                        result.setValue(sattus, forKey: "status")
                    }
                    idddd = result.value(forKey: "idd") as! Int64
                    let idd = result.value(forKey: "idd")
                    let originalId = result.value(forKey: "originalId")
                    let chatImage = result.value(forKey: "message")
                    let senderId = result.value(forKey: "senderId")
                    let lastmessage = result.value(forKey: "exchange")
                    let name = result.value(forKey: "timestamp")
                    let recieverId = result.value(forKey: "recieverId")
                    let status = result.value(forKey: "status")
                    let type = result.value(forKey: "type")
                    let image64 = result.value(forKey: "image64")
                    
                    // Adding to Chat Object
                    fetchValue["id"] = idd as AnyObject
                    fetchValue["originalId"] = originalId as AnyObject
                    fetchValue["message"] = chatImage as AnyObject
                    fetchValue["sender_id"] = senderId as AnyObject
                    fetchValue["exchange"] = lastmessage as AnyObject
                    fetchValue["timestamp"] = name as AnyObject
                    fetchValue["receiver_id"] = recieverId as AnyObject
                    fetchValue["status"] = status as AnyObject
                    fetchValue["type"] = type as AnyObject
                    fetchValue["image64"] = image64 as AnyObject
                    
                }
                
                
                do {
                    try context.save()
                    print("saved!")
                    var dict  = Constants.jsonStandard()
                    dict["id"] = idddd as AnyObject
                    NotificationCenter.default.post(name: Notification.Name("chatStatusUpdated"), object: nil , userInfo: fetchValue)//
                } catch let error as NSError  {
                    print("Could not save \(error), \(error.userInfo)")
                }
            }
            else
            {
                
            }
            //save the context
            
        } catch {
            print("Error with request: \(error)")
        }
    }

    func setUpFetchRequestCoreData() -> Void
    {
        fetchedResultsController = {
            // Create Fetch Request
        
            let fetchRequest: NSFetchRequest<ChatHistory> = ChatHistory.fetchRequest()
            
            if ChatDBManager.chatIdForUpdate != nil
            {
                let  predicate = NSPredicate(format: "originalId == %d",ChatDBManager.chatIdForUpdate)
                fetchRequest.predicate = predicate
            }
            
            // Configure Fetch Request
            fetchRequest.sortDescriptors = [NSSortDescriptor(key: "idd", ascending: true)]
            
            // Create Fetched Results Controller
            let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: ChatDBManager.ChatDBManagerSharedInstance.contextNew.viewContext, sectionNameKeyPath: nil, cacheName: nil)
            return fetchedResultsController
        }()
        
        if ChatDBManager.ChatDBManagerSharedInstance.isPresistanceOfChatLoaded
       {
        
            do {
                try self.fetchedResultsController.performFetch()
                
            } catch {
                let fetchError = error as NSError
                print("Unable to Perform Fetch Request")
                print("\(fetchError), \(fetchError.localizedDescription)")
            }
        
        }
        else
       {
            ChatDBManager.ChatDBManagerSharedInstance.contextNew.loadPersistentStores { (persistentStoreDescription, error) in
                if let error = error {
                    print("Unable to Load Persistent Store")
                    print("\(error), \(error.localizedDescription)")
                    ChatDBManager.ChatDBManagerSharedInstance.isPresistanceOfChatLoaded = false
                    
                } else {
                    // self.setupView()
                    ChatDBManager.ChatDBManagerSharedInstance.isPresistanceOfChatLoaded = true
                    do {
                        try self.fetchedResultsController.performFetch()
                    } catch {
                        let fetchError = error as NSError
                        print("Unable to Perform Fetch Request")
                        print("\(fetchError), \(fetchError.localizedDescription)")
                    }
                    
                }
            }
        }
        
        
        
    }
    
    
    func updateChatStatusNew (status:String! , chatId:Int64) {
        DispatchQueue.global(qos: .userInitiated).async {
//        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "ChatHistory")
        let context = self.contextNew.viewContext
//        fetchRequest.predicate = NSPredicate(format: "originalId == %d",chatId)
    
        let indexPath = IndexPath(item: 0, section: 0)
        ChatDBManager.chatIdForUpdate = chatId
        
        self.setUpFetchRequestCoreData()
        if (self.fetchedResultsController.fetchedObjects!.count > 0)
        {
            let obj = self.fetchedResultsController.object(at: indexPath)
            
            let chatObj = obj
            if status == "failed" {
                obj.status = "sending"
            }
            else if status == "sending" {
                obj.status = "sent"
            }
            else if chatObj.status != "read" {
                obj.status = status
            }
            do {
                try context.save()
                //  print("Member Saved Sucessfully")
                
            } catch {
                //  print("Error in Saving Members")
            }
        }
       // cur change
            self.isProccessing = false
            if self.arrayChatQueue.count > 0
            {
                self.arrayChatQueue.remove(at: 0)
                self.KeepReadingOurQueue()
            }
        }
        
    }
    func updateChatSendingStatusToFailed (status:String! , chatId:Int64) {
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "ChatHistory")
        let context = self.contextNew.viewContext
        fetchRequest.predicate = NSPredicate(format: "originalId == %d",chatId)
        
        var fetchValue = Constants.jsonStandard()
        
        do {
            
            let results = try context.fetch(fetchRequest)
            
            if results.count > 0
            {
                for result in results as! [NSManagedObject]
                {
                    
                    var sattus = status
                    if sattus == "sending" {
                        sattus = "failed"
                    }
                    
                    result.setValue(sattus, forKey: "status")
                    
                    let idd = result.value(forKey: "idd")
                    let originalId = result.value(forKey: "originalId")
                    let chatImage = result.value(forKey: "message")
                    let senderId = result.value(forKey: "senderId")
                    let lastmessage = result.value(forKey: "exchange")
                    let name = result.value(forKey: "timestamp")
                    let recieverId = result.value(forKey: "recieverId")
                    let status = result.value(forKey: "status")
                    let type = result.value(forKey: "type")
                    let image64 = result.value(forKey: "image64")
                    
                    // Adding to Chat Object
                    fetchValue["id"] = idd as AnyObject
                    fetchValue["originalId"] = originalId as AnyObject
                    fetchValue["message"] = chatImage as AnyObject
                    fetchValue["sender_id"] = senderId as AnyObject
                    fetchValue["exchange"] = lastmessage as AnyObject
                    fetchValue["timestamp"] = name as AnyObject
                    fetchValue["receiver_id"] = recieverId as AnyObject
                    fetchValue["status"] = status as AnyObject
                    fetchValue["type"] = type as AnyObject
                    fetchValue["image64"] = image64 as AnyObject
                    
                }
            }
            else
            {
                
            }
            //save the context
            
            do {
                try context.save()
                print("saved!")
                var dict  = Constants.jsonStandard()
                dict["id"] = chatId as AnyObject
               // NotificationCenter.default.post(name: Notification.Name("chatStatusUpdated"), object: nil , userInfo: fetchValue)//
            } catch let error as NSError  {
                print("Could not save \(error), \(error.userInfo)")
            }
        } catch {
            print("Error with request: \(error)")
        }
    }
    func updateImagefromMessage (url:String! , chatId:Int64) {
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "ChatHistory")
        let context = self.contextNew.viewContext
        fetchRequest.predicate = NSPredicate(format: "originalId == %d",chatId)
        
        var fetchValue = Constants.jsonStandard()
        
        do {
            
            let results = try context.fetch(fetchRequest)
            
            if results.count > 0
            {
                for result in results as! [NSManagedObject]
                {
                
                    result.setValue("", forKey: "image64")
                    result.setValue(url, forKey: "message")
                    
                    
                    let idd = result.value(forKey: "idd")
                    let originalId = result.value(forKey: "originalId")
                    let chatImage = result.value(forKey: "message")
                    let senderId = result.value(forKey: "senderId")
                    let lastmessage = result.value(forKey: "exchange")
                    let name = result.value(forKey: "timestamp")
                    let recieverId = result.value(forKey: "recieverId")
                    let status = result.value(forKey: "status")
                    let type = result.value(forKey: "type")
                    let image64 = result.value(forKey: "image64")
                    
                    // Adding to Chat Object
                    fetchValue["id"] = idd as AnyObject
                    fetchValue["originalId"] = originalId as AnyObject
                    fetchValue["message"] = url as AnyObject
                    fetchValue["sender_id"] = senderId as AnyObject
                    fetchValue["exchange"] = lastmessage as AnyObject
                    fetchValue["timestamp"] = name as AnyObject
                    fetchValue["receiver_id"] = recieverId as AnyObject
                    fetchValue["status"] = status as AnyObject
                    fetchValue["type"] = type as AnyObject
                    fetchValue["image64"] = "" as AnyObject
                    
                }
            }
            else
            {
                
            }
            //save the context
            
            do {
                try context.save()
                print("saved!")
                var dict  = Constants.jsonStandard()
               // dict["id"] = chatId as AnyObject
               // NotificationCenter.default.post(name: Notification.Name("chatStatusUpdated"), object: nil , userInfo: fetchValue)//
            } catch let error as NSError  {
                print("Could not save \(error), \(error.userInfo)")
            }
            
            
            
        } catch {
            print("Error with request: \(error)")
        }
    }
    
    func updateImagefromMessageNew (url:String! , chatId:Int64) {
        
       // let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "ChatHistory")
        let context = self.contextNew.viewContext
       // fetchRequest.predicate = NSPredicate(format: "originalId == %d",chatId)
        let indexPath = IndexPath(item: 0, section: 0)
        ChatDBManager.chatIdForUpdate = chatId
        self.setUpFetchRequestCoreData()
        let obj = fetchedResultsController.object(at: indexPath)
        let chatObj = obj
        
        //chatObj.image64 = ""
        chatObj.message = url
        // here
        do {
            try context.save()
            
            //  print("Member Saved Sucessfully")
        } catch {
            //  print("Error in Saving Members")
        }
        
    }
    func updateImageRemoveBase64 (chatId:Int64) {
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "ChatHistory")
        let context = self.contextNew.viewContext
        fetchRequest.predicate = NSPredicate(format: "originalId == %d",chatId)
        
        var fetchValue = Constants.jsonStandard()
        
        do {
            
            let results = try context.fetch(fetchRequest)
            
            if results.count > 0
            {
                for result in results as! [NSManagedObject]
                {
                    
                    result.setValue("", forKey: "image64")
                    
                    let idd = result.value(forKey: "idd")
                    let originalId = result.value(forKey: "originalId")
                    let chatImage = result.value(forKey: "message")
                    let senderId = result.value(forKey: "senderId")
                    let lastmessage = result.value(forKey: "exchange")
                    let name = result.value(forKey: "timestamp")
                    let recieverId = result.value(forKey: "recieverId")
                    let status = result.value(forKey: "status")
                    let type = result.value(forKey: "type")
                    //let image64 = result.value(forKey: "image64")
                    
                    // Adding to Chat Object
                    fetchValue["id"] = idd as AnyObject
                    fetchValue["originalId"] = originalId as AnyObject
                    fetchValue["message"] = chatImage as AnyObject
                    fetchValue["sender_id"] = senderId as AnyObject
                    fetchValue["exchange"] = lastmessage as AnyObject
                    fetchValue["timestamp"] = name as AnyObject
                    fetchValue["receiver_id"] = recieverId as AnyObject
                    fetchValue["status"] = status as AnyObject
                    fetchValue["type"] = type as AnyObject
                    fetchValue["image64"] = "" as AnyObject
                    
                }
            }
            else
            {
                
            }
            //save the context
            
            do {
              //  try context.save()
                print("saved!")
                var dict  = Constants.jsonStandard()
                // dict["id"] = chatId as AnyObject
                // NotificationCenter.default.post(name: Notification.Name("chatStatusUpdated"), object: nil , userInfo: fetchValue)//
            } catch let error as NSError  {
                print("Could not save \(error), \(error.userInfo)")
            }
            
            
            
        } catch {
            print("Error with request: \(error)")
        }
    }
    func updateLastSeenStatusStatus (data:[Constants.jsonStandard] ) {
        for i in 0..<data.count
        {
            let obj = data[i] 
            let userId = obj["member_id"] as! String
            let lastSeen =  obj["last_seen_time"] as! String
            
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Members")
            let context = self.contextNew.viewContext
            fetchRequest.predicate = NSPredicate(format: "userId == %@",userId)
            
//            var fetchValue = Constants.jsonStandard()
            
            do {
                
                let results = try context.fetch(fetchRequest)
                
                if results.count > 0
                {
//                    if lastSeen != nil && !lastSeen.isEmpty
//                    {
                        for result in results as! [NSManagedObject]
                        {
                            result.setValue(lastSeen, forKey: "status")
                            do {
                                try context.save()
                                print("saved!")
                                
                            } catch let error as NSError  {
                                print("Could not save \(error), \(error.userInfo)")
                            }
                        }
                   // }
                    
                }
                
                //save the context
                
                
                
                
                
            } catch {
                print("Error with request: \(error)")
            }
        }
        
    }
    
    func updateIsBlockedStatusWithArray (data:[Constants.jsonStandard] )
    {
        for i in 0..<data.count
        {
            let obj = data[i]
            let userId = obj["member_id"] as! String
            let isblocked =  obj["last_seen_time"] as! String
            
            self.updateIsBlockedStatus(status: isblocked, userId: userId)
            
        }
        
    }
    func updateIsBlockedStatus (status : String! , userId : String! )
    {
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Members")
            let context = self.contextNew.viewContext
            fetchRequest.predicate = NSPredicate(format: "userId == %@",userId)
            
            do {
                
                let results = try context.fetch(fetchRequest)
                
                if results.count > 0
                {
                    
                    for result in results as! [NSManagedObject]
                    {
                        result.setValue(status, forKey: "isBlocked")
                        do {
                            try context.save()
                            print("saved!")
                            
                        } catch let error as NSError  {
                            print("Could not save \(error), \(error.userInfo)")
                        }
                    }
                    
                }
                
            } catch {
                print("Error with request: \(error)")
            }
        
        
    }
    
    func updateThreadWithName(name : String! , lastMessage : String!) ->Void{
        
       
        
        let context = self.contextNew.viewContext
        let request = NSFetchRequest<NSFetchRequestResult>(entityName : "ChatThreads")
        request.predicate = NSPredicate(format: "exchnage == %@",name)
        
        do
        {
            let results : Array? = try context.fetch(request)
            if (results?.count)! > 0
            {
                for result in results as! [NSManagedObject]
                {
                    result.setValue(lastMessage, forKey: "lastmessage")
                    do {
                        try context.save()
                        print("saved!")
                        
                    } catch let error as NSError  {
                        print("Could not save \(error), \(error.userInfo)")
                    }
                    
                }
            }
            
        }
        catch
        {
            print("Error in Feching The ChatThreads")
        }
        
        
        
    }
    
    //MARK:- Subscribe To RMQServer
    public  func closeConnection()
    {
        conn.close()
    }
    public  func subscribeToRabbitMQServer(exchangeName : String!, queueName :String!) -> Void
    {
        // binding queue with system exchange
        print("Attempting to connect to local RabbitMQ broker")
        print("Waiting for messages.")
        
        //conn = RMQConnection(uri: "amqp://chatuser:chatUser9078@msgs.rozee.pk:444/chat",delegate: RMQConnectionDelegateLogger())
        
       
        let recoveryInterval = 1
        
        conn = RMQConnection(uri: "amqp://chatuser:chatUser9078@msgs.rozee.pk:444/chat",
                                 tlsOptions: RMQTLSOptions.fromURI("amqp://chatuser:chatUser9078@msgs.rozee.pk:444/chat"),
                                 channelMax: RMQChannelLimit as NSNumber,
                                 frameMax: RMQFrameMax as NSNumber,
                                 heartbeat: 60,
                                 syncTimeout: 20,
                                 delegate: self,
                                 delegateQueue: DispatchQueue.main,
                                 recoverAfter: recoveryInterval as NSNumber,
                                 recoveryAttempts: 40000000,
                                 recoverFromConnectionClose: true)
        
        
        conn.start()
       
        let ch = conn.createChannel()
        //ch.confirmSelect()
        var arguDic:[String : RMQValue] = [String : RMQValue]()
        let mode = RMQLongstr("lazy")
        arguDic["x-queue-mode"] = mode
       // ch.basicQos(1, global: false)
        let q = ch.queue(queueName, options: .durable , arguments: arguDic as! [String : RMQValue & RMQFieldValue])
      
        let exchange = ch.direct(exchangeName, options: [.durable, .autoDelete]) // durable exchange even if sever restarts it continue with the previous state
        
       // let exchange = ch.fanout(exchangeName, options: [.durable, .autoDelete])
        
        q.bind(exchange, routingKey: q.name+"")
        
//        q .subscribe(manualAck, handler:{(_ message: RMQMessage) -> Void in
//
//            // Convert json string to dictionary
//            let strJson = String(data: message.body, encoding: String.Encoding.utf8)!
//            let dict = self.convertToDictionary(text: strJson)
//
//            self.addRecievedMessagesToDB(data: dict! as Constants.jsonStandard)
//
//        })
        
        // Addition of new parameter "manualAck" for manual aknowledgements
        let manualAck = RMQBasicConsumeOptions()
        q.subscribe(manualAck, handler: {(_ message: RMQMessage) -> Void in
            let strJson = String(data: message.body, encoding: String.Encoding.utf8)!
            let dict = self.convertToDictionary(text: strJson)
            
            self.addRecievedMessagesToDB(data: dict! as Constants.jsonStandard)
            //usleep(300000)
            ch.ack(message.deliveryTag)
        })
    }
    func sendMessageToExchange(exchangeName : String! , queue : String , message : String) -> Void
    {
        self.subscribeToExchangeWithName(exchangeName: exchangeName, queue: queue)
       // self.subscribeToExchangeWithName(exchangeName: exchangeName, queue: queue)
    //    self.subscribeToRabbitMQServer(exchangeName: exchangeName, queueName: queue)
        // send messages to theraed id
        let ch = conn.createChannel()
        
        //ch.confirmSelect()
        var arguDic:[String : RMQValue] = [String : RMQValue]()
        // let value = RMQSignedLonglong(900000)
        // arguDic["x-expires"] = value
        
        
//        ch.afterConfirmed { _,_ in
//            print("confirmed message")
//        }
        let mode = RMQLongstr("lazy")
        arguDic["x-queue-mode"] = mode
        let q = ch.queue(queue, options: .durable , arguments: arguDic as! [String : RMQValue & RMQFieldValue])
        let exchange = ch.fanout(exchangeName, options: [.durable, .autoDelete])
        q.bind(exchange, routingKey: q.name+"")
        _ = exchange.publish(message.data(using: .utf8), routingKey: q.name+"")
        
        
//        ch.afterConfirmed(5) { (acked, nacked) in
//            print("confirmed message \(message)")
//        }
       // print("Sent \(message)")
    }
    func convertToDictionary(text: String) -> [String: Any]? {
        if let data = text.data(using: .utf8) {
            do {
                return try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
            } catch {
                print(error.localizedDescription)
            }
        }
        return nil
    }
    func subscribeToExchangeWithName(exchangeName : String! , queue : String ) -> Void
    {
        // binding with user exchange
        // Error**
        //print("Attempting to connect to local RabbitMQ broker")
      //  print("Waiting for messages.")
        
        let ch = conn.createChannel()
        // let q = ch.queue(queue)
        // let exchange = ch.direct(exchangeName, options: [.durable , .autoDelete])
        var arguDic:[String : RMQValue] = [String : RMQValue]()
       // let value = RMQSignedLonglong(900000)
       // arguDic["x-expires"] = value
        
        let mode = RMQLongstr("lazy")
        arguDic["x-queue-mode"] = mode
        let q = ch.queue(queue, options: .durable , arguments: arguDic as! [String : RMQValue & RMQFieldValue])
        let exchange = ch.fanout(exchangeName, options: [.durable, .autoDelete])
        q.bind(exchange, routingKey: q.name+"")
 
        
        
    }
    func addRecievedMessagesToDB(data : Constants.jsonStandard) -> Void
    {
        
        let type = data["type"] as! String
        if type == "system"
        {
            let exchange = data["exchange"] as! String
            let queue = data["queue"] as! String
            let senderName = data["senderName"] as! String
            let senderImage = data["senderImage"] as! String
            self.subscribeToExchangeWithName(exchangeName: exchange, queue: queue)
            
            // data to insert in DB
            var tempThread = Constants.jsonStandard()
            tempThread["name"] = exchange as AnyObject
            tempThread["senderName"] = senderName as AnyObject
            tempThread["senderImage"] = senderImage as AnyObject
            tempThread["exchange"] = exchange as AnyObject
            tempThread["lastmessage"] = "" as AnyObject
            
            let thread  = ChatThreadModel(info: tempThread)
            
            var insertionArray = [ChatThreadModel]()
            insertionArray.append(thread)
           // self.saveThreadsInDataBase(data: insertionArray)
            
            // add member to DB
            let userId = data["userId"] as! String
            
            var tempMember = Constants.jsonStandard()
            tempMember["name"] = senderName as AnyObject
            tempMember["userId"] = userId as AnyObject
            tempMember["status"] = "" as AnyObject
            tempMember["name"] = senderName as AnyObject
            tempMember["exchange"] = exchange as AnyObject
            tempMember["senderImage"] = senderImage as AnyObject
            
            let member = ChatMemberObject (info: tempMember)
            var memArray = [ChatMemberObject]()
            memArray.append(member)
           // self.saveMembersInDataBase(data: memArray)
            
        }
       else  if type == "chat"
        {
             let subtype = data["subtype"] as! String
            if subtype == "message"
            {
                // add to DB if thread does not exist
                var chatHistory = data["chatHistory"] as! Constants.jsonStandard
                // data to insert in DB
                let exchange = data["exchange"] as! String
                let queue = myQueue!
                let senderName = data["senderName"] as! String
                let senderImage = data["senderImage"] as! String
                self.subscribeToExchangeWithName(exchangeName: exchange, queue: queue)
                
                
                var tempThread = Constants.jsonStandard()
                tempThread["name"] = exchange as AnyObject
                tempThread["senderName"] = senderName as AnyObject
                tempThread["senderImage"] = senderImage as AnyObject
                tempThread["exchange"] = exchange as AnyObject
                tempThread["lastmessage"] = chatHistory["message"] as AnyObject
                let thread  = ChatThreadModel(info: tempThread)
                
                var insertionArray = [ChatThreadModel]()
                insertionArray.append(thread)
                self.saveThreadsInDataBase(data: insertionArray)
                
                // add member to DB
                let userId = data["userId"] as! String
                
                var tempMember = Constants.jsonStandard()
                tempMember["name"] = senderName as AnyObject
                tempMember["userId"] = userId as AnyObject
                tempMember["status"] = "" as AnyObject
                tempMember["name"] = senderName as AnyObject
                tempMember["senderImage"] = senderImage as AnyObject
                tempMember["exchange"] = exchange as AnyObject
                
                let member = ChatMemberObject (info: tempMember)
                var memArray = [ChatMemberObject]()
                memArray.append(member)
                self.saveMembersInDataBase(data: memArray)
                
                //// process the message
                
               
                let senderID = chatHistory["sender_id"] as! String
                if senderID != UserDefaults.standard.value(forKey: Constants.kChatUserId) as? String
                {
                    print(chatHistory["message"] as! String)
                    chatHistory["id"] = ChatDBManager.ChatDBManagerSharedInstance.fetchTheNextIdFor(table: "ChatHistory") as AnyObject
                }
                let msgObj = ChatHistoryObject(info:chatHistory)
                var array = [ChatHistoryObject]()
               
                array.append(msgObj)
                
                msgObj.dbAction = "1"
                self.arrayChatQueue.append(msgObj)
                if(!self.isOurQueueInProcess){
                    
                    self.KeepReadingOurQueue()
                }
                
                
                self.sendDeliveryStatus(chatObj: msgObj)
                NotificationCenter.default.post(name: Notification.Name("updateThreadsScreen"), object: nil , userInfo: nil)
                
            }
            if subtype == "message_status"
            {
                let msgStatus = data["chatHistory"] as! Constants.jsonStandard
                let msgObj = ChatHistoryObject(info:msgStatus)
                if (msgObj.status == "failed")
                {
                    self.updateChatStatus(status: msgObj.status, chatId: msgObj.originalId)
                }
                else
                {
                    msgObj.dbAction = "2"
                    arrayChatQueue.append(msgObj)
                    if(!self.isOurQueueInProcess){
                        
                        self.KeepReadingOurQueue()
                    }
                    //self.updateChatStatusNew(status: msgObj.status, chatId: msgObj.originalId)
                }
                
                NotificationCenter.default.post(name: Notification.Name("systemNotificationGenerated"), object: nil , userInfo: data)
            }
            if subtype == "user_status"
            {
                let userId = data["userId"] as! String
                if userId != UserDefaults.standard.value(forKey: Constants.kChatUserId) as! String
                {
                    self.syncUserLastSeen(userId: userId)
                }
                NotificationCenter.default.post(name: Notification.Name("systemNotificationGenerated"), object: nil , userInfo: data)
            }
            if subtype == "typingStatus"
            {
                NotificationCenter.default.post(name: Notification.Name("systemNotificationGenerated"), object: nil , userInfo: data)
            }
            
            
        }
        else if type == "getInfo"
        {
            let subtype = data["subtype"] as! String
            if subtype == "user_status" {
                self.sendOnlineStatus(statusObj: data)
                let userId = data["userId"] as! String
                if userId != UserDefaults.standard.value(forKey: Constants.kChatUserId) as! String
                {
                    self.syncUserLastSeen(userId: userId)
                }
            }
            
        }
    }
    
    
    public  func UnsubscribeToRabbitMQServer() -> Void
    {
        // binding queue with system exchange
        //print("Attempting to connect to local RabbitMQ broker")
       // print("Waiting for messages.")
        
        
        // Beta Server
        conn = RMQConnection(uri: "amqp://chatuser:chatUser9078@msgs.rozee.pk:444/chat",delegate: RMQConnectionDelegateLogger())
        // conn = RMQConnection(uri: "amqp://chatuser:chatUser9078@msgs.rozee.pk:444/chat",delegate:self as? RMQConnectionDelegate)
        
        
        conn.start()
      //  let value = RMQConnectionConfig.Builder.setRequestedHeartbeat(4)
        //let heart = RMQHeartbeat()
    
        
        
        let ch = conn.createChannel()
        var arguDic:[String : RMQValue] = [String : RMQValue]()
        // let value = RMQSignedLonglong(900000)
        // arguDic["x-expires"] = value
        let mode = RMQLongstr("lazy")
        arguDic["x-queue-mode"] = mode
        let q = ch.queue("1_6LAJa", options: .durable , arguments: arguDic as! [String : RMQValue & RMQFieldValue])
        
      //  let exchange = ch.direct(exchangeName, options: [.durable, .autoDelete]) // durable exchange even if sever restarts it continue with the previous state
        
       // q.bind(exchange, routingKey: q.name+"")
        
        
        q .subscribe({(_ message: RMQMessage) -> Void in
           // print("Received \(String(data: message.body, encoding: String.Encoding.utf8)!)")
            
            
            // Convert json string to dictionary
            let strJson = String(data: message.body, encoding: String.Encoding.utf8)!
            let dict = self.convertToDictionary(text: strJson)
            
            self.addRecievedMessagesToDB(data: dict! as Constants.jsonStandard)
            
        })
    }
    
    // MARK:- RabbitMQ Delegates
    
    /// @brief Called when a socket cannot be opened, or when AMQP handshaking times out for some reason.
    public func connection(_ connection: RMQConnection!, failedToConnectWithError error: Error!)
    {
        print("\(error)")
       // self.subscribeToRabbitMQServer(exchangeName:"Users", queueName: self.myQueue)
        NotificationCenter.default.post(name: Notification.Name("connectionLost"), object: nil , userInfo: nil)
    }
    
    /// @brief Called when a connection disconnects for any reason
    public func connection(_ connection: RMQConnection!, disconnectedWithError error: Error!)
    {
        // connection disconnected
        print("\(error)")
        NotificationCenter.default.post(name: Notification.Name("connectionLost"), object: nil , userInfo: nil)
    }
    
    /// @brief Called before the configured <a href="http://www.rabbitmq.com/api-guide.html#recovery">automatic connection recovery</a> sleep.
    public func willStartRecovery(with connection: RMQConnection!)
    {
        print("\(connection)")
    }
    
    /// @brief Called after the configured <a href="http://www.rabbitmq.com/api-guide.html#recovery">automatic connection recovery</a> sleep.
    public func startingRecovery(with connection: RMQConnection!)
    {
        print("\(connection)")
    }
    
    /*!
     * @brief Called when <a href="http://www.rabbitmq.com/api-guide.html#recovery">automatic connection recovery</a> has succeeded.
     * @param RMQConnection the connection instance that was recovered.
     */
    public func recoveredConnection(_ connection: RMQConnection!)
    {
//        self.subscribeToRabbitMQServer(exchangeName: ""  , queueName: "" )
        print("\(connection)")
        NotificationCenter.default.post(name: Notification.Name("connectionCreatedSuccessfully"), object: nil , userInfo: nil)
        self.fetchSendingMsgsAndResend()
    }
    func channel(_ channel: RMQChannel!, error: Error!) {
        print("\(error)")
    }
    
    //MARK:- Api Calls
    func apiCallForUploadImaget(imageData : String! , tag : Int) -> Void
    {
        // self.view.addSubview(activityVC.view)
        
        let url:String = Constants.baseUrl+ApiLinks.uploadChatImage
        var params:Constants.dictionaryStandard = Constants.dictionaryStandard()
        let header = [String : String]()
        
        params["image"] = imageData
        
        NotificationCenter.default.addObserver(self, selector: #selector(CallBackFromUploadImage(notification:)), name: Notification.Name("SpecialCallForImageUpload"), object: nil)
        
       // let obj = NetworkCalls(link:url , notificationName:ApiLinks.uploadChatImage, params:params , header:header , addUSerID:true)
        let obj = NetworkCalls.init(link: url, notificationName: "SpecialCallForImageUpload", params: params, header: header, addUSerID: true, arrayTag: tag)
        obj.postAPICall()
    }
    
    @objc func CallBackFromUploadImage(notification:NSNotification) -> Void
    {
        // activityVC.view.removeFromSuperview()
        
        if(notification.name == Notification.Name("SpecialCallForImageUpload"))
        {
            let apiData = notification.userInfo as! Constants.jsonStandard
            let response = apiData["response"] as! Constants.jsonStandard
            let tag = apiData["tag"] as! Int
            print("\(apiData)")
            let code = response["code"] as! String
            if code == "11"
            {
                let url = response["message"] as! String
                
                self.fetchMsgObjFromLocalArray(tag: tag, url: url)
                
            }
            else
            {
               // let msg = response["msg"] as! String
              //  showAlert(msg: msg)
            }
            
        }
        
        // Removing the Observer
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue:"SpecialCallForImageUpload"), object: nil)
    }
}
