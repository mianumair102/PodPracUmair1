//
//  AttendeesListViewController.swift
//  EventsApp
//
//  Created by Janbaz Ali on 3/22/17.
//  Copyright © 2017 Janbaz Ali. All rights reserved.
//

import UIKit
class AtendeesCell: UITableViewCell {
    @IBOutlet var lblName: UILabel!
    @IBOutlet var lblDesignation: UILabel!
    @IBOutlet var lblOrganization: UILabel!
    @IBOutlet var imgUser: UIImageView!
    @IBOutlet var imgChecked: UIImageView!
    
}
class AttendeesListViewController: UIViewController,UITableViewDataSource, UITableViewDelegate,UITextFieldDelegate{
    @IBOutlet var tblAtendees: UITableView!
    @IBOutlet var txtSearch: UITextField!
    
    @IBOutlet var viewForError: UIView!
    @IBOutlet var btnRefresh: UIButton!
    @IBOutlet var imgError: UIImageView!
    @IBOutlet var lblErroeMsg: UILabel!
    
    
    
    var arrayAtendees : NSMutableArray!
    var arrayWhoIsComing : NSMutableArray!
    var arraySearched : NSMutableArray!
    var activityVC : ActivityViewController!
    var whichOne = 0  // 0 for all and 1 for who's coming
    var isSearchinOn = false
   // var sessionId : String! // for who is coming in specified session
    
    // special variables for pagination
    var lastScrollPostionY = 0.0
    var  point : CGPoint!
    var isDataLoading = false
    var totalCount = 0
    var totalCountWhosComing = 0
    var totalSearching = 0
    var start = 0
    // special variables for pagination end
    
    override func viewDidLoad() {
        super.viewDidLoad()

//        let colorRed = UIColor(hexString: "#b71c1c")
//        let colorGreen = UIColor(hexString: "#8bc34a")
        point = CGPoint.init(x: 0, y: 0)
        
        arrayAtendees = NSMutableArray()
        arrayWhoIsComing = NSMutableArray()
        arraySearched = NSMutableArray()
        
        let storyboard = UIStoryboard(name: "Chatting", bundle: nil)
        activityVC  = storyboard.instantiateViewController(withIdentifier: "ActivityViewController") as! ActivityViewController
        self.apiCallForAtendees()
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    // MARK:- API Calls
    func apiCallForAtendees() -> Void {
        txtSearch.resignFirstResponder()
        self.activityVC.view.frame = self.view.frame
        self.view.addSubview(self.activityVC.view)
        
        let url:String = Constants.baseUrl+ApiLinks.getUsers
        let params:Constants.dictionaryStandard = Constants.dictionaryStandard()
        var header = Constants.dictionaryStandard()
        
//        if whichOne == 0 {
//            header["is_here"] = "N"
//            start = arrayAtendees.count
//        }
//        else
//        {
//            start = arrayWhoIsComing.count
//            header["is_here"] = "Y"
//        }
        
        if isSearchinOn {
            start = arraySearched.count
            let text: String = txtSearch.text!
            let encodedtext = text.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
            header["kw"] = encodedtext
        }
        
        header["start"] = "\(start)"
        
        header["rows"] = "50"
//        if sessionId != nil
//        {
//            header["session_id"] = sessionId
//        }
        
        isDataLoading = true
        
        NotificationCenter.default.addObserver(self, selector: #selector(callBackFromgetUsers(notification:)), name: Notification.Name(ApiLinks.getUsers), object: nil)
        let obj = NetworkCalls(link:url , notificationName:ApiLinks.getUsers, params:params , header:header , addUSerID:true)
        obj.getAPICall1()
    }
    

   
    
    // MARK: API  CallBacks
    
    @objc func callBackFromgetUsers(notification:NSNotification) -> Void
    {
        isDataLoading = false
        self.activityVC.view.removeFromSuperview()
        if(notification.name == Notification.Name(ApiLinks.getUsers))
        {
            let data = notification.userInfo as! Constants.jsonStandard
            let theFinalResponse = data["response"] as! Constants.jsonStandard
            print("The Final Response is :: \(theFinalResponse)")
            
            let code = theFinalResponse["code"] as! String
            if code == "11" {
                let tempArray = theFinalResponse["list"] as! NSArray
                let totalll = theFinalResponse["tot"] as! String
                if isSearchinOn {
                    arraySearched.addObjects(from: tempArray as! [Any])
                    totalSearching = Int(totalll)!
                    if arraySearched.count == 0
                    {
                        // let msg = theFinalResponse["message"] as! String
                        showNetNothingFound()
                    }
                    else
                    {
                        showTableView()
                    }
                }
                else if whichOne == 0 {
                    arrayAtendees.addObjects(from: tempArray as! [Any])
                    totalCount = Int(totalll)!
                    
                    if arrayAtendees.count == 0
                    {
                        // let msg = theFinalResponse["message"] as! String
                        showNetNothingFound()
                    }
                    else
                    {
                        showTableView()
                    }
                }
                else
                {
                    arrayWhoIsComing.addObjects(from: tempArray as! [Any])
                    totalCountWhosComing = Int(totalll)!
                    
                    if arrayWhoIsComing.count == 0
                    {
                        // let msg = theFinalResponse["message"] as! String
                        showNetNothingFound()
                    }
                    else
                    {
                        showTableView()
                    }
                }
                
                self.tblAtendees.reloadData()
                
                
               // self.apiCallForWhoIsComing()
            }
            else if code == "99" {
                
                if isSearchinOn {
                    
                    if arraySearched.count == 0
                    {
                        // let msg = theFinalResponse["message"] as! String
                        showNetWorkError()
                    }
                }
                else if whichOne == 0 {
                    
                    
                    if arrayAtendees.count == 0
                    {
                        // let msg = theFinalResponse["message"] as! String
                        showNetWorkError()
                    }
                }
                else
                {
                    
                    
                    if arrayWhoIsComing.count == 0
                    {
                        // let msg = theFinalResponse["message"] as! String
                       showNetWorkError()
                    }
                }
                
                
            }
            else
            {
                if isSearchinOn {
                    
                    if arraySearched.count == 0
                    {
                        // let msg = theFinalResponse["message"] as! String
                        showNetNothingFound()
                    }
                }
                else if whichOne == 0 {
                    
                    
                    if arrayAtendees.count == 0
                    {
                        // let msg = theFinalResponse["message"] as! String
                        showNetNothingFound()
                    }
                }
                else
                {
                   
                    
                    if arrayWhoIsComing.count == 0
                    {
                        // let msg = theFinalResponse["message"] as! String
                        showNetNothingFound()
                    }
                }
                
               
            }
            
        }
        
        // Removing the Observer
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: ApiLinks.getUsers), object: nil)
    }
    

