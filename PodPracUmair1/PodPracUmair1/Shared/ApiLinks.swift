//
//  Constants.swift
//  SeekerSwift1
//
//  Created by Mian Umair Nadeem on 11/01/2017.
//  Copyright © 2017 Mian Umair Nadeem. All rights reserved.
//

import Foundation

struct ApiLinks
{
    
    // MARK: Sign In Link
    static let signInUrl:String = "users/login"
    
    // MARK: Heartbeat
    static let hearbeatUrl:String = "heartbeat"
    
    
    
    // MARK:- Templates
    static let getSpeakersUrl:String = "speakers"
    
    // MARK:- Whos coming
    static let getAtendees:String = "users/comming"
    
    // MARK:- whos coming
    static let getWhosComingUrl:String = "users/comming"
    
    // MARK:- EditPostedJob
    static let getBreakoutSessions:String = "session"
    
    // MARK:- EditPostedJob
    static let getEventsUrl:String = "session/schedule"
    
    // MARK:- City Areas
    static let getOpinionPolls:String = "users/polls"
    
    // MARK:- City Areas
    static let postOpinionPollUrl:String = "users/savepoll"
    
    // MARK:- Update Profile
    static let updateProfileUrl:String = "users/updateprofile"
    
    // MARK:- Ask A Question
    static let askQuestionUrl:String = "session/addquestion"
    
    // MARK:- Rate Session
    static let rateSessionUrl:String = "session/rate"
    
    // MARK:- Reset password
    static let resetPasswordUrl:String = "users/resetpassword"
    
    // MARK:- Change password
    static let changePasswordUrl:String = "users/changepassword"
    
    // MARK:- BreakoutSession Details
    static let breakoutSessionDetailsUrl:String = "session/detail"
    
    // MARK:- Update Profile
    static let getProfileUrl:String = "users/profile"
    
    // MARK:- Check IN
    static let checkInUrl:String = "users/checkin"
    
    // MARK:- Register/Unregister
    static let registerUrl:String = "session/register"
    
    // MARK:- Search Companies
    static let getCompaniesUrl:String = "companies"
    
    // MARK:- Get Notifications
    static let getNotificationsUrl:String = "notification"
    
    // MARK:- Get Notifications
    static let logOutUrl:String = "users/logout"
    
    // MARK:- Register Push API
    static let registerPushUrl:String = "users/gcm"
    
    // MARK:- Register Push API
    static let getSpeakersDetailsUrl:String = "speakers/detail"
    
    // MARK:- Start Chat
    static let startChatUrl:String = "chat/start"
    
    // MARK: StatusUpdate
    static let statusUpdateUrl:String = "chat/updateStatus"
    
    // MARK:- SignUp User
    static let signUpUser:String = "users/register"
    
    // MARK:- Past Events
    static let getPastEvents:String = "event/"
    
    // MARK:- Report
    static let report:String = "users/feedback"
    
    // MARK:- DashBoard
    static let dashBoard:String = "event/dashboard"
    
    // MARK:- Event Details
    static let eventDetailsUrl:String = "event/detail"
    
    // MARK:- Event Register
    static let eventRegisterUrl:String = "event/register"
    
    // MARK:- Event Register from listing
    static let eventRegisterUrlListing:String = "event/register"
    
    
    // MARK:- Get users for Chat
    static let getUsers:String = "users"
    
    // MARK:- Block user api
    static let blockUser:String = "chat/blockMember"
    
    
    // MARK:- unblockUser  api
    static let unblockUser:String = "chat/unblock"
    
    // MARK:- Upload Chat Image
    static let uploadChatImage:String = "chat/uploadImage"
}
