//
//  MessengerViewModel.swift
//  PODZ
//
//  Created by Nick Miller on 10/25/20.
//  Copyright © 2020 Nick Miller. All rights reserved.
//

import Foundation
import SwiftUI
import FirebaseFirestore
import FirebaseFirestoreSwift



class MessengerViewModel: ObservableObject {
    
    @Published var observableMessages : [Message]
    @Published var totalMessageHeight : CGFloat =  0
    @Published var lastMessageTimestamp: Timestamp?
    let userID: String
    let podWrapper: PodWrapper
    var listener: ListenerRegistration?
    var loadLimitNumber = 40
    var firstTimeStampLoaded: Timestamp?
    
    init(podWrapper: PodWrapper, userID: String){
//        observableMessages = dataToDisplayMessages(pod: testPod)
        self.userID = userID
        self.podWrapper = podWrapper
        observableMessages = []
//        print("Start to listen")
        startToListen(podID: podWrapper.podID)
    }
    
    deinit {
        print("DEINIT MESSAGES VIEW MODEL")
        observableMessages = []
        if listener != nil {
            listener!.remove()
        }
        
    }
    
    func addLocalMessageToModel(message: Message) {
        
        
        
        if self.observableMessages.isEmpty {
            self.firstTimeStampLoaded = message.id
        }
        
        var messageHeight = getHeightOfMessage(messagesCurrentlyDisplaying: message)
        if message.newDay {
            messageHeight = messageHeight + 40
        }
        if message.senderID != userID && message.type == "chat" {
            //print("ADDING HEIGHT FOR CHAT FROM OTHER USER")
            messageHeight = messageHeight + 30
        }
        let height = getHeightOfMessage(messagesCurrentlyDisplaying: message)
        totalMessageHeight += height
        //print("ADDING LOCAL MESSAGE WITH HEIGHT: ", height)
//        print("added message, total message height is now: ", totalMessageHeight)
    }
    
    func addServerMessageToModel(message: Message) {

        
        if self.observableMessages.isEmpty {
            self.firstTimeStampLoaded = message.id
        }
        
        observableMessages.append(message)
        
        
        var messageHeight = getHeightOfMessage(messagesCurrentlyDisplaying: message)

        if message.senderID != userID && message.type == "chat"{
            
            messageHeight = messageHeight + 30
//            print("ADDING SENDER NAME TO INCOMING CHAT: ", messageHeight)
        }
        if message.newDay {
            messageHeight = messageHeight + 40
//            print("ADDING NEW DAY BANNER TO CHAT: ", messageHeight)
        }
        
        totalMessageHeight += messageHeight
//        print("ADDING SERVER MESSAGE WITH HEIGHT: ", messageHeight)
//        print("NEW TOTAL HEIGHT MESSAGE HEIGHT: ", totalMessageHeight)
    }
    
    
    func getHeightOfMessage(messagesCurrentlyDisplaying : Message) -> CGFloat {
        
        let text = messagesCurrentlyDisplaying.text
        
        var currentWord = ""
        var currentLineCount = 0
        var lines = 1
        //var previouslyAddedEnter = false
        

        for i in 0..<text.count {
            
            
            if text[i] == " " || (text[i..<i + 1]).contains("\n") {
                //print("in new word")
                if (currentLineCount + currentWord.count >= 61) {
                    lines += 1
                    //print("adding new line for TEXT, which puts this on next line: ", currentWord)
                    currentLineCount = currentWord.count + 1
                    //previouslyAddedEnter = false
                    currentWord = ""
                } else {
//                    print("current line count: ",currentLineCount)
//                    print(currentWord)
//                    print(currentWord.count)
                    currentLineCount = currentLineCount + currentWord.count + 1
                    currentWord = ""
                }
                
            }
            if (text[i..<i + 1]).contains("\n") {
                lines += 1
                //print("adding new line for ENTER")
                //previouslyAddedEnter = true
                currentLineCount = 0
                currentWord = ""
            }
            else {
                currentWord = currentWord + String(text[i])
            
            }
        }
        
        
        var height = 0
        
        if messagesCurrentlyDisplaying.type == "chat" {
            height = 16 * lines + 48
        }
        else if messagesCurrentlyDisplaying.type == "bot intro" {
            height = 16 * lines + 48 + 120
        }
        else if messagesCurrentlyDisplaying.type == "Info" {
            height = 120
            
        } else {
            if  messagesCurrentlyDisplaying.type == "verify" || messagesCurrentlyDisplaying.type == "Missing Verify" {

                let alias = podWrapper.getAliasFromUID(UID: messagesCurrentlyDisplaying.senderID) ?? "none"
                let phrase = podWrapper.currentPod!.memberAliasesAndLogPhrase[alias]
                //print("PHRASE FOR VERIFY: ", phrase)
                if phrase != nil {
                    if phrase!.count > 31 {
//                        print("ITS A TWO LINE PHRASE")
                        height = height + 22
                    }
                    
                }
                height = height + 16 * lines + 94
               
            }
        }
//        print("NUMBER OF LINES: ", lines)
//        print("HEIGHT OF CURRENT MESSAGE: ", height)
//        print("HEIGHT OF ALL MESSAGES: ", totalMessageHeight)
        return CGFloat(height)
    }
    //add message listener for from firebase to update observable messages
    
