//
//  ChatThreadsViewController.swift
//  EventsApp
//
//  Created by Janbaz Ali on 8/23/17.
//  Copyright © 2017 Janbaz Ali. All rights reserved.
//

import UIKit
class ChatThreadTableCell: UITableViewCell
{
    @IBOutlet weak var imgChat: RozeeUIButton!
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var lblMessage: UILabel!
    @IBOutlet weak var lblTime: UILabel!
    @IBOutlet weak var lblUnreadCount: UILabel!
    
}
class ChatThreadsViewController: UIViewController,UITableViewDelegate, UITableViewDataSource {

    var arrayExchange = [ChatThreadModel]()
    var arrayMembers : NSMutableArray!
    @IBOutlet weak var tblChatThreads: UITableView!
    @IBOutlet weak var viewNoChats: UIView!
    
    override func viewDidLoad() {
      
        super.viewDidLoad()
//        point = CGPoint.init(x: 0, y: 0)
       // arrayExchange = NSMutableArray()
        arrayMembers = NSMutableArray()
        
        NotificationCenter.default.addObserver(self, selector: #selector(newMessageRecievedUpdateScreen(notification:)), name: Notification.Name("updateThreadsScreen"), object: nil)
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        self.fetchChatsFromDB()
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    // MARK:- Notifications
    
    @objc func newMessageRecievedUpdateScreen(notification:NSNotification) -> Void
    {
        DispatchQueue.main.async() {
            self.fetchChatsFromDB();
        }
        
    }
    
    // MARK:- My Functions
    
    func fetchChatsFromDB() -> Void
    {
        arrayExchange.removeAll()
        let array =  ChatDBManager.ChatDBManagerSharedInstance.fetchThreads()
        arrayExchange.append(contentsOf: array)
        tblChatThreads.reloadData()
        
        if array.count == 0
        {
            viewNoChats.isHidden = false
        }
        else
        {
            viewNoChats.isHidden = true
        }
        
        for i in 0..<arrayExchange.count
        {
            let exg = arrayExchange[i] as! ChatThreadModel
            let temp = ChatDBManager.ChatDBManagerSharedInstance.fetchLastChatMessages(threadId: exg.exchange)
            if temp.count > 0
            {
                let tempmsgObj = temp[0]
                exg.lastmessage = tempmsgObj.message
                exg.lastmessageType = tempmsgObj.type
                exg.lastMsgTime = tempmsgObj.chattimestamp as! Int64!
                //arrayExchange.replaceObject(at: i, with: exg)
                arrayExchange.remove(at: i)
                arrayExchange.insert(exg, at: i)
                //arrayExchange.replaceSubrange(i, with: exg)
            }
            
            let temp1 = ChatDBManager.ChatDBManagerSharedInstance.fetchAllDelivereChatMsgsWithSenderId(exchange: exg.exchange, status: "delivered", senderId: "")
            exg.unreadCount = temp1.count
        }
        
        arrayExchange = arrayExchange.sorted(by: { $0.lastMsgTime > $1.lastMsgTime })
    
    }

    
    // MARK: - IBActions

    @IBAction func btnBackAction(_ sender: UIButton)
    {
        _ = self.navigationController?.popViewController(animated: true)
    }
 
    
    
    // MARK:- TableView Delegates
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return self.arrayExchange.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let msgObj = self.arrayExchange[indexPath.row] as! ChatThreadModel
        
        let cell:ChatThreadTableCell = self.tblChatThreads.dequeueReusableCell(withIdentifier: "ChatThreadTableCell") as! ChatThreadTableCell!
        
        cell.lblName.text = msgObj.senderName
        
        cell.lblMessage.text = msgObj.lastmessage
        if msgObj.lastmessageType == "image"
        {
            cell.lblMessage.text = "📷 photo"
        }
        cell.lblUnreadCount.text = "\(msgObj.unreadCount!)"
        if (msgObj.unreadCount == 0)
        {
            cell.lblUnreadCount.isHidden = true
        }
        else
        {
            DataManager.dataManagerSharedInstance.roundedCornerlabel(label: cell.lblUnreadCount, radius: 13)
            cell.lblUnreadCount.isHidden = false
        }
        // Setting Image
        let imgStr = msgObj.senderImage!
        let url = NSURL(string: imgStr)
        let imageName = "user_profile_bg.png"
        let image = UIImage(named: imageName)
        cell.imgChat.sd_setBackgroundImage(with: url! as URL, for: UIControlState.normal, placeholderImage: image)
        return cell
    }

    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        
       // tableView.deselectRow(at: indexPath, animated: false)
        
        let exgObj = self.arrayExchange[indexPath.row] as! ChatThreadModel
        
        let storyboard = UIStoryboard(name: "Chatting", bundle: nil)
        let chatingVC :ChattingViewController = storyboard.instantiateViewController(withIdentifier: "ChattingViewController") as! ChattingViewController
        chatingVC.exchangename = exgObj.exchange
        
        let aaray = ChatDBManager.ChatDBManagerSharedInstance.fetchMembersFromDB(exchange: exgObj.exchange)
        if aaray.count > 0 {
            let mem = aaray[0]
            chatingVC.recipientId = mem.userId
        }
        
        self.navigationController?.pushViewController(chatingVC, animated: false)
        
    }

}