    // MARK:- Alert
    
    func showAlert(msg: String) -> Void {
        let alert = UIAlertController(title: Constants.appName, message: msg, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    //MARK:- My Functions
    
    func showNetWorkError() -> Void {
        tblAtendees.isHidden = true
        viewForError.isHidden = false
        imgError.image = UIImage(named: "no-network-icon.png")
        btnRefresh.isHidden = false
        lblErroeMsg.text = "Please check your internet connection and try again."
    }
    func showNetNothingFound() -> Void {
        tblAtendees.isHidden = true
        viewForError.isHidden = false
        imgError.image = UIImage(named: "no_attendees_icon.png")
        btnRefresh.isHidden = true
        lblErroeMsg.text = "No Attendees Found"
        
    }
    func showTableView() -> Void {
        tblAtendees.isHidden = false
        viewForError.isHidden = true
        btnRefresh.isHidden = true
        
    }
    func callApiAgain() -> Void {
        if whichOne == 0 {
            self.btnAllAttendeesAction(self)
        }
        else
        {
            self.btnWhosComingAction(self)
        }
    }
    // MARK:- IBActions
    
    @IBAction func btnBackAction(_ sender: Any) {
        _ = self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func btnAllAttendeesAction(_ sender: Any) {
    
        whichOne = 0
        showTableView()
        isSearchinOn = false
        txtSearch.text = ""
//        if isSearchinOn {
//            if arraySearched.count > 0  {
//                
//                arraySearched.removeAllObjects()
//            }
//            self.apiCallForAtendees()
//        }
//        else
//        {
            if arrayAtendees.count == 0 {
                self.apiCallForAtendees()
            }
        //}
        
        tblAtendees.reloadData()
        
    }
    @IBAction func btnWhosComingAction(_ sender: Any) {
        
         whichOne = 1
        
        showTableView()
        isSearchinOn = false
        txtSearch.text = ""
//        if isSearchinOn {
//            if arraySearched.count > 0  {
//                arraySearched.removeAllObjects()
//            }
//            self.apiCallForAtendees()
//        }
//        else
//        {
            if arrayWhoIsComing.count == 0 {
                self.apiCallForAtendees()
            }
       // }
    
        
        tblAtendees.reloadData()
        
    }
    @IBAction func btnSearchAction(_ sender: Any) {
        if !(txtSearch.text?.isEmpty)!
        {
            if arraySearched.count > 0 {
                arraySearched.removeAllObjects()
            }
            isSearchinOn = true
            self.apiCallForAtendees()
        }
        else
        {
            self.showAlert(msg: "Please enter something to search")
        }
        
    }
    
    @IBAction func btnClearAction(_ sender: Any) {
        
        isSearchinOn = false
        txtSearch.text = ""
        self.callApiAgain()
        
    }
    @IBAction func btnRefreshAction(_ sender: Any) {
       self.callApiAgain()
    }
    
    
    

    // MARK:- TableView Delegates
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if isSearchinOn {
            return arraySearched.count
            
        }
        else if whichOne == 1 {
           return arrayWhoIsComing.count
            
        }
        
        return arrayAtendees.count
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        var atendee :   Constants.jsonStandard!
        
        if isSearchinOn {
            atendee =  arraySearched[indexPath.row] as! Constants.jsonStandard
            
        }
        else if whichOne == 1 {
            atendee =  arrayWhoIsComing[indexPath.row] as! Constants.jsonStandard
            
        }
        else
        {
            atendee =  arrayAtendees[indexPath.row] as! Constants.jsonStandard
        }
        
        
        let cell:AtendeesCell = self.tblAtendees.dequeueReusableCell(withIdentifier: "AtendeesCell") as! AtendeesCell!
        
        cell.lblName.text = atendee["first_name"] as! String + " \(atendee["last_name"] as! String)"
        cell.lblDesignation.text = atendee["designation"] as? String
        cell.lblOrganization.text = atendee["organization"] as? String
        
//        let iscoming = atendee["is_comming"] as! String
//        
//        if iscoming == "N" {
//            cell.imgChecked.isHidden = true
//        }
//        else
//        {
//            cell.imgChecked.isHidden = false
//        }
        
        let imgStr = atendee["image"] as! String
        // Setting Image
        let url = NSURL(string: imgStr)
        let imageName = "user_profile_bg.png"
        let image = UIImage(named: imageName)
        DataManager.dataManagerSharedInstance.roundedCornerImage(image: cell.imgUser, radius: 35)
        cell.imgUser.sd_setImage(with: url! as URL, placeholderImage: image!)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        
        return 90
        
        ;
    }
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        tableView.deselectRow(at: indexPath, animated: false)
        
        var userdata = arrayAtendees[indexPath.row] as! Constants.jsonStandard
        let userID = userdata["auto_id"] as! String
        
        if userID != UserDefaults.standard.value(forKey: Constants.kChatUserId) as? String
        {
            if isSearchinOn {
                userdata =  arraySearched[indexPath.row] as! Constants.jsonStandard
                
            }
            else if whichOne == 1 {
                userdata =  arrayWhoIsComing[indexPath.row] as! Constants.jsonStandard
                
            }
            else
            {
                userdata =  arrayAtendees[indexPath.row] as! Constants.jsonStandard
            }
            
            
            let userArray  = ChatDBManager.ChatDBManagerSharedInstance.fetchMemberWithUserId(userId: userdata["auto_id"] as! String)
            let storyboard = UIStoryboard(name: "Chatting", bundle: nil)
            let chatingVC :ChattingViewController = storyboard.instantiateViewController(withIdentifier: "ChattingViewController") as! ChattingViewController
            chatingVC.recipientId = userdata["auto_id"] as! String
            chatingVC.recieverName = userdata["first_name"] as! String + " \(userdata["last_name"] as! String)"
            
            if userArray.count > 0 {
                let user = userArray[0];
                chatingVC.exchangename = user.exchange
            }
            
            chatingVC.recieverImage = userdata["image"] as! String
            self.navigationController?.pushViewController(chatingVC, animated: false)
        }
    }
    
    
    
    
    // MARK:- Scroll Delegates
    
    
    func scrollViewDidScroll(_ scrollView: UIScrollView)
    {
        //lastScrollPostionY = scrollView.contentOffset.y;
        if(scrollView.contentOffset.y > point.y)
        {
            let bottomEdge = Int(scrollView.contentOffset.y + scrollView.frame.size.height);
            let LoadedHeight = Int(scrollView.contentSize.height)-200;
            
            if (bottomEdge >=  LoadedHeight )
            {
                if(!isDataLoading)
                {
                    if isSearchinOn
                    {
                        if totalSearching > arraySearched.count {
                            
                            self.apiCallForAtendees()
                        }
                    }
                    else if whichOne == 1
                    {
                        if totalCountWhosComing > arrayWhoIsComing.count {
                            
                            self.apiCallForAtendees()
                        }
                    }
                    else
                    {
                        if totalCount > arrayAtendees.count {
                            self.apiCallForAtendees()
                        }
                        
                    }
                }
            }
        }
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView)
    {
        
        point = scrollView.contentOffset;
        lastScrollPostionY = Double(scrollView.contentOffset.y);
    }
    
    
    // MARK:- TextField Delegates
    
    public func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool
    {
        
        
        return true
    }
    
    public func textFieldShouldReturn(_ textField: UITextField) -> Bool
    {
        txtSearch.resignFirstResponder()
        
        
        return true
    }
    
    public func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool
    {
        if (!string.isEmpty) {
            if textField == txtSearch && (textField.text?.characters.count)! < 100 {
                return true
            }
            
            else
            {
                return false
            }
        }
        else if (txtSearch.text?.characters.count == 1)
        {
            btnClearAction(self)
        }
        return true
    }
}