    func startToListen(podID: String) {
        
        let db = Firestore.firestore()
        
        listener = db.collection("messages").document(podID).collection(podID).order(by: "id").addSnapshotListener { (querySnapshot, error) in
            
            
            guard let document = querySnapshot else {
                print("Error fetching document: \(error!)")
                return
            }

            
            
            //let source = document.metadata.hasPendingWrites ? "Local" : "Server"

            for i in 0..<document.documentChanges.count {
                
               
                let result = Result {
                    try document.documentChanges[i].document.data(as: Message.self)
                    }
                    switch result {
                    case .success(let message):
                        if let message = message {
                            // A `City` value was successfully initialized from the DocumentSnapshot.
                            //print("MESSAGE LOADED: \(message)")
                            let source = document.metadata.hasPendingWrites ? "Local" : "Server"
                            if source == "Server"{
                                //print("from Server")
                                self.addServerMessageToModel(message: message)


                            }
//                            else {
//                                print("from local")
//                            }
                        } else {
                            // A nil value was successfully initialized from the DocumentSnapshot,
                            // or the DocumentSnapshot was nil.
                            print("MESSAGE DOES NOT EXIST")

                        }
                    case .failure(let error):
                        // A `City` value could not be initialized from the DocumentSnapshot.
                        print("Error decoding message: \(error)")
                    }
            }
        }
    }

