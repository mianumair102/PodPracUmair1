    //
//  ChattingViewController.swift
//  EventsApp
//
//  Created by Janbaz Ali on 7/10/17.
//  Copyright © 2017 Janbaz Ali. All rights reserved.
//

import UIKit
import RMQClient
import CoreData
    extension NSCalendar {
        func daysWithinEraFromDate(startDate: NSDate, toDate endDate: NSDate) -> NSInteger {
            let startDay = self.ordinality(of: .day, in: .era, for: startDate as Date)
            let endDay = self.ordinality(of: .day, in: .era, for: endDate as Date)
            return endDay - startDay
        }
    }
    
    
class ChatMessageTableCell: UITableViewCell
{
    @IBOutlet var lblmessage: UILabel!
    @IBOutlet weak var imgPointer: UIImageView!
    @IBOutlet weak var imgUser: RozeeUIButton!
    @IBOutlet weak var lblDate: UILabel!
    @IBOutlet weak var lblTopDate: UILabel!
    
}
class MyMessageTableCell: UITableViewCell
{
    @IBOutlet var lblmessage: UILabel!
    @IBOutlet weak var imgStatus: UIImageView!
    @IBOutlet weak var imgPointer: UIImageView!
    @IBOutlet weak var btnRetry: UIButton!
    @IBOutlet weak var lblDate: UILabel!
    @IBOutlet weak var lblTopDate: UILabel!
    
        
}
class MyImageTableCell: UITableViewCell
{
    @IBOutlet weak var imgPhoto: RozeeUIImageView!
    @IBOutlet weak var imgPointer: UIImageView!
    @IBOutlet weak var imgStatus: UIImageView!
    @IBOutlet weak var btnRetry: UIButton!
    @IBOutlet weak var lblDate: UILabel!
    @IBOutlet weak var lblTopDate: UILabel!

}
class SenderImageTableCell: UITableViewCell
{
    @IBOutlet weak var imgPhoto: RozeeUIImageView!
    @IBOutlet weak var imgPointer: UIImageView!
    @IBOutlet weak var imgUser: RozeeUIButton!
    @IBOutlet weak var lblDate: UILabel!
    @IBOutlet weak var lblTopDate: UILabel!
    @IBOutlet weak var btnFullImg: UIButton!
}
    
    
class ChattingViewController: UIViewController,UITextFieldDelegate, UITableViewDelegate, UITableViewDataSource, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextViewDelegate,NSFetchedResultsControllerDelegate
{
    @IBOutlet weak var imgUserTop: RozeeUIButton!
    @IBOutlet var tblChat: UITableView!
    @IBOutlet weak var lblUserName: UILabel!
    @IBOutlet weak var lblUserOnlineStatus: UILabel!
    @IBOutlet weak var constHeightLblConnectionStatus: NSLayoutConstraint!
    @IBOutlet weak var lblConnectionStatus: UILabel!
    var picker = UIImagePickerController()
    var aNotfictn : NSNotification!
    var doIt : Bool!
    var recipientId : String!
    var isPartnerTying: String!
    var connection:RMQConnection!
    var activityVC : ActivityViewController!
    var arrayChat : NSMutableArray!
    var exchangename : String?
    var queueForChat : String?
    var indexesArray = NSMutableArray()
    var recieverName : String!
    var recieverImage : String!
    var timer1 : Timer!
    var timeAtPress = Date()
    var lastmsgTime = Date()
    var onceOnline = false
    var compressedImgData : String!
    var curImgRow = -1;
    
    @IBOutlet var viewForText: UIView!
    @IBOutlet var txtfield: UITextView!
    let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tapBlurButton))
    
    var cellheight  = CGFloat(44)
    
    // special variables for pagination
    var lastScrollPostionY = 0.0
    var  point : CGPoint!
    var isDataLoading = false
    var totalCount = 0
    var start = 0
    // special variables for pagination end
    
    var imggggg : UIImage!
    //MARK:- LifeCycle
    var timer = Timer()
    
   // private let persistentContainer = NSPersistentContainer(name: "ChatDBModel")
    
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        self.constHeightLblConnectionStatus.constant = 0
//        exchangename = "1_6LADc_xD9Gsi4oEK"
//        recipientId = "6LAJa" //"6LADc"
        
        isPartnerTying = "N"
         point = CGPoint.init(x: 0, y: 0)
         self.view.backgroundColor = UIColor(patternImage: UIImage(named: "bg2.jpg")!)
        if self.recieverImage == nil
        {
            self.recieverImage = ""
        }
        picker.delegate = self
        doIt = true
        tblChat.estimatedRowHeight = 55
        tblChat.rowHeight = UITableViewAutomaticDimension
        queueForChat = ChatDBManager.ChatDBManagerSharedInstance.myQueue!
        
        NotificationCenter.default.addObserver(self, selector: #selector(callBackFromSystemMsg(notification:)), name: Notification.Name("systemNotificationGenerated"), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(callBackFromPostAnswer(notification:)), name: Notification.Name("chatnotification"), object: nil)
         NotificationCenter.default.addObserver(self, selector: #selector(notificationForStatusUpdate(notification:)), name: Notification.Name("chatStatusUpdated"), object: nil)
        
      //  connection = RMQConnection(uri: "amqp://chatuser:chatUser9078@msgs.rozee.pk:444/chat",delegate: RMQConnectionDelegateLogger())
     //   connection.start()
        
        self.arrayChat = NSMutableArray()
        
        let storyboard = UIStoryboard(name: "Chatting", bundle: nil)
        activityVC  = storyboard.instantiateViewController(withIdentifier: "ActivityViewController") as! ActivityViewController
        tapGesture.addTarget(self, action: #selector(tapBlurButton))
        tapGesture.numberOfTapsRequired = 1
        self.tblChat.addGestureRecognizer(tapGesture)
        
        self.setupTextView()
        
        if self.exchangename == nil || self.queueForChat == nil || (self.exchangename?.isEmpty)! || (self.queueForChat?.isEmpty)!{
            if self.checkIdUserBlocked()
            {
            }
            else
            {
                self.apiCallForStartChat()
            }
            
        }
        else
        {
            if self.checkIdUserBlocked()
            {
            }
            else
            {
                self.subscribeToExchangeWithName(exchangeName: exchangename, queue: queueForChat!)
            }
                self.setUpFetchRequestCoreData()
                self.fetchMessagesFromDB(exchange: self.exchangename)
             //   self.fetchOnlySendingMsgs()
                self.fetchOnlyDeliveredMsgs()
                self.lblUserName.text = self.recieverName;
                self.fetchMemDetails()
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillBeHidden), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        
        self.addNotificationsForConnection()
    }
    override func viewDidAppear(_ animated: Bool)
    {
        super.viewWillAppear(true)
        if self.checkIdUserBlocked()
        {
        }
        else
        {
            timer = Timer.scheduledTimer(timeInterval: 5, target: self, selector: #selector(getUserStatus), userInfo: nil, repeats: true)
        }
        
    }
    override func viewDidDisappear(_ animated: Bool) {
        timer.invalidate()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
       // txtfield.resignFirstResponder()
    }
    
   

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        self.txtfield.removeObserver(self, forKeyPath: "contentSize")
         NotificationCenter.default.removeObserver(self)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "systemNotificationGenerated"), object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "chatnotification"), object: nil)
        
    }
