//
//  UserObject.swift
//  EventsApp
//
//  Created by Janbaz Ali on 3/24/17.
//  Copyright © 2017 Janbaz Ali. All rights reserved.
//

import UIKit
import SDWebImage
class UserObject: NSObject {

    public
    var email : String!
    var first_name :String!
    var last_name :String!
    var image_name : String!
    var picture : UIImage!
    var career_level : String!
    var career_level_id : String!
    var designation : String!
    var experience : String!
    var experience_id : String!
    var gender : String!
    var gender_id : String!
    var industry : String!
    var industry_id : String!
    var mobile : String!
    var organization : String!
    var organizationId : String!
    var rsvp_status : String!
    var summary : String!
    var event_id : String!
    var getAlerts : String!
    var arraySkills : NSMutableArray!
    var is_checkedin : String!
    var is_profile_edited : String!
    var show_PhoneNo : String!
   
    override init() {
        
        super.init()
        print("constructor called")
        makeMyselfEmpty()
    }
    
    public
    func makeMyselfEmpty ()
    {
         email = ""
         first_name = ""
         last_name = ""
         image_name = ""
         picture = UIImage()
        
         career_level = ""
         career_level_id = ""
         designation = ""
        
         experience = ""
         experience_id = ""
         gender = ""
         gender_id = ""
         industry = ""
         industry_id = ""
         mobile = ""
         organization = ""
        organizationId = ""
        
         rsvp_status = ""
         summary = ""
         event_id = ""
        getAlerts = ""
        is_checkedin = ""
        is_profile_edited = ""
        show_PhoneNo = ""
        arraySkills = NSMutableArray()
        
    }
    
    func printMyValues() -> Void {
        
    }
    
    func updateMyselfWithNewData (data : Constants.jsonStandard)
    {
        print("\(data)")
        email = data["email"] as! String
        first_name = data["first_name"] as! String
        last_name = data["last_name"] as! String
        image_name = data["picture"] as! String
        picture = UIImage()
        
         if ((data["career_level"] as? String) != nil) {
             career_level = data["career_level"] as! String
        }
        if ((data["industry"] as? String) != nil) {
            industry = data["industry"] as! String
        }
        
        career_level_id = data["career_level_id"] as! String
        designation = data["designation"] as! String
        experience = data["experience"] as! String
        experience_id = data["experience_id"] as! String
        gender = data["gender"] as! String
        gender_id = data["gender_id"] as! String
        industry_id = data["industry_id"] as! String
        mobile = data["mobile"] as! String
        organization = data["organization"] as! String
        organizationId = data["organization_id"] as! String
        if data["rsvp_status"] is String{
            rsvp_status = data["rsvp_status"] as! String
        }else{
            rsvp_status = ""
        }
        
        summary = data["summary"] as! String
        if ((data["event_id"] as? String) != nil) {
             event_id = data["event_id"] as! String
        }
       
        getAlerts = data["recieve_job_alerts"] as! String //recieve_job_alerts
        if ((data["is_checkedin"] as? String) != nil) {
            is_checkedin = data["is_checkedin"] as! String
        }
        
        is_profile_edited = data["is_profile_edited"] as! String
        show_PhoneNo = data["show_mobile"] as! String
        let temp = data["skills"] as! NSArray
        if self.arraySkills.count > 0 {
            self.arraySkills.removeAllObjects()
        }
        for i in 0..<temp.count
        {
            let skill = temp[i] as! Constants.jsonStandard
            var updatedSkill =  Constants.jsonStandard()
            updatedSkill["displayName"] = skill["skill_name"] as! String as AnyObject?
            updatedSkill["value"] = skill["skill_id"] as! String as AnyObject?
            arraySkills.add(updatedSkill)
        }
        
    }
    
    
}

