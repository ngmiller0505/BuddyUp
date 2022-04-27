//
//  PodWrapper.swift
//  PODZ
//
//  Created by Nick Miller on 11/3/20.
//  Copyright © 2020 Nick Miller. All rights reserved.
//

import Foundation
import Firebase
import FirebaseFirestoreSwift

class PodWrapper: ObservableObject, Identifiable {
    
    @Published var currentPod: Pod?
//    {
//        willSet {
//            if !self.inPodChat {
//                print("not in podChat.   updating newPodView")
//                bufferedNewPod = nil
//                objectWillChange.send()
//            } else {
//                bufferedNewPod = newValue
//                print("in podChat.    bufferedNewPod = newValue")
//
//            }
//        }
//    }
    
    var bufferedNewPod: Pod?
    var somethingNewChangedForUserAlert: Bool = false
    var inPodChat: Bool = false
    var userJustLogged: Bool = false
    
    var podID: String
    var listener: ListenerRegistration?
    //@Published var loaded: Bool = false
    let userID : String
    
    init(id: String, UID: String) {
        self.podID = id
        self.userID = UID
        print("_________ON PODWRAPPER INIT LOADED IS FALSE__________")
        podListener()
    }
    deinit {
        print("DEINIT POD WRAPPER")

        if listener != nil{
            listener!.remove()
        }
    }
    
    
//    func addMessageToFirebase(message: displayMessage) {
//        let db = Firestore.firestore()
//
//        var ref: DocumentReference? = nil
//
//        ref = db.collection("pod").addDocument(data: [
//            "first": "Alan",
//            "middle": "Mathison",
//            "last": "Turing",
//            "born": 1912
//        ]) { err in
//            if let err = err {
//                print("Error adding document: \(err)")
//            } else {
//                print("Document added with ID: \(ref!.documentID)")
//            }
//        }
//
//    }
    
    func addPodToFirebase(currentPod: Pod) {
    
        let db = Firestore.firestore()

        do {
            try db.collection("pods").document(currentPod.podID).setData(from: currentPod) { err in
                if err == nil{
                    print("Document added with ID: \(currentPod.podID)")
                } else {
                    print("error inside try: \(String(describing: err))")
                }
            }
        }
        catch let error {
                print("error outside try: \(error)")
        }
    }
    
        
    
    func addUserToPod(podID: String, newUser: User){
        let db = Firestore.firestore()
        
        let docRef = db.collection("pods").document(podID)
        
        docRef.updateData([
            
            "membersIDandName" : FieldValue.arrayUnion([[newUser.ID, newUser.firstName]])
        
        ])
        
    }

//    func setLoadedToTrue(){
//        print("")
//        print("_________________setting loaded to true________________")
//        self.loaded = true
//        print("")
//
//    }
    
    func somethingNewChangedForUser(newPod: Pod, userAlias: String) -> Bool{
        if currentPod == nil {
            return false
        }
        if (currentPod!.memberAliasesAndSomethingNew[userAlias] != newPod.memberAliasesAndSomethingNew[userAlias]) && currentPod!.memberAliasesAndHasLogged[userAlias] == newPod.memberAliasesAndHasLogged[userAlias] &&
            currentPod!.memberAliasesAndScore[userAlias] == newPod.memberAliasesAndScore[userAlias] {
            
            print("onlySomethingNewChangedForUser return true")
            return true
        } else {
            return false
        }
    }
    
    func otherMemberSomethingNewChanged(newPod: Pod, userAlias: String) -> Bool {
        
        if currentPod == nil {
            return false
        }
        let aliases : [String] = Array(newPod.memberAliasesAndIDs.keys)
        let otherAliases = aliases.filter { alias in
            return alias != userAlias
        }
        for alias in otherAliases {
            
            if (currentPod!.memberAliasesAndSomethingNew[alias] != newPod.memberAliasesAndSomethingNew[alias]) &&
                currentPod!.memberAliasesAndHasLogged[alias] == newPod.memberAliasesAndHasLogged[alias] &&
                currentPod!.memberAliasesAndScore[alias] == newPod.memberAliasesAndScore[alias] {
                
                print("otherMemberOnlySomethingNewChanged return true")
                return true
            }
        }
        print("otherMemberOnlySomethingNewChanged return false")
        return false
        
    }
    