//
//    func addToolBar()
//    {
//        
//        
//        //Fixed space
//        let fixed = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.fixedSpace, target: self, action: nil)
//        fixed.width = 10
//        
//        //Text
//        let text = UIBarButtonItem(title: "My Title", style: UIBarButtonItemStyle.plain, target: self, action: nil)
//        text.setTitleTextAttributes([
//            NSFontAttributeName : UIFont.systemFont(ofSize: 23.0),
//            NSForegroundColorAttributeName : UIColor.white], for: UIControlState.normal)
//        
//        //TextField
//        let  textField = UITextField(frame:CGRect(x: 0, y: 0, width: 150, height: 30))
//        textField.delegate = self
//        textField.textColor = UIColor.blue
//        let border = CALayer()
//        let width : CGFloat = 2.0
//        border.borderColor = UIColor.white.cgColor
//        // border.frame = CGRectMake(0, textField.frame.size.height-width, textField.frame.size.width, textField.frame.size.height)
//        border.frame = CGRect(x: 0, y: textField.frame.size.height-width, width: textField.frame.size.width, height: textField.frame.size.height)
//        border.borderWidth = width
//        textField.layer.addSublayer(border)
//        textField.layer.masksToBounds = true
//        let textFieldButton = UIBarButtonItem(customView: textField)
//        
//        //Search Button
//        let search = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.search, target: self, action: nil)
//        
//        
//        //Toolbar
//        let toolbar = UIToolbar(frame: CGRect(x: 0, y: view.frame.height-50, width: view.frame.width, height: 50))
//        toolbar.sizeToFit()
//        toolbar.barTintColor = UIColor.orange
//        toolbar.isTranslucent = false
//        toolbar.tintColor = UIColor.white
//        toolbar.items = [fixed, text, fixed, textFieldButton, search]
//       // view.addSubview(toolbar)
//        txtfield.inputAccessoryView = toolbar
//    }
//    func donePressed()
//    {
//        view.endEditing(true)
//    }
//    func cancelPressed(){
//        view.endEditing(true) // or do something
//    }
    
    
    // MARK: - Methods to Fetch data from CoreData
    func setUpFetchRequestCoreData() -> Void
    {
        
        
        if ChatDBManager.ChatDBManagerSharedInstance.isPresistanceOfChatLoaded
        {
            
            do {
                try self.fetchedResultsController.performFetch()
            } catch {
                let fetchError = error as NSError
              //  print("Unable to Perform Fetch Request")
              //  print("\(fetchError), \(fetchError.localizedDescription)")
            }
            
        }
        else
        {
            ChatDBManager.ChatDBManagerSharedInstance.contextNew.loadPersistentStores { (persistentStoreDescription, error) in
                if let error = error {
                   // print("Unable to Load Persistent Store")
                  //  print("\(error), \(error.localizedDescription)")
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
                    
                    // self.updateView()
                }
            }
        }
        
    }

    fileprivate lazy var fetchedResultsController: NSFetchedResultsController<ChatHistory> = {
        // Create Fetch Request
        var fetchRequest: NSFetchRequest<ChatHistory> = ChatHistory.fetchRequest()
        
        // Configure Fetch Predicate
        let  predicate = NSPredicate(format: "exchange == %@",self.exchangename!)
        fetchRequest.predicate = predicate
        
        // Configure Fetch Request
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "idd", ascending: true)]
        
        // Create Fetched Results Controller
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: ChatDBManager.ChatDBManagerSharedInstance.contextNew.viewContext, sectionNameKeyPath: nil, cacheName: nil)
        
        // Configure Fetched Results Controller
        fetchedResultsController.delegate = self
        
        return fetchedResultsController
    }()
    
    //MARK:- My Functions
    @objc func tapBlurButton(sender: UITapGestureRecognizer) {
        
        txtfield.resignFirstResponder()
    }
    
    func setupTextView() {
        
            txtfield.scrollsToTop = false;
            txtfield.backgroundColor = UIColor.white;
            txtfield.isScrollEnabled = true;
            txtfield.addObserver(self, forKeyPath: "contentSize", options:[ NSKeyValueObservingOptions.old , NSKeyValueObservingOptions.new], context: nil)
        
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        
        if let changeDict = change, let view = self.txtfield {
            if object as? NSObject == self.txtfield && keyPath == "contentSize" {
                if let oldContentSize = (changeDict[NSKeyValueChangeKey.oldKey] as AnyObject).cgSizeValue,
                    let newContentSize = (changeDict[NSKeyValueChangeKey.newKey] as AnyObject).cgSizeValue {
                    
                    if newContentSize.height < 200 {
                        let dy = newContentSize.height - oldContentSize.height
                        var aRect: CGRect = viewForText.frame
                        if dy > 0 {
                            
                             aRect.size.height = newContentSize.height + 16
                            
                        }
                        else
                        {
                            if newContentSize.height > 45 {
                                aRect.size.height = newContentSize.height
                            }
                            
                        }
                       if newContentSize.height > 45 {
                        aRect.origin.y = aRect.origin.y - dy
                        }
                        
                        viewForText.frame = aRect
                        self.view.layoutIfNeeded()
                        let contentOffsetToShowLastLine = CGPoint(x: 0.0, y: view.contentSize.height - view.bounds.height)
                        view.contentOffset = contentOffsetToShowLastLine
                        self.changetableViewScroll()
                    }
                }
            }
        }
    }
    
    func fetchMessagesFromDB(exchange: String!) -> Void {
       let array =  ChatDBManager.ChatDBManagerSharedInstance.fetchChatMessages(threadId: exchangename)
        arrayChat.addObjects(from: array)
        tblChat.reloadData()
        if arrayChat.count > 0 {
            self.scrollToBottom()
        }
    }
    func  fetchOnlyDeliveredMsgs() -> Void {
       let arrayMsgs = ChatDBManager.ChatDBManagerSharedInstance.fetchAllDelivereChatMsgs(exchange: exchangename, status: "delivered")
        
        for  i in 0..<arrayMsgs.count
        {
            if DataManager.dataManagerSharedInstance.isInternetAvailable() {
                let  msgObj = arrayMsgs[i]
                let senderId = msgObj.senderId
                
                if senderId != UserDefaults.standard.value(forKey: Constants.kChatUserId) as? String
                {
                    ChatDBManager.ChatDBManagerSharedInstance.sendDeliveryStatus(chatObj: msgObj)
                }
                
            }
          
        }
    }
    func  fetchOnlySendingMsgs() -> Void {
        let arrayMsgs = ChatDBManager.ChatDBManagerSharedInstance.fetchAllChatMsgsWithStatus(exchange: exchangename, status: "sending")
        for  i in 0..<arrayMsgs.count
        {
            let  msgObj = arrayMsgs[i]
            let senderId = msgObj.senderId
                
            if senderId == UserDefaults.standard.value(forKey: Constants.kChatUserId) as? String
            {
                ChatDBManager.ChatDBManagerSharedInstance.updateChatSendingStatusToFailed(status: msgObj.status, chatId: msgObj.idd)
            }
            
        }
    }

    func retrySendingMessage(tag : Int, url : String!)
    {
        let indexPath = IndexPath(item: tag, section: 0)
        let msgObjFetchReq = fetchedResultsController.object(at: indexPath)
        let msgObj = ChatHistoryObject.init(data: msgObjFetchReq)
        var dic = Constants.jsonStandard()
        dic["type"] = "chat" as AnyObject
        dic["subtype"] = "message" as AnyObject
        dic["application_name"] = "Evento" as AnyObject
        dic["exchange"] = self.exchangename as AnyObject
        dic["senderNumber"] = "988347928429" as AnyObject
        dic["queue"] = self.queueForChat as AnyObject
        dic["senderName"] = "\(SingletonClassOfObjects.SharedInstance.userObject.first_name!) \(SingletonClassOfObjects.SharedInstance.userObject.last_name!)"  as AnyObject
        dic["senderImage"] = SingletonClassOfObjects.SharedInstance.userObject.image_name as AnyObject
        dic["userId"] = UserDefaults.standard.value(forKey: Constants.kChatUserId) as AnyObject
        
        var chat = Constants.jsonStandard()
        chat["id"] = msgObj.idd as AnyObject
        chat["originalId"] = msgObj.originalId as AnyObject
        chat["message"] = msgObj.message as AnyObject
        if url.isEmpty {
            chat["message"] = msgObj.message as AnyObject
        }
        else
        {
            chat["message"] = url as AnyObject
        }
        chat["sender_id"] = msgObj.senderId as AnyObject
        chat["exchange"] = msgObj.exchange as AnyObject
        chat["timestamp"] = msgObj.chattimestamp as AnyObject
        chat["receiver_id"] = msgObj.recieverId as AnyObject
        chat["status"] = msgObj.status as AnyObject
        chat["type"] = msgObj.type as AnyObject
        
        if DataManager.dataManagerSharedInstance.isInternetAvailable()
        {
            chat["status"] = "sending" as AnyObject
            // update msgs status locally
            if (msgObj.status == "failed" ) {
                msgObj.dbAction = "2"
                ChatDBManager.ChatDBManagerSharedInstance.arrayChatQueue.append(msgObj)
                if(!ChatDBManager.ChatDBManagerSharedInstance.isOurQueueInProcess){
                    
                    ChatDBManager.ChatDBManagerSharedInstance.KeepReadingOurQueue()
                }
            }
        }
        else
        {
            chat["status"] = "failed" as AnyObject
        }
        
        if msgObj.type == "image"
        {
            
            if url.isEmpty || url == nil
            {
                self.apiCallForUploadImaget(imageData: msgObj.image64, tag: tag)
                return
            }
            chat["image64"] = msgObj.image64 as AnyObject
            chat["message"] = url as AnyObject
        }
        chat["env"] = "dev" as AnyObject
        dic["chatHistory"] = chat as AnyObject
        
        var msg = ""
        do {
            let data = try JSONSerialization.data(withJSONObject:dic, options:[])
            msg = String(data: data, encoding: String.Encoding.utf8)!
            
        } catch {
            print("JSON serialization failed:  \(error)")
        }
        
        txtfield.text = ""
        self.setFrameForTextAfterSendingMsg()
       
        // send msg with blured image
        
        ChatDBManager.ChatDBManagerSharedInstance.sendMessageToExchange(exchangeName: exchangename, queue: queueForChat!, message: msg)
        
        
        // save the data in local db with original image
        
        if msgObj.type == "image"
        {
            chat["image64"] = msgObj.image64 as AnyObject
            chat["message"] = url as AnyObject
        }
        let msgObj1 = ChatHistoryObject(info:chat)

        if msgObj.type == "image"
        {
            ChatDBManager.ChatDBManagerSharedInstance.updateImagefromMessageNew(url: msgObj1.message, chatId: msgObj1.originalId)
        }
        
    }
    func changeTypingStatus() -> Void {
        
            DispatchQueue.main.sync(execute: {
                () -> Void in
                if isPartnerTying == "Y"
                {
                    self.lblUserOnlineStatus.text = "typing..."
                }
                else
                {
                    self.getUserStatus()
                }
                
            })
    }
    @objc func getUserStatus()
    {
        if isPartnerTying == "Y"
        {

        }
        else if self.checkIdUserBlocked()
        {
        }
        else
        {
            let elapsed = lastmsgTime.timeIntervalSince(timeAtPress)
            lastmsgTime = Date()
            let duration = Int(elapsed)
            if onceOnline {
                if duration > 7 {
                    //lblUserOnlineStatus.text = "offline"
                    self.fetchMemDetails()
                }
                else
                {
                    lblUserOnlineStatus.text = "online"
                }
            }



            var msg = ""
            var dic = Constants.jsonStandard()
            dic["type"] = "getInfo" as AnyObject
            dic["subtype"] = "user_status" as AnyObject
            dic["exchange"] = exchangename as AnyObject
            dic["userId"] = UserDefaults.standard.value(forKey: Constants.kChatUserId) as AnyObject

            do {
                let data = try JSONSerialization.data(withJSONObject:dic, options:[])
                msg = String(data: data, encoding: String.Encoding.utf8)!
                // print(msg)

            } catch {
                print("JSON serialization failed:  \(error)")
            }

            ChatDBManager.ChatDBManagerSharedInstance.sendMessageToExchange(exchangeName: exchangename, queue: queueForChat!, message: msg)
        }
        
    }
    
    func fetchMemDetails() -> Void {
        let array = ChatDBManager.ChatDBManagerSharedInstance.fetchMemberWithUserId(userId: recipientId)
        if array.count > 0 {
            let mem = array[0]
            
            
            if let strTime = Double(mem.status)
            {
                let date = NSDate(timeIntervalSince1970: TimeInterval(strTime))
                let dateFormatter = DateFormatter()
                dateFormatter.timeStyle = DateFormatter.Style.medium //Set time style
                dateFormatter.dateStyle = DateFormatter.Style.medium //Set date style
                dateFormatter.timeZone = TimeZone.current
                dateFormatter.dateFormat = "dd MMM yyyy-h:mm:a"
                var localDate = dateFormatter.string(from: date as Date)
                let arrT = localDate.components(separatedBy: "-")
                
                var differenceFromCurDate = 0
                let calendar = Calendar.current as NSCalendar
                let curD = Date() as NSDate
                differenceFromCurDate = calendar.daysWithinEraFromDate(startDate: date, toDate: curD)
                if differenceFromCurDate == 0 {
                    localDate = "today at \(arrT[1])"
                }
                else if differenceFromCurDate == 0 {
                    localDate = "yesterday at \(arrT[1])"
                }
                else
                {
                    localDate = "\(arrT[0]) at \(arrT[1])"
                }
                
                lblUserOnlineStatus.text = "last seen \(localDate)"
                
                
            }
            
            else
            {
                lblUserOnlineStatus.text = "offline"
            }
            
            
            if mem.name == nil || mem.name.isEmpty
            {
                lblUserName.text = self.recieverName
            }
            else
            {
                lblUserName.text = mem.name
            }
            if mem.senderImage == nil || mem.senderImage.isEmpty
            {
                
            }
            else
            {
                self.recieverImage = mem.senderImage
            }
            
            
            let url = URL(string: self.recieverImage)
            let  image = UIImage(named : "user_profile_bg.png")
            
            imgUserTop.sd_setBackgroundImage(with: url, for: UIControlState.normal, placeholderImage: image)
            
            
        }
    }
    
    func blockThisUser()
    {
        self.apiCallForBlockUser()
    }
    
    func verifyUrl (urlString: String?) -> Bool {
        //Check for nil
        if let urlString = urlString {
            // create NSURL instance
            if let url = NSURL(string: urlString) {
                // check if your application can open the NSURL instance
                return UIApplication.shared.canOpenURL(url as URL)
            }
        }
        return false
    }
    
    func checkIdUserBlocked() -> Bool {
        for i in 0..<SingletonClassOfObjects.SharedInstance.blockedUsersArray.count
        {
            //
            let user = SingletonClassOfObjects.SharedInstance.blockedUsersArray[i] as! Constants.jsonStandard
            let usersId = user["member_id"] as! String
            if usersId == recipientId {
                return true
                
            }
        }
        return false
    }
    func unblockUserLcally() {
        for i in 0..<SingletonClassOfObjects.SharedInstance.blockedUsersArray.count
        {
            //
            let user = SingletonClassOfObjects.SharedInstance.blockedUsersArray[i] as! Constants.jsonStandard
            let usersId = user["member_id"] as! String
            if usersId == recipientId {
                SingletonClassOfObjects.SharedInstance.blockedUsersArray.removeObject(at: i)
                timer = Timer()
                timer = Timer.scheduledTimer(timeInterval: 5, target: self, selector: #selector(getUserStatus), userInfo: nil, repeats: true)
                break
            }
        }
        
    }
    func blockUserLcally()
    {
        var dict = Constants.jsonStandard()
        dict["is_blocked"] = "Y" as AnyObject
        dict["member_id"] = recipientId! as AnyObject
       SingletonClassOfObjects.SharedInstance.blockedUsersArray.add(dict)
        timer.invalidate()
    }
    func addNotificationsForConnection() -> Void {
        NotificationCenter.default.addObserver(self, selector: #selector(connectionCreatedSuccessfully(notification:)), name: Notification.Name("connectionCreatedSuccessfully"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(connectionLost(notification:)), name: Notification.Name("connectionLost"), object: nil)
    }
    // MARK:- Alert
    
    func showAlert(msg: String) -> Void {
        let alert = UIAlertController(title: "Rozee", message: msg, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    func  sendTyingStatus(isTyping : String!) -> Void {
         var dic = Constants.jsonStandard()
        dic["type"] = "chat" as AnyObject
        dic["subtype"] = "typingStatus" as AnyObject
        dic["application_name"] = "Evento" as AnyObject
        dic["exchange"] = self.exchangename as AnyObject
        dic["senderNumber"] = "988347928429" as AnyObject
        dic["queue"] = self.queueForChat as AnyObject
        dic["senderName"] = "\(SingletonClassOfObjects.SharedInstance.userObject.first_name!) \(SingletonClassOfObjects.SharedInstance.userObject.last_name!)"  as AnyObject
        dic["senderImage"] = SingletonClassOfObjects.SharedInstance.userObject.image_name! as AnyObject
        dic["userId"] = UserDefaults.standard.value(forKey: Constants.kChatUserId) as AnyObject
        
        var typingData = Constants.jsonStandard()
        typingData["isTyping"] = isTyping as AnyObject
        dic["typingData"] = typingData as AnyObject
        
        var msg = ""
        do {
            let data = try JSONSerialization.data(withJSONObject:dic, options:[])
            msg = String(data: data, encoding: String.Encoding.utf8)!
            
        }catch {
            print("JSON serialization failed:  \(error)")
            
        }
  ChatDBManager.ChatDBManagerSharedInstance.sendMessageToExchange(exchangeName: self.exchangename, queue: queueForChat!, message: msg)
        
        
    }
   
    
    
    //MARK:- Textfiled Delegate
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool
    {
        if (!text.isEmpty)
        {
         if (txtfield.text.characters.count) == 0
         {
                self.sendTyingStatus(isTyping: "Y")
         }
         
        }
        else
        {
            if (txtfield.text.characters.count) > 1
            {
                
            }
            else
            {
                self.sendTyingStatus(isTyping: "N")
            }
        }
        
        return true
    }
    
    // MARK:- Managing Keyboard
    
    @objc  func keyboardWillBeHidden(aNotification: NSNotification)
    {
        if txtfield.text.isEmpty {
            txtfield.text = "Type a message"
            txtfield.textColor = UIColor.darkGray
            self.sendTyingStatus(isTyping: "N")
        }
        doIt = true
        let contentInsets: UIEdgeInsets = UIEdgeInsets.zero;
        self.tblChat.contentInset = contentInsets
        self.tblChat.scrollIndicatorInsets = contentInsets
        
        var aRect: CGRect = viewForText.frame
        aRect.origin.y = self.view.frame.size.height -  viewForText.frame.size.height
        viewForText.frame = aRect
    }
    @objc  func keyboardWillShow(aNotification: NSNotification)
    {
        if txtfield.text == "Type a message" {
            txtfield.text = ""
            txtfield.textColor = UIColor.black
        }
        if doIt == true {
            doIt = false
            aNotfictn = aNotification
            var info = aNotification.userInfo!
            let kbSize = ((info[UIKeyboardFrameEndUserInfoKey] as AnyObject).cgRectValue.size)
            let contentInsets: UIEdgeInsets = UIEdgeInsetsMake(0.0, 0.0, kbSize.height , 0.0)
            tblChat.contentInset = contentInsets
            tblChat.scrollIndicatorInsets = contentInsets
            self.view.bringSubview(toFront: viewForText)
            var aRect: CGRect = viewForText.frame
            aRect.origin.y = aRect.origin.y - kbSize.height
            viewForText.frame = aRect
        }
        
    }
    func changetableViewScroll() -> Void {
        if aNotfictn != nil
        {
            var info = aNotfictn.userInfo!
            let kbSize = ((info[UIKeyboardFrameEndUserInfoKey] as AnyObject).cgRectValue.size)
            let contentInsets: UIEdgeInsets = UIEdgeInsetsMake(0.0, 0.0, (kbSize.height + viewForText.frame.size.height - 45), 0.0)
            tblChat.contentInset = contentInsets
            tblChat.scrollIndicatorInsets = contentInsets
        }
        
    }
    func setFrameForTextAfterSendingMsg() -> Void {
        
        if viewForText.frame.size.height > 45
        {
            var aRect: CGRect = viewForText.frame
            aRect.origin.y = aRect.origin.y + (aRect.size.height - 45)
            aRect.size.height = 45
            viewForText.frame = aRect
        }
    }

    //MARK:- IBActions
    @IBAction func backBtnAction(_ sender: Any)
    {
        let when = DispatchTime.now() + 10
        DispatchQueue.main.asyncAfter(deadline: when){
            // ChatDBManager.ChatDBManagerSharedInstance.fetchSendingMsgsAndMarkFailed()
        }
        _=self.navigationController?.popViewController(animated: true)
    }
    @IBAction func btnSendAction(_ sender: UIButton)
    {
       
        if self.checkIdUserBlocked()
        {
            let alert = UIAlertController(title: "Unblock this user to chat", message: nil, preferredStyle: .actionSheet)
            alert.addAction(UIAlertAction(title: "Unblock", style: .default) { action in
                self.apiCallForunblockUser()
            })
            alert.addAction(UIAlertAction(title: "Cancel", style: .default) { action in
                // self.cancelAction()
            })
            
            self.present(alert, animated: true, completion: nil)
        }
        else
        {
          //  for i in 0..<50 {
            
                let strtext = txtfield.text.trimmingCharacters(in: .whitespacesAndNewlines)
                if strtext.isEmpty || txtfield.text == "Type a message" {
                    return
                }
                else
                {
                    var msg = txtfield.text!
                    var dic = Constants.jsonStandard()
                    
                    let date = Date()
                    let timeInterval = date.timeIntervalSince1970
                    let timeInLongInt : Int = Int(timeInterval)
                    
                    dic["type"] = "chat" as AnyObject
                    dic["subtype"] = "message" as AnyObject
                    dic["application_name"] = "Evento" as AnyObject
                    dic["exchange"] = self.exchangename as AnyObject
                    dic["senderNumber"] = "988347928429" as AnyObject
                    dic["queue"] = self.queueForChat as AnyObject
                    dic["senderName"] = "\(SingletonClassOfObjects.SharedInstance.userObject.first_name!) \(SingletonClassOfObjects.SharedInstance.userObject.last_name!)"  as AnyObject
                    dic["senderImage"] = SingletonClassOfObjects.SharedInstance.userObject.image_name! as AnyObject
                    dic["userId"] = UserDefaults.standard.value(forKey: Constants.kChatUserId) as AnyObject
                    
                    var chat = Constants.jsonStandard()
                    chat["exchange"] = self.exchangename as AnyObject
                    chat["timestamp"] = "\(timeInLongInt)" as AnyObject
                    chat["message"] = msg as AnyObject
                    //chat["message"] = "msg \(i)" as AnyObject
                    chat["receiver_id"] = self.recipientId as AnyObject
                    chat["sender_id"] = UserDefaults.standard.value(forKey: Constants.kChatUserId) as AnyObject
                    chat["id"] = ChatDBManager.ChatDBManagerSharedInstance.fetchTheNextIdFor(table: "ChatHistory") as AnyObject
                    chat["originalId"] = ChatDBManager.ChatDBManagerSharedInstance.fetchTheNextIdFor(table: "ChatHistory") as AnyObject
                    chat["type"] = "message" as AnyObject
                    if DataManager.dataManagerSharedInstance.isInternetAvailable()
                    {
                        chat["status"] = "sending" as AnyObject
                    }
                    else
                    {
                        chat["status"] = "failed" as AnyObject
                    }
                     chat["env"] = "dev" as AnyObject
                    dic["chatHistory"] = chat as AnyObject
                    
                    
                    let msgObj = ChatHistoryObject(info:chat)
                    
                    do {
                        let data = try JSONSerialization.data(withJSONObject:dic, options:[])
                        msg = String(data: data, encoding: String.Encoding.utf8)!
                        
                    } catch {
                        print("JSON serialization failed:  \(error)")
                    }
                    
                    txtfield.text = ""
                    self.setFrameForTextAfterSendingMsg()
                    self.changetableViewScroll()
                    if arrayChat.count > 0
                    {
                        self.scrollToBottom()
                    }
                    
                    self.sendTyingStatus(isTyping: "N")
                    
                    var array = [ChatHistoryObject]()
                    array.append(msgObj)
                    //ChatDBManager.ChatDBManagerSharedInstance.saveChatMessagesInDataBaseNew(data: array, chatData: nil)
                    msgObj.dbAction = "1"
                    ChatDBManager.ChatDBManagerSharedInstance.arrayChatQueue.append(msgObj)
                    if(!ChatDBManager.ChatDBManagerSharedInstance.isOurQueueInProcess){
                        ChatDBManager.ChatDBManagerSharedInstance.KeepReadingOurQueue()
                    }
                    
                    ChatDBManager.ChatDBManagerSharedInstance.sendMessageToExchange(exchangeName: exchangename, queue: queueForChat!, message: msg)
                    
                    usleep(300000)
                }
           // }
        }
        
    }
    
//    func sendmessageToRabbit(array : [ChatHistoryObject], msg : String!) -> Void {
//        ChatDBManager.ChatDBManagerSharedInstance.saveChatMessagesInDataBaseNew(data: array, chatData: nil)
//
//        ChatDBManager.ChatDBManagerSharedInstance.sendMessageToExchange(exchangeName: exchangename, queue: queueForChat!, message: msg)
//    }
    
    @IBAction func addOptionsBtnAction(_ sender: Any)
    {
        if self.checkIdUserBlocked()
        {
            let alert = UIAlertController(title: "Unblock this user to chat", message: nil, preferredStyle: .actionSheet)
            alert.addAction(UIAlertAction(title: "Unblock", style: .default) { action in
                self.apiCallForunblockUser()
            })
            alert.addAction(UIAlertAction(title: "Cancel", style: .default) { action in
                // self.cancelAction()
            })
            
            self.present(alert, animated: true, completion: nil)
        }
        else
        {
            let alert = UIAlertController(title: "Upload Profile Picture", message: nil, preferredStyle: .actionSheet)
            alert.addAction(UIAlertAction(title: "Camera", style: .default) { action in
                self.openCamera()
            })
            alert.addAction(UIAlertAction(title: "Choose From Gallery", style: .default) { action in
                self.openGallary()
            })
            alert.addAction(UIAlertAction(title: "Cancel", style: .default) { action in
                // self.cancelAction()
            })
            
            self.present(alert, animated: true, completion: nil)
        }
    }
    @IBAction func btnRetryMessageAction(_ sender: UIButton)
    {
        let alert = UIAlertController(title: "Retry Options", message: nil, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Retry", style: .default) { action in
            self.retrySendingMessage(tag: sender.tag, url: "")
        })
        alert.addAction(UIAlertAction(title: "Cancel", style: .default) { action in
            // self.cancelAction()
        })
        self.present(alert, animated: true, completion: nil)
    }
    @IBAction func btnRetryImageAction(_ sender: UIButton)
    {
       // let obj = arrayChat[sender.tag] as! ChatHistoryObject
        let indexPath = IndexPath(item: sender.tag, section: 0)
        let msgObjFetchReq = fetchedResultsController.object(at: indexPath)
        let obj = ChatHistoryObject.init(data: msgObjFetchReq)
        if obj.status == "failed"
        {
            let alert = UIAlertController(title: "Retry Options", message: nil, preferredStyle: .actionSheet)
            alert.addAction(UIAlertAction(title: "Retry", style: .default) { action in
                self.retrySendingMessage(tag: sender.tag, url: "")
            })
            alert.addAction(UIAlertAction(title: "Cancel", style: .default) { action in
                // self.cancelAction()
            })
            self.present(alert, animated: true, completion: nil)
        }
        else if obj.status == "sending"
        {
            
        }
        else
        {
            let storyboard = UIStoryboard(name: "Chatting", bundle: nil)
            let fullImage :FullImageViewController = storyboard.instantiateViewController(withIdentifier: "FullImageViewController") as! FullImageViewController
            fullImage.imgStr = obj.message
            self.navigationController?.pushViewController(fullImage, animated: false)
        }
        
    }
    @IBAction func btnMoreAction(_ sender: UIButton)
    {
        if self.checkIdUserBlocked()
        {
            let alert = UIAlertController(title: "Unblock this user to chat", message: nil, preferredStyle: .actionSheet)
            alert.addAction(UIAlertAction(title: "Unblock", style: .default) { action in
                self.apiCallForunblockUser()
            })
            alert.addAction(UIAlertAction(title: "Cancel", style: .default) { action in
                // self.cancelAction()
            })
            
            self.present(alert, animated: true, completion: nil)
        }
        else
        {
            let alert = UIAlertController(title: "More Options", message: nil, preferredStyle: .actionSheet)
            alert.addAction(UIAlertAction(title: "Block this user", style: .default) { action in
                self.blockThisUser()
            })
            alert.addAction(UIAlertAction(title: "Cancel", style: .default) { action in
                // self.cancelAction()
            })
            
            self.present(alert, animated: true, completion: nil)
        }
        
    }
    @IBAction func btnFullImageAction(_ sender: UIButton)
    {
        //let obj = arrayChat[sender.tag] as! ChatHistoryObject
        let indexPath = IndexPath(item: sender.tag, section: 0)
        let msgObjFetchReq = fetchedResultsController.object(at: indexPath)
        let obj = ChatHistoryObject.init(data: msgObjFetchReq)
        let storyboard = UIStoryboard(name: "Chatting", bundle: nil)
        let fullImage :FullImageViewController = storyboard.instantiateViewController(withIdentifier: "FullImageViewController") as! FullImageViewController
        fullImage.imgStr = obj.message
        self.navigationController?.pushViewController(fullImage, animated: false)
    }
    @IBAction func btnUserImageAction(_ sender: Any)
    {
        if recieverImage.isEmpty {
            
        }
        else
        {
            let storyboard = UIStoryboard(name: "Chatting", bundle: nil)
            let fullImage :FullImageViewController = storyboard.instantiateViewController(withIdentifier: "FullImageViewController") as! FullImageViewController
            fullImage.imgStr = recieverImage
            self.navigationController?.pushViewController(fullImage, animated: false)
        }
        
    }
    
    // MARK:- TableView Delegates
//    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
//        return 200;
//    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        if self.exchangename == nil || self.queueForChat == nil || (self.exchangename?.isEmpty)! || (self.queueForChat?.isEmpty)!{
            return 0
        }
        guard let quotes = fetchedResultsController.fetchedObjects else { return 0 }
        return quotes.count
        //return self.arrayChat.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        var showTopDate = true
        let msgObjFetchReq = fetchedResultsController.object(at: indexPath)
        let msgObj = ChatHistoryObject.init(data: msgObjFetchReq)
        //let msgObj = self.arrayChat[indexPath.row] as! ChatHistoryObject
        //  print("Testing The Crash")
       // msgObj.PrintMySelf()
        var differenceFromCurDate = 0
        var dateToShow = ""
        let end = NSDate(timeIntervalSince1970: TimeInterval(msgObj.chattimestamp!))
        let calendar = Calendar.current as NSCalendar
        let curD = Date() as NSDate
        if indexPath.row > 0 {
            let indexPath1 = IndexPath(item: indexPath.row - 1, section: 0)
            let msgObjFetchReq1 = fetchedResultsController.object(at: indexPath1)
             let temObj = ChatHistoryObject.init(data: msgObjFetchReq1)
           // let temObj = self.arrayChat[indexPath.row - 1] as! ChatHistoryObject
            let start = NSDate(timeIntervalSince1970: TimeInterval(temObj.chattimestamp!))
            let dif = calendar.daysWithinEraFromDate(startDate: start, toDate: end)
            
            if dif > 0
            {
                differenceFromCurDate = calendar.daysWithinEraFromDate(startDate: end, toDate: curD)
                if differenceFromCurDate == 0 {
                    dateToShow = "Today"
                }
                else if differenceFromCurDate == 0 {
                    dateToShow = "Yesterday"
                }
                else
                {
                    let dateFormatter = DateFormatter()
                    dateFormatter.timeStyle = DateFormatter.Style.medium //Set time style
                    dateFormatter.dateStyle = DateFormatter.Style.medium //Set date style
                    dateFormatter.timeZone = TimeZone.current
                    dateFormatter.dateFormat = "dd MMM, yyyy"
                    dateToShow = dateFormatter.string(from: end as Date)
                }
                showTopDate = true
            }
            else
            {
                showTopDate = false
            }
        }
        else
        {
            differenceFromCurDate = calendar.daysWithinEraFromDate(startDate: end, toDate: curD)
            if differenceFromCurDate == 0 {
                dateToShow = "Today"
            }
            else if differenceFromCurDate == 1 {
                dateToShow = "Yesterday"
            }
            else
            {
                let dateFormatter = DateFormatter()
                dateFormatter.timeStyle = DateFormatter.Style.medium //Set time style
                dateFormatter.dateStyle = DateFormatter.Style.medium //Set date style
                dateFormatter.timeZone = TimeZone.current
                dateFormatter.dateFormat = "dd MMM, yyyy"
                dateToShow = dateFormatter.string(from: end as Date)
            }
        }
        
        let senderId = msgObj.senderId
        if indexPath.row == 164 {
            print(msgObj.chattimestamp)
            print(msgObj.originalId)
        }
        
        if senderId == UserDefaults.standard.value(forKey: Constants.kChatUserId) as? String
        {
            if msgObj.type == "image"
            {
                let cell:MyImageTableCell = self.tblChat.dequeueReusableCell(withIdentifier: "MyImageTableCell") as! MyImageTableCell!
                DataManager.dataManagerSharedInstance.roundedCornerImage(image: cell.imgPhoto, radius: 4)
            DataManager.dataManagerSharedInstance.roundedCornerlabel(label: cell.lblTopDate, radius: 8)
                if showTopDate
                {
                    cell.lblTopDate.text = dateToShow
                    cell.lblTopDate.isHidden = false
                }
                else
                {
                    cell.lblTopDate.isHidden = true
                }
                
                let url = URL(string: msgObj.message)
            
                let dataDecoded : Data = Data(base64Encoded: msgObj.image64, options: .ignoreUnknownCharacters)!
                
                var image = UIImage()
                
                if (!msgObj.image64.isEmpty)
                {
                    let decodedimage = UIImage(data: dataDecoded)
                    image = decodedimage!
                    cell.imgPhoto.image = image
                }
                else
                {
                    // image = UIImage(named : "bg2.jpg")
                    cell.imgPhoto.sd_setShowActivityIndicatorView(true)
                    cell.imgPhoto.sd_setIndicatorStyle(.gray)
                    cell.imgPhoto.sd_setImage(with: url, completed: { (responseImage, error, nil, url) in
                       // uncom  ChatDBManager.ChatDBManagerSharedInstance.updateImageRemoveBase64(chatId: msgObj.originalId)
                    })
//                    cell.imgPhoto.sd_setHighlightedImage(with: url, options: [.highPriority], completed: { (responseImage, error, nil, url) in
//                        ChatDBManager.ChatDBManagerSharedInstance.updateImageRemoveBase64(chatId: msgObj.originalId)
                  //  })
                }
//                if (!msgObj.image64.isEmpty)
//                {
//                    let decodedimage = UIImage(data: dataDecoded)
//                    image = decodedimage!
//                }
//                else
//                {
//                 //   image = UIImage(named : "bg2.jpg")
//                }
//
//                if msgObj.message != nil && !msgObj.message.isEmpty
//                {
//                    cell.imgPhoto.sd_setShowActivityIndicatorView(true)
//                    cell.imgPhoto.sd_setIndicatorStyle(.gray)
//
//
//                    cell.imgPhoto.sd_setImage(with: url, placeholderImage : image, options: [.highPriority] , completed : { (responseImage, error, nil  , url ) in
//
//                        if !cell.imgPhoto.isImageLoaded
//                        {
//                            DispatchQueue.main.async(execute: {
//                                () -> Void in
//                                if (!msgObj.image64.isEmpty)
//                                {
//                                    cell.imgPhoto.isImageLoaded = true
////                                    self.tblChat.beginUpdates()
////                                    self.tblChat.reloadRows( at: [indexPath], with: .fade)
////                                    self.tblChat.endUpdates()
//                                    ChatDBManager.ChatDBManagerSharedInstance.updateImageRemoveBase64(chatId: msgObj.originalId)
//                                }
//
//
//                            })
//                        }
//
//                    })
//                }
//            else
//                {
//                    cell.imgPhoto.image = image
//                }
                if arrayChat.count > indexPath.row + 1
                {
                    let nextObj = self.arrayChat[indexPath.row + 1] as! ChatHistoryObject
                    if nextObj.senderId == msgObj.senderId
                    {
                        
                        cell.imgPointer.isHidden = true
                    }
                    else
                    {
                        cell.imgPointer.isHidden = false
                    }
                }
                else
                {
                    cell.imgPointer.isHidden = false
                }
                
                
                let date = NSDate(timeIntervalSince1970: TimeInterval(msgObj.chattimestamp!))
                let dateFormatter = DateFormatter()
                dateFormatter.timeStyle = DateFormatter.Style.medium //Set time style
                dateFormatter.dateStyle = DateFormatter.Style.medium //Set date style
                dateFormatter.timeZone = TimeZone.current
                dateFormatter.dateFormat = "h:mm:a"
                let localDate = dateFormatter.string(from: date as Date)
                
                cell.lblDate.text = localDate
                cell.btnRetry.tag = indexPath.row
                if msgObj.status == "sent" {
                    let img = UIImage(named: "sent.png")
                    cell.imgStatus.image = img
                    // cell.btnRetry.isHidden = true
                }
                else if msgObj.status == "failed" {
                   // cell.btnRetry.isHidden = false
                    let img = UIImage(named: "failed.png")
                    cell.imgStatus.image = img
                }
                else if msgObj.status == "delivered" {
                    let img = UIImage(named: "Delivered.png")
                    cell.imgStatus.image = img
                    //cell.btnRetry.isHidden = true
                }
                else if msgObj.status == "read" {
                    let img = UIImage(named: "read.png")
                    cell.imgStatus.image = img
                    //cell.btnRetry.isHidden = true
                }
                else
                {
                    let img = UIImage(named: "sending.png")
                    cell.imgStatus.image = img
                    //cell.btnRetry.isHidden = true
                }
                
                
                return cell
            }
            
            
            let cell:MyMessageTableCell = self.tblChat.dequeueReusableCell(withIdentifier: "MyMessageTableCell") as! MyMessageTableCell!
            DataManager.dataManagerSharedInstance.roundedCornerlabel(label: cell.lblTopDate, radius: 8)
            cell.lblmessage.text = msgObj.message
            if showTopDate
            {
                cell.lblTopDate.text = dateToShow
                cell.lblTopDate.isHidden = false
            }
            else
            {
                cell.lblTopDate.isHidden = true
            }
            
            if msgObj.status == "sent" {
                let img = UIImage(named: "sent.png")
                cell.imgStatus.image = img
                cell.btnRetry.isHidden = true
            }
            else if msgObj.status == "failed" {
                cell.btnRetry.isHidden = false
                let img = UIImage(named: "failed.png")
                cell.imgStatus.image = img
            }
            else if msgObj.status == "delivered" {
                let img = UIImage(named: "Delivered.png")
                cell.imgStatus.image = img
                cell.btnRetry.isHidden = true
            }
            else if msgObj.status == "read" {
                let img = UIImage(named: "read.png")
                cell.imgStatus.image = img
                cell.btnRetry.isHidden = true
            }
            else
            {
                let img = UIImage(named: "sending.png")
                cell.imgStatus.image = img
                cell.btnRetry.isHidden = true
            }
            if arrayChat.count > indexPath.row + 1
            {
                let nextObj = self.arrayChat[indexPath.row + 1] as! ChatHistoryObject
                if nextObj.senderId == msgObj.senderId
                {
                    cell.imgPointer.isHidden = true
                }
                else
                {
                    cell.imgPointer.isHidden = false
                }
            }
            else
            {
                cell.imgPointer.isHidden = false
            }
            
            
            let date = NSDate(timeIntervalSince1970: TimeInterval(msgObj.chattimestamp!))
            let dateFormatter = DateFormatter()
            dateFormatter.timeStyle = DateFormatter.Style.medium //Set time style
            dateFormatter.dateStyle = DateFormatter.Style.medium //Set date style
            dateFormatter.timeZone = TimeZone.current
            dateFormatter.dateFormat = "h:mm:a"
            let localDate = dateFormatter.string(from: date as Date)
            
            cell.lblDate.text = localDate
            
            
            
            cell.btnRetry.tag = indexPath.row
            return cell
        }
        
         if msgObj.type == "image"
        {
            let cell:SenderImageTableCell = self.tblChat.dequeueReusableCell(withIdentifier: "SenderImageTableCell") as! SenderImageTableCell!
            DataManager.dataManagerSharedInstance.roundedCornerImage(image: cell.imgPhoto, radius: 4)
            DataManager.dataManagerSharedInstance.roundedCornerlabel(label: cell.lblTopDate, radius: 8)
            cell.btnFullImg.tag = indexPath.row
            if showTopDate
            {
                cell.lblTopDate.text = dateToShow
                cell.lblTopDate.isHidden = false
            }
            else
            {
                cell.lblTopDate.isHidden = true
            }
            
            let userImg = URL(string: self.recieverImage)
            cell.imgUser.sd_setBackgroundImage(with: userImg, for: UIControlState.normal)
            
            
            let url = URL(string: msgObj.message)
            let dataDecoded : Data = Data(base64Encoded: msgObj.image64, options: .ignoreUnknownCharacters)!
            
            var image = UIImage()
            if (!msgObj.image64.isEmpty)
            {
                let decodedimage = UIImage(data: dataDecoded)
                image = decodedimage!
                cell.imgPhoto.image = image
            }
            else
            {
                image = UIImage(named : "bg2.jpg")!
//                cell.imgPhoto.sd_setShowActivityIndicatorView(true)
//                cell.imgPhoto.sd_setIndicatorStyle(.gray)
//                cell.imgPhoto.sd_setHighlightedImage(with: url, options: [.highPriority], completed: { (responseImage, error, nil, url) in
//                    ChatDBManager.ChatDBManagerSharedInstance.updateImageRemoveBase64(chatId: msgObj.originalId)
//                })
            }
            cell.imgPhoto.sd_setShowActivityIndicatorView(true)
            cell.imgPhoto.sd_setIndicatorStyle(.gray)

            cell.imgPhoto.sd_setImage(with: url, placeholderImage : image, options: [.highPriority] , completed : { (responseImage, error, nil  , url ) in

                if !cell.imgPhoto.isImageLoaded
                {
                    DispatchQueue.main.async(execute: {
                        () -> Void in
                        if (!msgObj.image64.isEmpty)
                        {
                            cell.imgPhoto.isImageLoaded = true
//                            self.tblChat.beginUpdates()
//                            self.tblChat.reloadRows( at: [indexPath], with: .fade)
//                            self.tblChat.endUpdates()
                          //uncom  ChatDBManager.ChatDBManagerSharedInstance.updateImageRemoveBase64(chatId: msgObj.originalId)
                        }
                    })
                }

            })
            
            
            if arrayChat.count > indexPath.row + 1
            {
                let nextObj = self.arrayChat[indexPath.row + 1] as! ChatHistoryObject
                if nextObj.senderId == msgObj.senderId
                {
                    cell.imgPointer.isHidden = true
                    cell.imgUser.isHidden = true
                }
                else
                {
                    cell.imgPointer.isHidden = false
                    cell.imgUser.isHidden = false
                }
            }
            else
            {
                cell.imgPointer.isHidden = false
                cell.imgUser.isHidden = false
            }
            
            
            let date = NSDate(timeIntervalSince1970: TimeInterval(msgObj.chattimestamp!))
            let dateFormatter = DateFormatter()
            dateFormatter.timeStyle = DateFormatter.Style.medium //Set time style
            dateFormatter.dateStyle = DateFormatter.Style.medium //Set date style
            dateFormatter.timeZone = TimeZone.current
            dateFormatter.dateFormat = "h:mm:a"
            let localDate = dateFormatter.string(from: date as Date)
            
            cell.lblDate.text = localDate
            cell.btnFullImg.tag = indexPath.row
            return cell
        }
        
        
        let cell:ChatMessageTableCell = self.tblChat.dequeueReusableCell(withIdentifier: "ChatMessageTableCell") as! ChatMessageTableCell!
        DataManager.dataManagerSharedInstance.roundedCornerlabel(label: cell.lblTopDate, radius: 8)
        
        if showTopDate
        {
            cell.lblTopDate.text = dateToShow
            cell.lblTopDate.isHidden = false
        }
        else
        {
            cell.lblTopDate.isHidden = true
        }
        cell.lblmessage.text = msgObj.message
        let userImg = URL(string: self.recieverImage)
        if userImg != nil
        {
            cell.imgUser.sd_setBackgroundImage(with: userImg, for: UIControlState.normal)
        }
        if arrayChat.count > indexPath.row + 1
        {
            let nextObj = self.arrayChat[indexPath.row + 1] as! ChatHistoryObject
            if nextObj.senderId == msgObj.senderId
            {
                cell.imgPointer.isHidden = true
                cell.imgUser.isHidden = true
            }
            else
            {
                cell.imgPointer.isHidden = false
                cell.imgUser.isHidden = false
            }
        }
        else
        {
            cell.imgPointer.isHidden = false
            cell.imgUser.isHidden = false
        }
        
        
        let date = NSDate(timeIntervalSince1970: TimeInterval(msgObj.chattimestamp!))
        let dateFormatter = DateFormatter()
        dateFormatter.timeStyle = DateFormatter.Style.medium //Set time style
        dateFormatter.dateStyle = DateFormatter.Style.medium //Set date style
        dateFormatter.timeZone = TimeZone.current
        dateFormatter.dateFormat = "h:mm:a"
        let localDate = dateFormatter.string(from: date as Date)
        
        cell.lblDate.text = localDate
        
        return cell
        
        
    }
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        
        tableView.deselectRow(at: indexPath, animated: false)
        
    }
    // MARK:- RabbitMQ Methods
    
    func subscribeToExchangeWithName(exchangeName : String! , queue : String ) -> Void
    {
        // subscribe with exchange to recieve messages from specified exchange
        
      //  print("Attempting to connect to local RabbitMQ broker")
      //  print("Waiting for messages.")
        
        let ch = ChatDBManager.ChatDBManagerSharedInstance.conn.createChannel()
       // let q = ch.queue(queue)
       // let exchange = ch.direct(exchangeName, options: [.durable , .autoDelete])
        var arguDic:[String : RMQValue] = [String : RMQValue]()
       // let value = RMQSignedLonglong(900000)
        
        //arguDic["x-expires"] = value
        let mode = RMQLongstr("lazy")
        arguDic["x-queue-mode"] = mode
        let q = ch.queue(queue, options: .durable , arguments: arguDic as! [String : RMQValue & RMQFieldValue])
        let exchange = ch.fanout(exchangeName, options: [.durable, .autoDelete])
        q.bind(exchange, routingKey: q.name+"")

        
    }
    
    
    
    
    @objc  func callBackFromPostAnswer(notification:NSNotification) -> Void
    {
      //  self.setUpFetchRequestCoreData()
        DispatchQueue.main.async() {
            let indexPath = IndexPath(item: self.arrayChat.count - 1, section: 0)
           // check self.tblChat.insertRows(at: [indexPath], with: .bottom)
          //  self.tblChat.reloadData()
            if self.arrayChat.count > 0
            {
              //  self.scrollToBottom()
            }
            
        }
        
    }
    @objc func notificationForStatusUpdate(notification:NSNotification) -> Void
    {
        DispatchQueue.main.async() {
            let data = notification.userInfo as! Constants.jsonStandard
            let obj = ChatHistoryObject(info:data)
            
            let senderId = obj.senderId
            
            if senderId == UserDefaults.standard.value(forKey: Constants.kChatUserId) as? String
            {
                var indexFoundAt = 0
                for  i in (0..<self.arrayChat.count).reversed()
                {
                    let objOld = self.arrayChat[i] as! ChatHistoryObject
                    
                    if obj.idd == objOld.idd
                    {
                        self.arrayChat.replaceObject(at: i, with: obj)
                        indexFoundAt = i
                        break
                    }
                    
                }
                let rowNumber = indexFoundAt
                let indexPath = IndexPath(item: rowNumber, section: 0)
                UIView.performWithoutAnimation {
                     self.tblChat.reloadRows(at: [indexPath], with: .none)
                }
               
                //self.tblChat.reloadData()
                if self.arrayChat.count > 0
                {
                    self.scrollToBottom()
                }
            }
            
        }
        
    }
    func scrollToBottom()
    {
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(300)) {
            let numberOfSections = self.tblChat.numberOfSections
            let numberOfRows = self.tblChat.numberOfRows(inSection: numberOfSections-1)
            
            if numberOfRows > 0 {
                let indexPath = IndexPath(row: numberOfRows-1, section: (numberOfSections-1))
                self.tblChat.scrollToRow(at: indexPath, at: .bottom, animated: false)
            }
        }
    }
    
    ////==================== App delegate Methods ======================
    
    
    //MARK:- NOtification
    @objc func callBackFromSystemMsg(notification:NSNotification) -> Void
    {
        
        let data = notification.userInfo as! Constants.jsonStandard
        let type = data["type"] as! String
        if (type == "system")
        {}
        else if (type == "chat")
        {
            let subtype = data["subtype"] as! String
            
            if subtype == "message"
            {
                let chatHistory = data["chatHistory"] as! Constants.jsonStandard
                let msgObj = ChatHistoryObject(info:chatHistory)
                let senderId = msgObj.senderId
                if msgObj.exchange == self.exchangename // if this message for the same user
                {
                    if senderId != UserDefaults.standard.value(forKey: Constants.kChatUserId) as? String
                    {
                        arrayChat.add(msgObj)
                        NotificationCenter.default.post(name: Notification.Name("chatnotification"), object: nil , userInfo: nil)
                        msgObj.status = "read"
                        ChatDBManager.ChatDBManagerSharedInstance.sendDeliveryStatus(chatObj: msgObj)
                    }
                }
            }
            if subtype == "user_status" {
                let userId = data["userId"] as! String
                if userId != UserDefaults.standard.value(forKey: Constants.kChatUserId) as? String
                {
                    onceOnline = true
                    timeAtPress = Date()
                }
            }
            if subtype == "typingStatus"
            {
                let userId = data["userId"] as! String
                if userId != UserDefaults.standard.value(forKey: Constants.kChatUserId) as? String
                {
                    let exchange = data["exchange"] as! String
                    if exchange == self.exchangename
                    {
                        let statusData = data["typingData"] as! Constants.jsonStandard
                        let isTyping = statusData["isTyping"] as! String
                        if isPartnerTying != isTyping
                        {
                            isPartnerTying = isTyping
                            self.changeTypingStatus()
                        }
                    }
                }
            }
        }
    }
    
    @objc func connectionCreatedSuccessfully(notification:NSNotification) -> Void
    {
        self.lblConnectionStatus.backgroundColor = UIColor.green
        self.lblConnectionStatus.text = "Connected"
        DispatchQueue.main.async() {
            
            UIView.animate(withDuration: 1, animations: {
                self.constHeightLblConnectionStatus.constant = 0
                self.lblConnectionStatus.alpha = 0.0
                self.view.layoutIfNeeded()
                
            }, completion: { (true) in
                //self.lblConnectionStatus.isHidden = true
            })
        }
        
    }
    @objc func connectionLost(notification:NSNotification) -> Void
    {
        self.lblConnectionStatus.backgroundColor = UIColor.red
        self.lblConnectionStatus.text = "No Connection"
        DispatchQueue.main.async() {
            UIView.animate(withDuration: 0.5, animations: {
                self.constHeightLblConnectionStatus.constant = 25
                self.lblConnectionStatus.alpha = 100
                self.view.layoutIfNeeded()
                
            }, completion: { (true) in
                //self.lblConnectionStatus.isHidden = false
            })
        }
        
    }
    // MARK: API Call For Start Chat
    func apiCallForStartChat() -> Void
    {
        self.view.addSubview(activityVC.view)
        
        let url:String = Constants.baseUrl+ApiLinks.startChatUrl
        var params:Constants.dictionaryStandard = Constants.dictionaryStandard()
        let header = [String : String]()
        
        params["recipient"] = recipientId
        
        NotificationCenter.default.addObserver(self, selector: #selector(CallBackFromStartChatApi(notification:)), name: Notification.Name(ApiLinks.startChatUrl), object: nil)
        let obj = NetworkCalls(link:url , notificationName:ApiLinks.startChatUrl, params:params , header:header , addUSerID:true)
        obj.postAPICall()
    }
    
    @objc func CallBackFromStartChatApi(notification:NSNotification) -> Void
    {
        activityVC.view.removeFromSuperview()
        if(notification.name == Notification.Name(ApiLinks.startChatUrl))
        {
            let apiData = notification.userInfo as! Constants.jsonStandard
            let response = apiData["response"] as! Constants.jsonStandard
           // print("\(apiData)")
            let code = response["code"] as! String
            if code == "11"
            {
                exchangename = response["exchange"] as? String
                queueForChat = response["queue"] as? String 
                self.subscribeToExchangeWithName(exchangeName: exchangename!, queue: queueForChat!)
                
                // Add Thread To DB
                var tempThread = Constants.jsonStandard()
                tempThread["name"] = exchangename as AnyObject
                tempThread["senderName"] = self.recieverName as AnyObject
                tempThread["senderImage"] = self.recieverImage as AnyObject
                tempThread["exchange"] = self.exchangename as AnyObject
                
                let thread  = ChatThreadModel(info: tempThread)
                
                var insertionArray = [ChatThreadModel]()
                insertionArray.append(thread)
                ChatDBManager.ChatDBManagerSharedInstance.saveThreadsInDataBase(data: insertionArray)
                
                // Add Member To DB
                
                var tempMember = Constants.jsonStandard()
                tempMember["id"] = "" as AnyObject
                tempMember["name"] = self.recieverName as AnyObject
                tempMember["exchange"] = exchangename as AnyObject
                tempMember["userId"] = recipientId as AnyObject
                tempMember["status"] = "" as AnyObject
                tempMember["senderImage"] = recieverImage as AnyObject
                
                let member  = ChatMemberObject(info: tempMember)
                
                var insertionMemArray = [ChatMemberObject]()
                insertionMemArray.append(member)
                ChatDBManager.ChatDBManagerSharedInstance.saveMembersInDataBase(data: insertionMemArray)
                
                // Fetch Messages From DB
                self.fetchMemDetails()
                
              //  self.fetchMessagesFromDB(exchange: exchangename)
                // new
                self.setUpFetchRequestCoreData()
            }
            else
            {
                let msg = response["message"] as! String
                // showAlert(msg: msg)
            }
        }
        
        // Removing the Observer
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: ApiLinks.startChatUrl), object: nil)
    }
    
    
    // MARK: API Call For UploadImage
    func apiCallForUploadImaget(imageData : String! , tag : Int) -> Void
    {
       // self.view.addSubview(activityVC.view)
        curImgRow = tag
        let url:String = Constants.baseUrl+ApiLinks.uploadChatImage
        var params:Constants.dictionaryStandard = Constants.dictionaryStandard()
        let header = [String : String]()
        
        params["image"] = imageData
        
        NotificationCenter.default.addObserver(self, selector: #selector(CallBackFromUploadImage(notification:)), name: Notification.Name(ApiLinks.uploadChatImage), object: nil)
        
//        let obj = NetworkCalls(link:url , notificationName:ApiLinks.uploadChatImage, params:params , header:header , addUSerID:true)
        let obj = NetworkCalls.init(link: url, notificationName: ApiLinks.uploadChatImage, params: params, header: header, addUSerID: true, arrayTag: tag)
        obj.postAPICall()
    }
    
    @objc func CallBackFromUploadImage(notification:NSNotification) -> Void
    {
       // activityVC.view.removeFromSuperview()
        
        if(notification.name == Notification.Name(ApiLinks.uploadChatImage))
        {
            let apiData = notification.userInfo as! Constants.jsonStandard
            let response = apiData["response"] as! Constants.jsonStandard
            let tag = apiData["tag"] as! Int
           // print("\(apiData)")
            let code = response["code"] as! String
            if code == "11"
            {
                let url = response["message"] as! String
                
                self.retrySendingMessage(tag: tag, url: url)
                
                curImgRow = -1
            }
            else
            {
                let msg = response["msg"] as! String
                 showAlert(msg: msg)
            }
            
        }
        
        // Removing the Observer
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: ApiLinks.uploadChatImage), object: nil)
    }
    // MARK: API Call For block user
    func apiCallForBlockUser() -> Void
    {
        self.view.addSubview(activityVC.view)
        
        let url:String = Constants.baseUrl+ApiLinks.blockUser
        var params:Constants.dictionaryStandard = Constants.dictionaryStandard()
        let header = [String : String]()
        
        params["member"] = recipientId
        params["group"] = exchangename
        
        NotificationCenter.default.addObserver(self, selector: #selector(CallBackFromBlockUser(notification:)), name: Notification.Name(ApiLinks.blockUser), object: nil)
        let obj = NetworkCalls(link:url , notificationName:ApiLinks.blockUser, params:params , header:header , addUSerID:true)
        obj.postAPICall()
    }
    
    @objc func CallBackFromBlockUser(notification:NSNotification) -> Void
    {
        activityVC.view.removeFromSuperview()
        
        if(notification.name == Notification.Name(ApiLinks.blockUser))
        {
            let apiData = notification.userInfo as! Constants.jsonStandard
            let response = apiData["response"] as! Constants.jsonStandard
           // print("\(apiData)")
            let code = response["code"] as! String
            let msg = response["message"] as! String
            if code == "11"
            {
                self.blockUserLcally()
                showAlert(msg: msg)
                
                //_=self.navigationController?.popViewController(animated: true)
            }
            else if code == "401"
            {
                self.blockUserLcally()
                showAlert(msg: msg)
                
            }
            else
            {
                
                 showAlert(msg: msg)
            }
        }
        
        // Removing the Observer
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: ApiLinks.blockUser), object: nil)
    }
    // MARK: API Call For block user
    func apiCallForunblockUser() -> Void
    {
        self.view.addSubview(activityVC.view)
        
        let url:String = Constants.baseUrl+ApiLinks.unblockUser
        var params:Constants.dictionaryStandard = Constants.dictionaryStandard()
        let header = [String : String]()
        
        params["member"] = recipientId
        params["group"] = exchangename
        
        NotificationCenter.default.addObserver(self, selector: #selector(CallBackFromunblockUser(notification:)), name: Notification.Name(ApiLinks.unblockUser), object: nil)
        let obj = NetworkCalls(link:url , notificationName:ApiLinks.unblockUser, params:params , header:header , addUSerID:true)
        obj.postAPICall()
    }
    
    @objc func CallBackFromunblockUser(notification:NSNotification) -> Void
    {
        activityVC.view.removeFromSuperview()
        
        if(notification.name == Notification.Name(ApiLinks.unblockUser))
        {
            let apiData = notification.userInfo as! Constants.jsonStandard
            let response = apiData["response"] as! Constants.jsonStandard
           // print("\(apiData)")
            let code = response["code"] as! String
            let msg = response["message"] as! String
            if code == "11"
            {
                self.unblockUserLcally()
               // showAlert(msg: msg)
            }
            else
            {
                showAlert(msg: msg)
            }
        }
        
        // Removing the Observer
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: ApiLinks.unblockUser), object: nil)
    }
    
    
    //MARK:- Image Picker Delegates
    
    // Photo Capturing Functions
    
    func openGallary()
    {
        picker.allowsEditing = true
        picker.sourceType = .photoLibrary
        picker.mediaTypes = UIImagePickerController.availableMediaTypes(for: .photoLibrary)!
        picker.modalPresentationStyle = .popover
        present(picker, animated: true, completion: nil)
        //  picker.popoverPresentationController?.barButtonItem = sender
        
        
    }
    
    
    func openCamera()
    {
        if(UIImagePickerController .isSourceTypeAvailable(UIImagePickerControllerSourceType.camera)){
            picker.allowsEditing = true
            picker.sourceType = UIImagePickerControllerSourceType.camera
            picker.cameraCaptureMode = .photo
            present(picker, animated: true, completion: nil)
        }
        else{
            let alert = UIAlertController(title: "Camera Not Found", message: "This device has no Camera", preferredStyle: .alert)
            let ok = UIAlertAction(title: "OK", style:.default, handler: nil)
            alert.addAction(ok)
            present(alert, animated: true, completion: nil)
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any])
    {
        
        
        if let image = info[UIImagePickerControllerEditedImage] as? UIImage
        {
        
            if let imageData = image.jpeg(.lowest)
            {
                 compressedImgData = imageData.base64EncodedString(options: NSData.Base64EncodingOptions(rawValue: 0))
            }
            var  base64 = ""
            if let actualImagData = image.jpeg(.medium)
            {
               base64 = actualImagData.base64EncodedString(options: NSData.Base64EncodingOptions(rawValue: 0))
                
                
            }
            
            let date = Date()
            let timeInterval = date.timeIntervalSince1970
            let timeInLongInt : Int = Int(timeInterval)
            
            var dic = Constants.jsonStandard()
            
            dic["type"] = "chat" as AnyObject
            dic["subtype"] = "message" as AnyObject
            dic["application_name"] = "Evento" as AnyObject
            dic["exchange"] = self.exchangename as AnyObject
            dic["senderNumber"] = "988347928429" as AnyObject
            dic["queue"] = self.queueForChat as AnyObject
            dic["senderName"] = "\(SingletonClassOfObjects.SharedInstance.userObject.first_name!) \(SingletonClassOfObjects.SharedInstance.userObject.last_name!)"  as AnyObject
            dic["senderImage"] = SingletonClassOfObjects.SharedInstance.userObject.image_name as AnyObject
            dic["userId"] = UserDefaults.standard.value(forKey: Constants.kChatUserId) as AnyObject
            
            var chat = Constants.jsonStandard()
            chat["exchange"] = exchangename as AnyObject
            chat["timestamp"] = "\(timeInLongInt)" as AnyObject
            chat["type"] = "image" as AnyObject
            chat["receiver_id"] = self.recipientId as AnyObject
            chat["sender_id"] = UserDefaults.standard.value(forKey: Constants.kChatUserId) as AnyObject
            chat["id"] = ChatDBManager.ChatDBManagerSharedInstance.fetchTheNextIdFor(table: "ChatHistory") as AnyObject
            chat["originalId"] = ChatDBManager.ChatDBManagerSharedInstance.fetchTheNextIdFor(table: "ChatHistory") as AnyObject
            chat["image64"] = compressedImgData as AnyObject
            chat["message"] = "" as AnyObject
            if DataManager.dataManagerSharedInstance.isInternetAvailable()
            {
                chat["status"] = "sending" as AnyObject
            }
            else
            {
                chat["status"] = "failed" as AnyObject
            }
            chat["env"] = "dev" as AnyObject
            dic["chatHistory"] = chat as AnyObject
            
            
            let msgObj = ChatHistoryObject(info:chat)
            self.arrayChat.add(msgObj)
            //let indexPath = IndexPath(item: arrayChat.count - 1, section: 0)
          //  self.tblChat.insertRows(at: [indexPath], with: .bottom)
            //tblChat.reloadData()
            if arrayChat.count > 0
            {
                //self.scrollToBottom()
            }
            
            var msg = ""
            do {
                let data = try JSONSerialization.data(withJSONObject:dic, options:[])
                msg = String(data: data, encoding: String.Encoding.utf8)!
                
            } catch {
               // print("JSON serialization failed:  \(error)")
            }
           // reloadata
            var array = [ChatHistoryObject]()
            array.append(msgObj)
             guard let countForTag = fetchedResultsController.fetchedObjects else { return }
           // ChatDBManager.ChatDBManagerSharedInstance.saveChatMessagesInDataBase(data: array, chatData: nil)
            //ChatDBManager.ChatDBManagerSharedInstance.saveChatMessagesInDataBaseNew(data: array, chatData: nil)
            
            msgObj.dbAction = "1"
            ChatDBManager.ChatDBManagerSharedInstance.arrayChatQueue.append(msgObj)
            if(!ChatDBManager.ChatDBManagerSharedInstance.isOurQueueInProcess){
                ChatDBManager.ChatDBManagerSharedInstance.KeepReadingOurQueue()
            }
            
        print("BEFORE ============ \(NSDate())")
            let queue = DispatchQueue.global()
            queue.async {
                let bluredImg = image.resize(width: 400)
                if let imageData = bluredImg?.jpeg(.lowest)
                {print("AFTER ===========\(NSDate())")
                    self.compressedImgData = imageData.base64EncodedString(options: NSData.Base64EncodingOptions(rawValue: 0))
                    self.apiCallForUploadImaget(imageData: base64 , tag: countForTag.count);
                }
            }
            
            
        }
        
        picker.dismiss(animated: true, completion: nil);
    }
    
    
    //MARK:- NsFetchResultControllerDelegate
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
       // tblChat.beginUpdates()
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        //tblChat.endUpdates()
        
    }
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch (type) {
        case .insert:
            if let indexPath = newIndexPath {
            
                    UIView.performWithoutAnimation {
                        self.tblChat.insertRows(at: [indexPath], with: .none)
                        let msgObjFetchReq = self.fetchedResultsController.object(at: indexPath)
                        let msgObj = ChatHistoryObject.init(data: msgObjFetchReq)
                        let senderId = msgObj.senderId
                        if senderId != UserDefaults.standard.value(forKey: Constants.kChatUserId) as? String
                        {
                            msgObj.status = "read"
                            ChatDBManager.ChatDBManagerSharedInstance.sendDeliveryStatus(chatObj: msgObj)
                        }
                    }
                
                let previos = IndexPath.init(row: indexPath.row - 3, section: indexPath.section)
                let cellRect = tblChat.rectForRow(at: previos)
                let completelyVisible = tblChat.bounds.contains(cellRect)
                if (completelyVisible)
                {
                    self.scrollToBottom()
                }
                
                self.scrollToBottom()
                
            }
            
            break;
        case .update:
            if let indexPath = newIndexPath {
               DispatchQueue.main.async {
                UIView.performWithoutAnimation {
                    self.tblChat.reloadRows(at: [indexPath], with: .none)
                    //self.tblChat.reloadData()
                }
                }
            }
            break;
        case .delete:
            
            break;
        default:
            print("No Action Performed")
        }
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
        
    }
    
    