    func addMessageToFirestore(podID : String, message: Message) {
        
        var lastMissingForUser: Message?
        let db = Firestore.firestore()
        //let requiresNewDay = requiresNewDayMessage(newMessageTimestamp: message.id)
        
        if message.type == "verify" {

            lastMissingForUser = self.observableMessages.first(where: { mess in
                print("MISSING VERIFY TIMESTAMP: ", mess.id)
                print("NEW VERIFY TIMESTAMP: ", message.id)
                print("message.id.dateValue().timeIntervalSince1970.magnitude: ", message.id.dateValue().timeIntervalSince1970.magnitude)
                print("mess.id.dateValue().timeIntervalSince1970.magnitude: ", mess.id.dateValue().timeIntervalSince1970.magnitude)
                let timeConditional =  message.id.dateValue().timeIntervalSince1970.magnitude - mess.id.dateValue().timeIntervalSince1970.magnitude < 12 * 3600
                let userMissingConditional = mess.type == "Missing Verify" && mess.senderID == self.userID
                print("timeConditional: ", timeConditional)
                print("userMissingConditional: ", userMissingConditional)
                return timeConditional && userMissingConditional
            })
            
//            let isThereMissingVerifyInThePast12Hours = missingVerifyForUser.filter { mess in
//                print("MISSING VERIFY TIMESTAMP: ", mess.id)
//                print("NEW VERIFY TIMESTAMP: ", message.id)
//                print("message.id.dateValue().timeIntervalSince1970.magnitude: ", message.id.dateValue().timeIntervalSince1970.magnitude)
//                print("mess.id.dateValue().timeIntervalSince1970.magnitude: ", mess.id.dateValue().timeIntervalSince1970.magnitude)
//                let timeConditional =  message.id.dateValue().timeIntervalSince1970.magnitude - mess.id.dateValue().timeIntervalSince1970.magnitude > 12 * 3600
//                print("timeConditional: ", timeConditional)
//                return timeConditional
//            }
            
            
            if lastMissingForUser != nil {
                print("THERES A RECENT MISSING THAT NEEDS TO BE REPLACED BY A VERIFY. NO NEED TO ADD TO MODEL BECUASE HEIGHT IS ALREADY CALCULATED")
                print("THIS IS THE USER MISSING: ", lastMissingForUser!)
                //THERES A RECENT MISSING THAT NEEDS TO BE REPLACED BY A VERIFY. NO NEED TO ADD TO MODEL BECUASE HEIGHT IS ALREADY CALCULATED
                let index = observableMessages.firstIndex(of: lastMissingForUser!)!
                //lastMissingForUser = observableMessages[index]
                
                observableMessages[index].type = message.type
                observableMessages[index].text = message.text
                //observableMessages[index].newDay = requiresNewDay

                db.collection("messages").document(podID).collection(podID).document(lastMissingForUser!.messageID).updateData(
                        [
                            "type" : message.type,
                            "text" : message.text
                        ])
                    { err in
                    if err == nil{
                        print("MISSING VERIFY UPDATED TO VERIFY: \(self.observableMessages[index])")
                        print("For podID \(podID)")
                    } else {
                        print("error inside try: \(String(describing: err))")
                    }
                }
            

                print("observableMessages.firstIndex(of: lastMissingForUser!)! = ", index)
            } else {
                //THERES NO RECENT MISSING SO JUST ADD NEW VERIFY
                print("THERES NO RECENT MISSING SO JUST ADD NEW VERIFY")
                addLocalMessageToModel(message: message)
                observableMessages.append(message)
                do {
                    try db.collection("messages").document(podID).collection(podID).document(message.messageID).setData(from: message) { err in
                    if err == nil{
                        print("NEW VERIFY MESSAGE ADDED TO FIRESTORE: \(message)")
                        print("For podID \(podID)")
                    } else {
                        print("error inside try: \(String(describing: err))")
                    }
                }
            }
            catch let error {
                    print("error outside try: \(error)")
                }
                
                
            }
        } else  {
            //THIS IS A CHAT MESSAGE
            print("THIS IS A CHAT MESSAGE")
            addLocalMessageToModel(message: message)
            observableMessages.append(message)
            
            do {
                try db.collection("messages").document(podID).collection(podID).document(message.messageID).setData(from: message) { err in
                if err == nil{
                    print("CHAT MESSAGE ADDED TO FIRESTORE: \(message)")
                    print("For podID \(podID)")
                } else {
                    print("error inside try: \(String(describing: err))")
                }
            }
        }
        catch let error {
                print("error outside try: \(error)")
        }
            
        }
        
        //ONCE WE'VE ADDED LOCALLY, UPDATE FIRESTORE
        
//        do {
//            try db.collection("messages").document(podID).collection(podID).document(lastMissingForUser?.messageID ?? message.messageID).setData(from: message) { err in
//            if err == nil{
//                print("MESSAGE ADDED TO FIRESTORE: \(message)")
//                print("For podID \(podID)")
//            } else {
//                print("error inside try: \(String(describing: err))")
//            }
//        }
//    }
//    catch let error {
//            print("error outside try: \(error)")
//    }

    }

//    func requiresNewDayMessage(oldTimeStamp: Timestamp, newTimeStamp: Timestamp)  -> Bool {
//    //    print(oldTimeStamp, newTimeStamp, oldTimeStamp.compare(newTimeStamp).rawValue)
//        print(oldTimeStamp.dateValue(), newTimeStamp.dateValue(), oldTimeStamp.compare(newTimeStamp).rawValue)
//        if oldTimeStamp.compare(newTimeStamp).rawValue == 0 {
//            print("RETURNED IDENTICAL TIMESTAMP. SHOULD ONLY BE HAPPENING ON FIRST MESSAGE. PLACE TIME MESSAGE")
//            return true
//        }
//        let oldDate = dateNumber(myDateString: timeStampToLongString(timeStamp: oldTimeStamp))
//        let newDate = dateNumber(myDateString: timeStampToLongString(timeStamp: newTimeStamp))
//
//        print("timeStampToLongString(timeStamp: oldTimeStamp): ", timeStampToLongString(timeStamp: oldTimeStamp))
//        print("timeStampToLongString(timeStamp: newTimeStamp): ", timeStampToLongString(timeStamp: newTimeStamp))
//        return oldDate != newDate
//
//    }
    
    func requiresNewDayMessage(newMessageTimestamp: Timestamp) -> Bool {
        let lastNewDayMessage = observableMessages.last { mess in
            return mess.newDay
        }
        if lastNewDayMessage != nil {
            
            let oldDate = dateNumber(myDateString: timeStampToLongString(timeStamp: lastNewDayMessage!.id))
            let newDate = dateNumber(myDateString: timeStampToLongString(timeStamp: newMessageTimestamp))
//              print("timeStampToLongString(timeStamp: oldTimeStamp): ", timeStampToLongString(timeStamp: lastNewDayMessage!.id))
//              print("timeStampToLongString(timeStamp: newTimeStamp): ", timeStampToLongString(timeStamp: newMessageTimestamp))
            return oldDate != newDate
            
        } else {
            
            return true
        }
       
    }


}



