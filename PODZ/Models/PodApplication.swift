//
//  PodApplication.swift
//  PODZ
//
//  Created by Nick Miller on 2/2/21.
//  Copyright © 2021 Nick Miller. All rights reserved.
//

import Foundation
import Firebase

class PodApplication: Codable {
    
    var appID: String
    var daysOfTheWeek: [Bool] //length 7 array of 1s and 0s
    var timeOfDay: Int? //HHMM in GMT
    var catagory: String?
    var subCatagory: String?
    var UID : String?
    var reminderPhrase: String?
    var logPhrase: String?
    var userBannedList: [String]?
    var myTimestamp: Timestamp
    var secondsFromGMT: Int?
    var friendIDs: [String]?
    var associatedPod: String?
    var commitmentLength: Int?
    var friendInviteMessage: String?
    var isFriendPodLocked: Bool?
//    var podName: String?
    
    init(days: [Bool], time: Int, catagory: String, subCatagory: String?, UID: String, reminderPhrase: String, logPhrase: String, bans: [String], currentTime: Timestamp, secondsFromGMT: Int, friendIDs: [String]?, associatedPod: String?, commitmentLength: Int, friendInviteMessage: String, isFriendPodLocked: Bool?) {
        
        self.appID = UUID().uuidString
        self.daysOfTheWeek = days
        self.timeOfDay = time
        self.catagory = catagory
        if subCatagory != nil {
            self.subCatagory = subCatagory
        }
        self.UID = UID
        self.reminderPhrase = reminderPhrase
        self.logPhrase = logPhrase
        self.userBannedList = bans
        self.myTimestamp = currentTime
        self.secondsFromGMT = secondsFromGMT
        self.friendIDs = friendIDs
        self.associatedPod = associatedPod
        self.commitmentLength = commitmentLength
        self.friendInviteMessage = friendInviteMessage
        self.isFriendPodLocked = isFriendPodLocked
        //self.timeOfDayAsDate = timeOfDayAsDate
    }
    init(currentTime: Timestamp){
        self.appID = UUID().uuidString
        self.daysOfTheWeek = [Bool](repeating: false, count: 7)
        self.timeOfDay = nil
        self.catagory = nil
        self.subCatagory = nil
        self.reminderPhrase = nil
        self.logPhrase = nil
        self.userBannedList = nil
        self.myTimestamp = currentTime
        self.secondsFromGMT = nil
        self.friendIDs = nil
        self.associatedPod = nil
        self.UID = nil
        self.commitmentLength = 30
        self.friendInviteMessage = "Join my habit group!"
        //self.timeOfDayAsDate = nil
        
    }
    
    
}