//    func blurTheImageAndSendIt(timer : Timer!) -> Void {
//        let arr = timer.userInfo as! Array<Any>
//        let image = arr[1] as! UIImage
//        let base64 = arr[0] as! String
//
//        let bluredImg = image.resize(width: 400)
//        if let imageData = bluredImg?.jpeg(.lowest)
//        {
//            self.compressedImgData = imageData.base64EncodedString(options: NSData.Base64EncodingOptions(rawValue: 0))
//            self.apiCallForUploadImaget(imageData: base64 , tag: self.arrayChat.count-1);
//
//        }
//    }
    //MARK:- Extension Started
}
    
    extension String {
        func height(withConstrainedWidth width: CGFloat, font: UIFont) -> CGFloat {
            let constraintRect = CGSize(width: width, height: .greatestFiniteMagnitude)
            let boundingBox = self.boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, attributes: [NSAttributedStringKey.font: font], context: nil)
            
            return ceil(boundingBox.height)
        }
        
        func width(withConstraintedHeight height: CGFloat, font: UIFont) -> CGFloat {
            let constraintRect = CGSize(width: .greatestFiniteMagnitude, height: height)
            let boundingBox = self.boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, attributes: [NSAttributedStringKey.font: font], context: nil)
            
            return ceil(boundingBox.width)
        }
    }
    