    func newScores(newPod: Pod) -> [String : Int]? {
        if currentPod == nil {
            return nil
        }
        let aliases : [String] = Array(newPod.memberAliasesAndIDs.keys)

        for alias in aliases {
            
            if (currentPod!.memberAliasesAndSomethingNew[alias] != newPod.memberAliasesAndSomethingNew[alias]) &&
                currentPod!.memberAliasesAndHasLogged[alias] == newPod.memberAliasesAndHasLogged[alias] &&
                currentPod!.memberAliasesAndScore[alias] == newPod.memberAliasesAndScore[alias] {
                
                print("otherMemberOnlySomethingNewChanged return true")
                return newPod.memberAliasesAndScore
            }
        }
        return nil
    }

    
    func podListener() {
      
            let db = Firestore.firestore()
            
        listener = db.collection("pods").document(self.podID).addSnapshotListener { (querySnapshot, error) in
                guard let document = querySnapshot else {
                    print("Error fetching document: \(error!)")
                    return
                }

            guard let data = document.data() else {
                    print("Document data was empty.")

                    return
            }
            let source = document.metadata.hasPendingWrites ? "Local" : "Server"
            print("\(source) data: \(document.data() ?? [:])")
            print(data.map(String.init(describing:)))
            
                let result = Result {
                    try document.data(as: Pod.self)
                    }
                    switch result {
                    case .success(let pod):
                        
                        if let pod = pod {
                            // A `City` value was successfully initialized from the DocumentSnapshot.
                            print("____________________")
                            print("POD LISTENER DATA LOADED: \(pod)")
                              print("POD LISTENER DATA LOADED")
                            
                            print("____________________")
                            if self.currentPod != nil {
                                let userAlias = self.getAliasFromUID(UID: self.userID)
                                if userAlias != nil {
                                    if self.inPodChat {
                                        print("IN POD CHAT SO WE WON'T UPDATE CHANGES")
                                        self.bufferedNewPod = pod
                                    } else {
                                        print("NOT IN POD CHAT SO WE UPDATE CHANGES")
                                        self.currentPod = pod
                                        self.bufferedNewPod = nil
                                    }
                                }
                            else {
                                self.currentPod = pod
                                }
                            } else {
                                self.currentPod = pod
                            }
                           

                            
                            //self.setLoadedToTrue()
                            
                            
                        } else {
                            // A nil value was successfully initialized from the DocumentSnapshot,
                            // or the DocumentSnapshot was nil.
                            print("Pod Document does not exist")
                            
                        }
                    case .failure(let error):
                        // A `City` value could not be initialized from the DocumentSnapshot.
                        print("Error decoding pod: \(error)")
                    }
            
            }
                
                
            
    }
    
    func incrementScore(userAlias: String) {
        //
        if self.inPodChat {
            if bufferedNewPod != nil {
                self.bufferedNewPod!.memberAliasesAndScore[userAlias]! += 1
            }
            else {
                self.bufferedNewPod = self.currentPod
                self.bufferedNewPod!.memberAliasesAndScore[userAlias]! += 1            }
        }
        let db = Firestore.firestore()
        db.collection("pods").document(podID).updateData(
            ["memberAliasesAndScore.\(userAlias)" : self.currentPod!.memberAliasesAndScore[userAlias]!])
        { err in
            if err == nil {
                print("updated Score")
            } else {
                print(err!.localizedDescription)
            }
        }
    }

