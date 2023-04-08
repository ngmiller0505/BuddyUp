//
//  Pod.swift
//  PODZ
//
//  Created by Nick Miller on 6/15/20.
//  Copyright © 2020 Nick Miller. All rights reserved.
//

import Foundation
import FirebaseFirestore

class Pod: Identifiable, Codable, Equatable {
  
        static func == (lhs: Pod, rhs: Pod) -> Bool {
            return lhs.podID == rhs.podID
        }

    
    let podID: String
    let podName: String
    var memberAliasesAndIDs : [String : String] //a
    var memberAliasesAndScore: [String: Int] //dictionary of memberID: score //CHANGES REGULARLY
    var memberAliasesAndColorCode : [String : Int]
    var memberAliasesAndName: [String:String]
//    var somethingNew : Int
    var memberAliasesAndSchedule: [String: [Bool]] //dictionary of {memberID: [true, false, true, false, true ,false , false]} seven booleans describing on and off days
    var memberAliasesAndReminderPhrase: [String: String]
    var memberAliasesAndLogPhrase: [String: String] //dictionary of {memberAlias: string}, ex: {"a": "lets go", "b" : "time to win!"}
    var memberAliasesAndTime: [String: Int] //dictionary of {memberAlias: int} ex {"a" : 0845} (for 8:45am GMT) 
    var communityOrFriendGroup: String //Gives "Friend" if friend. gives "Community" if community (would be an enum but enums don't behave well with firestore)
    var habit : String? //If community group has specific unifying habit, give habit type, else give nil. if friend group (for now) automatically give nil
    var memberAliasesAndHasLogged: [String: Bool] //CHANGES REGULARLY
    var invitedFriendIDs: [String]?
    var dayNumber: Int
    var dayLimit: Int
    var memberAliasesAndSecondsFromGMT: [String: Int]
    var memberAliasesAndHabitDays : [String: Int]
    var memberAliasesAndHabit : [String : String]
    var memberAliasesAndSomethingNew : [String : Bool] //CHANGES REGULARLY
    var dateCreated: Timestamp?
    

    
    init(id:String, n: String, memberScoreDict: [String: Int], memberNameDict: [String: String], memberScheduleDict: [String: [Bool]], memberPhraseDict: [String:String], memberTimeDict: [String: Int], communityOrFriend: String, habit: String? , memberAliasesAndIDs: [String : String], memberColorDict: [String: Int], memberAliasHasLogged: [String: Bool], memberAliasLogPhrase: [String: String], dayNumber: Int, dayLimit: Int, memberAliasesAndSecondsFromGMT: [String: Int], memberAliasesAndHabitDays: [String: Int], memberAliasesAndHabit : [String : String], memberAliasesAndSomethingNew : [String : Bool]) {
        self.podName = n
        //self.messages = m
//        self.somethingNew = 4
        self.memberAliasesAndScore = memberScoreDict
        self.memberAliasesAndColorCode = memberColorDict
        self.memberAliasesAndName = memberNameDict
        //self.podID = UUID().uuidString
        self.memberAliasesAndSchedule = memberScheduleDict
        self.memberAliasesAndReminderPhrase = memberPhraseDict
        self.memberAliasesAndTime = memberTimeDict
        self.podID = id
        self.communityOrFriendGroup = communityOrFriend
        self.habit = habit
        self.memberAliasesAndIDs = memberAliasesAndIDs
        self.memberAliasesAndHasLogged = memberAliasHasLogged
        self.memberAliasesAndLogPhrase = memberAliasLogPhrase
        self.dayNumber = dayNumber
        self.dayLimit = dayLimit
        self.memberAliasesAndSecondsFromGMT = memberAliasesAndSecondsFromGMT
        self.memberAliasesAndHabitDays = memberAliasesAndHabitDays
        self.memberAliasesAndHabit = memberAliasesAndHabit
        self.memberAliasesAndSomethingNew = memberAliasesAndSomethingNew
        
    }
}