//    extension UIImage {
//        enum JPEGQuality: CGFloat {
//            case lowest  = 0
//            case low     = 0.25
//            case medium  = 0.5
//            case high    = 0.75
//            case highest = 1
//        }
//        
//        /// Returns the data for the specified image in PNG format
//        /// If the image object’s underlying image data has been purged, calling this function forces that data to be reloaded into memory.
//        /// - returns: A data object containing the PNG data, or nil if there was a problem generating the data. This function may return nil if the image has no data or if the underlying CGImageRef contains data in an unsupported bitmap format.
//        var png: Data? { return UIImagePNGRepresentation(self) }
//        
//        /// Returns the data for the specified image in JPEG format.
//        /// If the image object’s underlying image data has been purged, calling this function forces that data to be reloaded into memory.
//        /// - returns: A data object containing the JPEG data, or nil if there was a problem generating the data. This function may return nil if the image has no data or if the underlying CGImageRef contains data in an unsupported bitmap format.
//        func jpeg(_ quality: JPEGQuality) -> Data? {
//            return UIImageJPEGRepresentation(self, quality.rawValue)
//        }
//    }
    
    extension UIImage {
        enum JPEGQuality: CGFloat {
            case lowest  = 0
            case low     = 0.25
            case medium  = 0.5
            case high    = 0.75
            case highest = 1
        }
        
        /// Returns the data for the specified image in PNG format
        /// If the image object’s underlying image data has been purged, calling this function forces that data to be reloaded into memory.
        /// - returns: A data object containing the PNG data, or nil if there was a problem generating the data. This function may return nil if the image has no data or if the underlying CGImageRef contains data in an unsupported bitmap format.
        var png: Data? { return UIImagePNGRepresentation(self) }
        
        /// Returns the data for the specified image in JPEG format.
        /// If the image object’s underlying image data has been purged, calling this function forces that data to be reloaded into memory.
        /// - returns: A data object containing the JPEG data, or nil if there was a problem generating the data. This function may return nil if the image has no data or if the underlying CGImageRef contains data in an unsupported bitmap format.
        func jpeg(_ quality: JPEGQuality) -> Data? {
            return UIImageJPEGRepresentation(self, quality.rawValue)
        }
        
        public func resize(width: CGFloat) -> UIImage? {
            let scale = width / self.size.width
            let height = self.size.height * scale
            UIGraphicsBeginImageContext(CGSize(width: width, height: height))
            self.draw(in: CGRect(x:0, y:0, width:width, height:height))
            var resultImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            
            //resultImage = blurImage(resultImage: resultImage!)
            return resultImage
        }
        public func blurImage(resultImage: UIImage) -> UIImage? {
            
            let inputImage = CIImage(image: resultImage)
            
            //let filter = CIFilter(name: "CIGaussianBlur")
            let filter = CIFilter(name: "CIBoxBlur")
            filter?.setValue(inputImage, forKey: "inputImage")
           // filter?.setValue(20, forKey: "inputRadius")
            let blurred = filter?.value(forKey: "outputImage") as! CIImage
            
            let resImage = convert(cmage: blurred)
            return resImage
        }
        
        func convert(cmage:CIImage) -> UIImage
        {
            let context:CIContext = CIContext.init(options: nil)
            let cgImage:CGImage = context.createCGImage(cmage, from: cmage.extent)!
            let image:UIImage = UIImage.init(cgImage: cgImage)
            return image
        }
        
        
    }
    extension UIImageView
    {
        func addBlurEffect()
        {
            let blurEffect = UIBlurEffect(style: UIBlurEffectStyle.regular)
            let blurEffectView = UIVisualEffectView(effect: blurEffect)
            blurEffectView.frame = self.bounds
            
            blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight] // for supporting device rotation
            self.addSubview(blurEffectView)
        }
    }
    
    
    
    
    