func timeStampToLongString(timeStamp: Timestamp) -> String {
    
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
    let myString = formatter.string(from: timeStamp.dateValue())
    
    return myString
    
}
    
func timeAsHHMMIntToStringInSentance(timeAsHHMM: Int) -> String {
    

    if timeAsHHMM >= 1300 {
        var timeAsHHMMCopy = timeAsHHMM
        timeAsHHMMCopy = timeAsHHMM - 1200
        let asString = String(timeAsHHMMCopy)
        let minutes = String(asString.suffix(2))
        var hours = asString
        _ = hours.popLast()
        _ = hours.popLast()
        var timeString = hours + ":" + minutes
        timeString = timeString + "pm"
        
        return timeString
    } else if timeAsHHMM >= 1200 {
        
        let asString = String(timeAsHHMM)
        let minutes = String(asString.suffix(2))
        let hours = String(12)
        var timeString = hours + ":" + minutes
        timeString = timeString + "pm"
        return timeString
        
    }
    else if timeAsHHMM < 100 {
       
        let minutes = String(timeAsHHMM)
        let hours = String(12)
        var timeString = hours + ":" + minutes
        timeString = timeString + "am"
        return timeString

    }
    else {
        let asString = String(timeAsHHMM)
        let minutes = String(asString.suffix(2))
        var hours = asString
        _ = hours.popLast()
        _ = hours.popLast()
        var timeString = hours + ":" + minutes
        timeString = timeString + "am"
        
        return timeString
    }
    
}
func timeAsHHMMIntToStringInChat(timeAsHHMM: Int) -> String {
    

    
    if timeAsHHMM >= 1300 {
        var timeAsHHMMCopy = timeAsHHMM
        timeAsHHMMCopy = timeAsHHMM - 1200
        let asString = String(timeAsHHMMCopy)
        let minutes = String(asString.suffix(2))
        var hours = asString
        _ = hours.popLast()
        _ = hours.popLast()
        var timeString = hours + ":" + minutes
        timeString = timeString + " PM"
        
        return timeString
    } else if timeAsHHMM >= 1200 {
        
        let asString = String(timeAsHHMM)
        let minutes = String(asString.suffix(2))
        let hours = String(12)
        var timeString = hours + ":" + minutes
        timeString = timeString + " PM"
        return timeString
        
    }
    else if timeAsHHMM < 100 {
       
        let minutes = String(timeAsHHMM)
        let hours = String(12)
        var timeString = hours + ":" + minutes
        timeString = timeString + " AM"
        return timeString

    }
    else {
        let asString = String(timeAsHHMM)
        let minutes = String(asString.suffix(2))
        var hours = asString
        _ = hours.popLast()
        _ = hours.popLast()
        var timeString = hours + ":" + minutes
        timeString = timeString + " AM"
        
        return timeString
    }
    
    
//    if timeAsHHMM > 1200 {
//        var timeAsHHMMCopy = timeAsHHMM
//        timeAsHHMMCopy = timeAsHHMM - 1200
//        let asString = String(timeAsHHMMCopy)
//        let minutes = String(asString.suffix(2))
//        var hours = asString
//        _ = hours.popLast()
//        _ = hours.popLast()
//        var timeString = hours + ":" + minutes
//        timeString = timeString + " PM"
//
//        return timeString
//    } else {
//        let asString = String(timeAsHHMM)
//        let minutes = String(asString.suffix(2))
//        var hours = asString
//        _ = hours.popLast()
//        _ = hours.popLast()
//        var timeString = hours + ":" + minutes
//        timeString = timeString + " AM"
//
//        return timeString
//    }
    
}

func stringToChatBubbleFormat(fullString: String) -> String {
    
//    print("____________________")
//    print("fullString: " + fullString)
    var hoursAndMinutes = String(fullString.suffix(8).prefix(5))
//    print("hoursAndMinutes: " + hoursAndMinutes)

    let hours: String = String(fullString.suffix(8).prefix(2))
//    print("hours: " + hours)
    
    var hoursInInt = Int(hours)!
    
    

    if hoursInInt > 12 {
//        print("in hoursInInt > 12")
        hoursInInt = hoursInInt - 12
        hoursAndMinutes = String(hoursInInt) + hoursAndMinutes.suffix(3) + " PM"
    }
    else if hoursInInt == 12 {
//        print("in hoursInInt == 12")
        hoursAndMinutes = String(hoursInInt) + hoursAndMinutes.suffix(3) + " PM"
        
    } else if hoursInInt == 0 {
//        print("in hoursInInt == 0")
        hoursAndMinutes = String(12) + hoursAndMinutes.suffix(3) + " AM"
    } else if hoursInInt > 9 {
//        print("in hoursInInt > 9 ")
        hoursAndMinutes = hoursAndMinutes.suffix(5) + " AM"
    } else {
//        print("in else")
        hoursAndMinutes = hoursAndMinutes.suffix(4) + " AM"
    }
//    print("returning: " + hoursAndMinutes)
//    print("____________________")

    return hoursAndMinutes
        
}