    func getAliasFromUID(UID: String) -> String? {
        var flattened: [String] = []
        if UID == "BuddyUp Bot" {
            return "BuddyUp Bot"
        }
        for (alias,ID) in self.currentPod!.memberAliasesAndIDs {
            flattened.append(alias)
            flattened.append(ID)
        }
        let aliasIndexPlus1 = flattened.firstIndex(of: UID)
        if aliasIndexPlus1 == nil {
            return nil
        }
        let aliasIndex = aliasIndexPlus1! - 1
//        print("_____________________")
//        print("Flattened: ", flattened)
//        print("UID: ", UID)
//        print("aliasIndex: ", aliasIndex)
//        print("Flattened[aliasIndex]: ", flattened[aliasIndex])
//        print("_____________________")
        
        return flattened[aliasIndex]
        
        
    }
    
    func hasLogged(userAlias: String) {
        //DONT DO ANYTHING LOCALLY TO AVOID AUTOMATIC POP
        if self.inPodChat {
            if bufferedNewPod != nil {
                self.bufferedNewPod!.memberAliasesAndHasLogged[userAlias]! = true
            }
            else {
                self.bufferedNewPod = self.currentPod
                self.bufferedNewPod!.memberAliasesAndHasLogged[userAlias]! = true
            }
        }
            
        let db = Firestore.firestore()
        db.collection("pods").document(podID).updateData(
            ["memberAliasesAndHasLogged.\(userAlias)" : self.currentPod!.memberAliasesAndHasLogged[userAlias]!])
            { err in
                if err == nil {
                    print("updated hasLogged")
                } else {
                    print(err!.localizedDescription)
                }
            }
        }
    
    
    func cloudFunctionsOnHabitLogged(alias: String) {
        let functions = Functions.functions()
        incrementScore(userAlias: alias)
        hasLogged(userAlias: alias)
        functions.httpsCallable("onHabitLogged").call(["alias": alias, "podID" : podID]) { (result, error) in
            if let error = error as NSError? {
              if error.domain == FunctionsErrorDomain {
                let code = FunctionsErrorCode(rawValue: error.code)
                let message = error.localizedDescription
                let details = error.userInfo[FunctionsErrorDetailsKey]
                print(code!, message, details!)
              }
              // ...
            }
            if let text = result?.data as? String {
              print(text)
            }
        }
    }
//    func setSomethingNewForOtherUsersInPod(userAlias: String) {
//        let aliases = ["a", "b", "c"]
//
//        let otherAliases = aliases.filter { alias in
//            return alias != userAlias
//        }
//        for alias in otherAliases {
//            currentPod!.memberAliasesAndSomethingNew[alias] = true
//        }
////        let db = Firestore.firestore()
////        for alias in otherAliases {
////            db.collection("pods").document(podID).updateData(
////                ["memberAliasesAndSomethingNew.\(alias)" : true])
////                { err in
////                    if err == nil {
////                        print("updated hasLogged")
////                    } else {
////                        print(err!.localizedDescription)
////                    }
////                }
////        }
//    }
    func cloudFunctionsOnMessageSent(message: Message) {
        
        
        
        let alias = getAliasFromUID(UID: message.senderID)
        if alias == nil {
            return
        }
        
        //setSomethingNewForOtherUsersInPod(userAlias: alias!)
        print("cloud message triggered")
        let functions = Functions.functions()
        functions.httpsCallable("onMessageSend").call(["senderID": message.senderID, "senderAlias": alias ,"podID" : podID, "messageText": message.text, "messageType": message.type]) { (result, error) in
            if let error = error as NSError? {
              if error.domain == FunctionsErrorDomain {
                let code = FunctionsErrorCode(rawValue: error.code)
                let message = error.localizedDescription
                let details = error.userInfo[FunctionsErrorDetailsKey]
                print(code!, message, details!)
              }
              // ...
            }
            if let text = result?.data as? String {
              print(text)
            }
        }
    }

