//
//  message.swift
//  PODZ
//
//  Created by Nick Miller on 6/16/20.
//  Copyright © 2020 Nick Miller. All rights reserved.
//

import Foundation
import Firebase
import FirebaseFirestore
import FirebaseFirestoreSwift



struct Message: Identifiable, Codable, Hashable {
     
    //var id: Int //looks like id : [text, senderID, type, timestamp]
    var text: String
    var senderID: String
    var type: String
    var newDay: Bool
    var id: Timestamp
    var messageID: String
    
    init(text: String, senderID: String, type: String, timeStamp: Timestamp, isNewDay : Bool, messageID: String){
        self.id = timeStamp
        self.text = text
        self.senderID = senderID
        self.type = type
        self.newDay = isNewDay
        self.messageID = messageID
        //self.timeStamp = timeStamp
    }
    
}
//
//func dataToDisplayMessages(pod: Pod) -> [displayMessage] {
//
//    var displayMessageList: [displayMessage] = []
//    var counter: Int = 0
//    for mess in pod.messages{
//
//        displayMessageList.append(displayMessage(id: counter, text: mess[1], sender: mess[0], type: mess[2], timeStamp: Date()))
//        counter = counter + 1
//    }
//    return displayMessageList