func getWrittenOutDate(myDate: Date) -> String{
    let myCalendar = Calendar(identifier: .gregorian)
    let weekDay = myCalendar.component(.weekday, from: myDate)
    let dayOfTheWeek = getDayOfTheWeed(dayNumber: weekDay)
    let monthOfTheYear = getMonthOfTheYear(monthNumber: myCalendar.component(.month, from: myDate))
    let numberDate = myCalendar.component(.day, from: myDate)
    
    let fullDate = dayOfTheWeek + ", " + monthOfTheYear + " " + String(numberDate)
    return fullDate
    
}

func getDayOfTheWeed(dayNumber: Int) -> String {
    let days = ["Sunday", "Monday", "Tuesday", "Wednesday","Thursday", "Friday", "Saturday"]
    return days[dayNumber - 1]
}

func getMonthOfTheYear(monthNumber: Int) -> String {
    let months = ["January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"]
    return months[monthNumber - 1]
    
}

func dateNumber(myDateString: String) -> String {

    return String(myDateString.prefix(10))
}

func isToday(myDateString: String) -> Bool {
    
    let todayDate = dateNumber(myDateString: timeStampToLongString(timeStamp: Timestamp()))
    let myDate = dateNumber(myDateString: myDateString)
    return todayDate == myDate

}



func dateChatLogic(oldTimeStamp: Timestamp, newTimeStamp: Timestamp) -> String {

    if isToday(myDateString: timeStampToLongString(timeStamp: newTimeStamp)) {
        return "Today"
    } else {
        return getWrittenOutDate(myDate: newTimeStamp.dateValue())
    }
    
    
}

func getUserScore(userAlias: String, currentPod: Pod) -> Int {
//    print("____________")
//    print("______USERALIAS______")
//    print(userAlias)
//    print("____________")
    return currentPod.memberAliasesAndScore[userAlias]!
}

func getSenderName(senderAlias: String, currentPod: Pod) -> String {
//    print("____________")
//    print("______SENDERALIAS______")
//    print(senderAlias)
//    print("____________")
    if senderAlias == "BuddyUp Bot" {
        return "BuddyUp Bot"
    }
    if senderAlias == "Not Found" {
        return "Unknown"
    } else {
        return currentPod.memberAliasesAndName[senderAlias]!
    }
}
func getColorCode(memberAlias: String, currentPod: Pod) -> Int {
//    print("____________")
//    print("______MEMBERALIAS______")
//    print(memberAlias)
//    print("____________")

    if memberAlias == "BuddyUp Bot" {
        return 100
    }
    if memberAlias == "Not Found" {
        return -1
    } else {
        return currentPod.memberAliasesAndColorCode[memberAlias]!
    }
}


func convertToGMTTime(userRequestedTimeHHMM: Int, secondsFromGMT: Int) -> Int {
    let hourTimeDifference = secondsFromGMT/3600
    return userRequestedTimeHHMM - hourTimeDifference
}


extension StringProtocol {
    subscript(_ offset: Int)                     -> Element     { self[index(startIndex, offsetBy: offset)] }
    subscript(_ range: Range<Int>)               -> SubSequence { prefix(range.lowerBound+range.count).suffix(range.count) }
    subscript(_ range: ClosedRange<Int>)         -> SubSequence { prefix(range.lowerBound+range.count).suffix(range.count) }
    subscript(_ range: PartialRangeThrough<Int>) -> SubSequence { prefix(range.upperBound.advanced(by: 1)) }
    subscript(_ range: PartialRangeUpTo<Int>)    -> SubSequence { prefix(range.upperBound) }
    subscript(_ range: PartialRangeFrom<Int>)    -> SubSequence { suffix(Swift.max(0, count-range.lowerBound)) }
}
extension LosslessStringConvertible {
    var string: String { .init(self) }
}
extension BidirectionalCollection {
    subscript(safe offset: Int) -> Element? {
        guard !isEmpty, let i = index(startIndex, offsetBy: offset, limitedBy: index(before: endIndex)) else { return nil }
        return self[i]
    }
}