    func expectingHabitLogToday(UID: String) -> Bool {
        
        let date = Date()
        let calendar = Calendar.current
        let components = calendar.dateComponents([.weekday], from: date)
        let dayOfWeekNumber = components.weekday
        
        let alias = getAliasFromUID(UID: UID)!
        
        let userSchedule = currentPod!.memberAliasesAndSchedule[alias]!
        let hasAlreadyLogged = currentPod!.memberAliasesAndHasLogged[alias]!
        
        //TODO: if a person has a habit late at night we may have an issue with them being able to log because its technically the next day
        //day just past but we still have a habit to log
        
        
        if userSchedule[dayOfWeekNumber! - 1] && !hasAlreadyLogged && !userJustLogged {
            return true
        } else  {
            return false
        }
            
            
    }
    func seenSomethingNew(UID: String) {
        let alias = getAliasFromUID(UID: UID)
        if alias == nil || currentPod == nil {
            return
        }
        currentPod!.memberAliasesAndSomethingNew[alias!] = false
        let db = Firestore.firestore()
        
        db.collection("pods").document(currentPod!.podID).updateData([
            "memberAliasesAndSomethingNew.\(alias!)" : false
        ]) { err in
            if err == nil {
                print("somethingNew has been updated")
            } else {
                print(err!.localizedDescription)
            }
        }
        
    }
    func isThereSomethingNewForUser(UID: String) -> Bool {
        let alias = getAliasFromUID(UID: UID)
        if alias == nil || currentPod == nil {
            return false
        }
        return currentPod!.memberAliasesAndSomethingNew[alias!] ?? false
    }
    
    func updateSecondsFromGmtForUser(UID: String) {
        let newSecondsFromGmt = TimeZone.current.secondsFromGMT()
        
        let alias = self.getAliasFromUID(UID: UID)
        
        if alias == nil || currentPod == nil {
            return
        } else {
            
            let oldSecondsFromGmt = currentPod!.memberAliasesAndSecondsFromGMT[alias!]
            
            if oldSecondsFromGmt == nil {
                let db = Firestore.firestore()
                print("BEFORE rewrite currentPod!.memberAliasesAndSecondsFromGMT =  ", currentPod!.memberAliasesAndSecondsFromGMT)
                currentPod!.memberAliasesAndSecondsFromGMT[alias!] = newSecondsFromGmt
                print("AFTER rewrite currentPod!.memberAliasesAndSecondsFromGMT =  ", currentPod!.memberAliasesAndSecondsFromGMT)
                print("\n\\n")
                db.collection("pods").document(podID).updateData( [
                    "memberAliasesAndSecondsFromGMT" :  currentPod!.memberAliasesAndSecondsFromGMT
                    ]
                )
                { err in
                    if err == nil {
                        print("USER changed timezones. updated new seconds from gmt")
                    } else {
                        print(err!.localizedDescription)
                    }
                }

            } else {
                if oldSecondsFromGmt == newSecondsFromGmt {
                    return
                } else {
                    let db = Firestore.firestore()
                    print("BEFORE rewrite currentPod!.memberAliasesAndSecondsFromGMT =  ", currentPod!.memberAliasesAndSecondsFromGMT)
                    currentPod!.memberAliasesAndSecondsFromGMT[alias!]! = newSecondsFromGmt
                    print("AFTER rewrite currentPod!.memberAliasesAndSecondsFromGMT =  ", currentPod!.memberAliasesAndSecondsFromGMT)
                    print("\n\\n")
                    db.collection("pods").document(podID).updateData( [
                        "memberAliasesAndSecondsFromGMT" :  currentPod!.memberAliasesAndSecondsFromGMT
                        ]
                    )
                    { err in
                        if err == nil {
                            print("USER changed timezones. updated new seconds from gmt")
                        } else {
                            print(err!.localizedDescription)
                        }
                    }
                }
            }
            print("\n\n in updateSecondsFromGmtForUser")
            print("alias = ", alias!)
            

        }
    }
    func updatePodName(newPodName: String) {
        let db = Firestore.firestore()
        db.collection("pods").document(podID).updateData(["podName" : newPodName])
        { err in
            if err == nil {
                print("pod Name Succesfully updated")
            } else {
                print(err!.localizedDescription)
            }
        }
    }
    
}

//extension example {
//    init(currentPod: Pod, listener: ListenerRegestration?, loaded: Binding<Bool>) {
//        self.currentPod = currentPod
//    }
//}



