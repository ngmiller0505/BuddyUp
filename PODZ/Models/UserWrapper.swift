//
//  UserWrapper.swift
//  PODZ
//
//  Created by Nick Miller on 9/24/20.
//  Copyright © 2020 Nick Miller. All rights reserved.
//

import Foundation
import Firebase
import FBSDKCoreKit
import FirebaseAuth
import FirebaseFirestore
import FirebaseFirestoreSwift
import Combine
import Purchases
import Contacts




enum DeviceType
{
    case old, new, SE
}



class UserWrapper: ObservableObject {
    
    @Published var currentUser : User?
    
    @Published var userPods: [PodWrapper] = []
    @Published var userFriends: [User] = []
    @Published var userIncomingFriendRequests: [User] = []
    @Published var contactsMatchedToUsers : [User] = []
    
    
    @Published var faqs: [String:String] = [:]
    @Published var phraseExamples: [PhraseExample] = []
    @Published var currentPodApplication: PodApplication = PodApplication(currentTime: Timestamp())
    @Published var leftAPod: Bool = false
    
    
    @Published var differentDevice: DeviceType = .new
    
    @Published var loadingFromSignIn = false
    @Published var startedToLoadUser = false
    @Published var triedToLoadUser = false
    
    @Published var showConfirmedProfileInformation = false
    
    @Published var notificationAction: String?
    @Published var podIDView: String = ""

    @Published var pendingPods: [PendingPod] = []
    @Published var finishedPods: [Pod] = []
    
    @Published var triedToLoadUserPods = false
    @Published var triedToLoadPendingPods = false
    
//    @Published var purchasesWrapper : PurchasesWrapper?
    
    var emailFirstName: String?
    var emailLastName: String?
    
    var handle: AuthStateDidChangeListenerHandle?
    var listener: ListenerRegistration?
    
    var tokenDict : [String:String]? = nil
    
    
    @Published var activeComplaint : Complaint? = nil
    
//     @Published var activeSheet: ActiveSheet? = nil

    
    
    
    
    
    
    
    deinit {
        print("DEINIT USER WRAPPER")
        stopListen()
    }
    
    
    
    
    
    
    
    
    
    
    func checkDifferentDevice() {
        let modelName = UIDevice.modelName
        let oldDevices = ["iPhone8,1", "iPhone 6s", "iPhone8,2", "iPhone 6s Plus", "iPhone8,4", "iPhone9,1", "iPhone9,3","iPhone 7", "iPhone9,2", "iPhone9,4", "iPhone 7 Plus", "iPhone 8", "iPhone 8 Plus", "iPhone SE (2nd generation)"]
//        let SEDevices = ["iPhone 6", "iPhone7,1", "iPhone 6 Plus", "iPhone SE", "iPhone SE (2nd generation)"] //THIS IS NOT USED
        
        print("DEVICE NAME: ", modelName)
        
        for device in oldDevices {
            let simulatorDevice = "Simulator " + device
            
            if device == modelName || modelName == simulatorDevice {
                self.differentDevice = .old
                print("OLD DEVICE")
            }
        }
//        for device in SEDevices {
//            let simulatorDevice = "Simulator " + device
//
//            if device == modelName || modelName == simulatorDevice {
//                self.differentDevice = .SE
//                print("SE DEVICE")
//            }
//        }
    }
    
    func listen() {
        checkDifferentDevice()
            if handle == nil {
                handle = Auth.auth().addStateDidChangeListener { (auth, user) in
                    if let user = user {
                        print("User logged in: \(user)")
                        
                        self.getUserFromFirestore(id: user.uid) { [self] firUser in
                            
                            if firUser == nil {
                                    
                                    print("no user found in firestore so creating new user")
                                    print(user.email!)
                                
                                var firstName : String? = nil
                                var lastName : String? = nil
                                
                                if emailFirstName != nil {
                                     firstName = emailFirstName
                                     lastName = emailLastName
                                    showConfirmedProfileInformation = true
                                    
                                } else {
                                    let names = user.displayName?.split(separator: " ")
                                    firstName = names == nil ? "unknown" : String(names!.first!)
                                    lastName = names == nil ? "unknown" : String(names!.last!)
                                    

                                }
                                
                                self.currentUser = User(fn: String(firstName!), ln: String(lastName!), uid: user.uid, email: user.email!.lowercased(), paid: false, dateCreated: Timestamp())
                                self.addUserToFirestore(currentUser: self.currentUser!)
                                
                                
                                self.getPhraseExamples()
                                self.getFAQs { (qAndA) in
                                    faqs = qAndA
                                }

                                triedToLoadUser = true
                                triedToLoadUserPods = true
                                triedToLoadPendingPods = true
                                self.setNotificationTokenDict(tokenDict: tokenDict)
                                
                                print("INITIALIZING purchasesWRAPPER")
                                self.getPackages() { packagesResult in
                                    
                                    self.packages = packagesResult
                                    
                                }

                                
                                self.logInRevenueCat(userID: user.uid) { isPremium in
                                    self.isPremium = isPremium
                                }

                                
                            } else {
                                print("-")
                                print("_________________________________")
                                print("print user already exists")
                                print("copying data from firestore to use locally")
                                print("_________________________________")
                                print("-")

                            userDataListener(userID: user.uid) { userFromListener in
                                
                                    currentUser = userFromListener
                                
                                print("INITIALIZING purchasesWRAPPER")
                                self.getPackages() { packagesResult in
                                    
                                    self.packages = packagesResult
                                    
                                }
                                
                                self.logInRevenueCat(userID: user.uid) { isPremium in
                                    print("in logInRevenueCat  isPremium = ", isPremium)
                                    self.isPremium = isPremium
                                }

                                
                                    self.setNotificationTokenDict(tokenDict: tokenDict)
                                    triedToLoadUser = true
                                    
                                
                                    self.getPendingPods() {
                                        triedToLoadPendingPods = true
                                    }
                                
                                
                                    let podIDsInUserPods = self.userPods.map { (podWrapper) -> String in
                                        podWrapper.podID
                                    }
                                    for podID in self.currentUser!.podsApartOfID {
                                        if !(podIDsInUserPods.contains(podID)) {
                                            self.userPods.append(PodWrapper(id: podID, UID: self.currentUser!.ID))
                                        }
                                    }
                                    self.userPods = self.userPods.filter { (podWrapper) -> Bool in
                                        triedToLoadUserPods = true
                                        print("LOADED USER PODS")
                                        return self.currentUser!.podsApartOfID.contains(podWrapper.podID)
                                    }
                                
                                
                                
                                    self.pendingPods = self.pendingPods.filter { (pendingPod) -> Bool in
                                        print("LOADED PENDING PODS")
                                        return self.currentUser!.pendingPodIDs.contains(pendingPod.id)
                                    }
                                    
                                    
                                    

                                    self.getFriendUsers()
                                    self.getFriendRequestUsers()
                                    self.getPhraseExamples()
                                        
                                    self.getFAQs { (qAndA) in
                                        faqs = qAndA
                                        
                                    }
                                    self.getFinishedPods()
                                    self.loadingFromSignIn = false
                                    
                                    return userFromListener
                                }
                            }
                            
                        }
                        
                    }  else {
                        //self.loadingFromSignIn = false
                        self.isPremium = false
                        self.packages = nil
                        self.purchaseStatus = nil
                        
                        self.currentUser = nil
                        self.emailLastName = nil
                        self.emailFirstName = nil
                        self.userPods = []
                        self.pendingPods = []
                        self.userFriends = []
                        self.finishedPods = []
                        self.userIncomingFriendRequests = []
                        self.contactsMatchedToUsers = []
                        print("unable to auth")
                        print("headed to sign in screen")
                        print("self.currentUser = nil")
                        self.triedToLoadUser = true
                        self.triedToLoadUserPods = true
                        self.triedToLoadPendingPods = true
                        self.currentPodApplication = PodApplication(currentTime: Timestamp())

                    }

                }
            }
        }
    
    func stopListen() {
        print("SIGN OUT 4")
        if let handle = handle {
            Auth.auth().removeStateDidChangeListener(handle)
        }
    }
    
    
    func daysSinceUserCreated() -> Int {
        let today = Date()
        let dateCreatedAsDate = currentUser!.dateCreated.dateValue()
        let numberOfDays = Calendar.current.dateComponents([.day], from: dateCreatedAsDate, to: today)
        return numberOfDays.day!
    }

    func updateFirstAndLastName(newFirstName: String, newLastName: String) {
        
        let db = Firestore.firestore()
        let docRef = db.collection("users").document(currentUser!.ID)
        
        
        docRef.updateData([
            "firstName" : newFirstName,
            "lastName"  : newLastName
        ]) { err in
            if let err = err {
                print("Error updating document: \(err)")
            } else {
                print("Document successfully updated")
            }
        }
        
    }
    
    func getUserFromFirestore(id: String, completion: @escaping ((User?) -> ()) ) {
        
        let db = Firestore.firestore()
        let docRef = db.collection("users").document(id)
        
        var loadedUser: User?
        
        docRef.getDocument { (document, error) in
            if let document = document, document.exists {
                let dataDescription = document.data().map(String.init(describing:)) ?? "nil"
                print("Document data: \(dataDescription)")

                let result = Result {
                    try document.data(as: User.self)
                    }
                    switch result {
                    case .success(let usr):
                        if let usr = usr {
                            // A `City` value was successfully initialized from the DocumentSnapshot.
                            loadedUser = usr
                            print("USER WITHIN: ", loadedUser?.email ?? "no user")
                            completion(loadedUser)
                        } else {
                            // A nil value was successfully initialized from the DocumentSnapshot,
                            // or the DocumentSnapshot was nil.
                            print("Document does not exist")
                            
                        }
                    case .failure(let error):
                        // A `City` value could not be initialized from the DocumentSnapshot.
                        print("Error decoding user: \(error)")
                    }
            } else {
                print("something is wrong with firestore", (document.debugDescription))
                completion(loadedUser)
            }
        }
    }
    

    func addUserToFirestore(currentUser: User) {
        let db = Firestore.firestore()

        do {
            try db.collection("users").document(currentUser.ID).setData(from: currentUser) { err in
                if err == nil{
                    print("Document added with ID: \(currentUser.ID)")
                } else {
                    print("error inside try: \(String(describing: err))")
                    
                }
            }
        }
        catch let error {
                print("error outside try: \(error)")
        }
    }
    
    
    
    
    func addPodToUser(newPod: Pod) {
        let db = Firestore.firestore()
        
        let docRef = db.collection("users").document(newPod.podID)
        
        docRef.updateData([
            
            "membersIDandName" : FieldValue.arrayUnion([[self.currentUser!.firstName, currentUser!.ID]])
        
        ]) { (err) in
            if err == nil{
                self.currentUser!.podsApartOfID.append(newPod.podID)
                self.userPods.append(PodWrapper(id: newPod.podID, UID: self.currentUser!.ID))
            } else {
                print("ERROR ADDING NEW POD TO USER DATA: \(err!)")
            }
        }
    }
    

    
    
    func getSinglePod(podID: String,  completion: @escaping ( (Pod?)->() )) {
        
        let db = Firestore.firestore()
        let citiesRef = db.collection("pods")

        // Create a query against the collection.
        let query = citiesRef.whereField("podID", isEqualTo: podID)
        
        var loadedPod: Pod?
        
        
        query.getDocuments { (querySnapshot, error) in
            print("__________")
            print("RIGHT BEFORE try querySnapshot!.documents[0].data(as: Pod.self)")
            print("__________")
            if querySnapshot == nil {
                print("querySnapshot is nil")
            } else if querySnapshot!.documents.isEmpty {
                print("documents is empty")
                completion(nil)
            }
            else {
            let result = Result {
                try querySnapshot!.documents[0].data(as: Pod.self)
                }
                switch result {
                case .success(let pod):
                    if let pod = pod {
                        // A `City` value was successfully initialized from the DocumentSnapshot.
                        print("\nPOD: \(pod)")
                        loadedPod = pod
                        completion(loadedPod!)

                    } else {
                        // A nil value was successfully initialized from the DocumentSnapshot,
                        // or the DocumentSnapshot was nil.
                        print("\nDocument does not exist\n")
                        completion(nil)
                        
                    }
                case .failure(let error):
                    // A `City` value could not be initialized from the DocumentSnapshot.
                    print("Error decoding user: \(error)")
                }
            }
        }
    }
    
    
    
    func userDataListener(userID: String, completion: @escaping ((User) -> (User)) ) {
        let db = Firestore.firestore()
        
        listener = db.collection("users").document(userID).addSnapshotListener { (querySnapshot, error) in
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
                try document.data(as: User.self)
                }
                switch result {
                case .success(let usr):
                    if let usr = usr {
                        // A `City` value was successfully initialized from the DocumentSnapshot.
                        print("USER LISTENER DATA LOADED: \(usr)")
                        completion(usr)
                        
                    } else {
                        // A nil value was successfully initialized from the DocumentSnapshot,
                        // or the DocumentSnapshot was nil.
                        print("Document does not exist")
                        
                    }
                case .failure(let error):
                    // A `City` value could not be initialized from the DocumentSnapshot.
                    print("Error decoding user: \(error)")
                }
        }
    }
    
    
    
    func getPendingPodFromPendingPodIDs(pendingPodID: String) -> PendingPod? {
        
        let podInList = pendingPods.filter { pendingPod in
            return pendingPod.id == pendingPodID
        }
        if podInList.isEmpty {
            return nil
        } else {
            return podInList[0]
        }
    }
    
    func getFriendUsers() {
        
        if self.currentUser!.friendIDs.isEmpty {
            return
        }
        
        
        let db = Firestore.firestore()

        db.collection("users").whereField("ID", in: self.currentUser!.friendIDs).getDocuments { (querySnapshot, error) in
            if error != nil {
                print("error retrieving document: " + error.debugDescription)
                return
            }
            else {
                for doc in querySnapshot!.documents {
                    let result = Result {
                        try doc.data(as: User.self)
                    }
                    switch result {
                        case .success(let user):
                            if let user = user {
                                
                                print(" loaded friend " + user.email)
                                if !(self.userFriends.contains(user)){
                                    self.userFriends.append(user)
                                }
                            } else {
                                print("message does not exist")
                            }
                    case .failure(let error):
                        print("error decoding document: \(error)")
                    }
                }
            }
        }

    }
    
    func dontShowPodTutorialAgain() {
        let db = Firestore.firestore()
        currentUser!.donePodTutorial = true
        db.collection("users").document(currentUser!.ID).updateData(
            ["donePodTutorial" : true]
        ){ err in
            if let err = err {
                print("Error updating donePodTutorial: \(err)")
            } else {
                print("Document successfully donePodTutorial")
            }
        }
    }
    
    func getFriendRequestUsers() {
        
        
        if self.currentUser!.incomingFriendRequestIDs.isEmpty {
            return
        }
        
        
        let db = Firestore.firestore()

        db.collection("users").whereField("ID", in: self.currentUser!.incomingFriendRequestIDs).getDocuments { (querySnapshot, error) in
            if error != nil {
                print("ERROR RETRIEVING INCOMING FRIEND REQUESTS: " + error.debugDescription)
                return
            }
            else {
                for doc in querySnapshot!.documents {
                    let result = Result {
                        try doc.data(as: User.self)
                    }
                    switch result {
                        case .success(let user):
                            if let user = user {
                                print(" loaded friend request from" + user.email)
                                if !(self.userIncomingFriendRequests.contains(user)){
                                    self.userIncomingFriendRequests.append(user)
                                }
                            } else {
                                print("message does not exist")
                            }
                    case .failure(let error):
                        print("error decoding document: \(error)")
                    }
                }
            }
        }

    }
    
    func sendFriendRequest(friendUID: String) {
        let db = Firestore.firestore()
        
        self.currentUser!.pendingSentFriendRequestsIDs.append(friendUID)
        
        db.collection("users").document(friendUID).updateData(["incomingFriendRequestIDs" : FieldValue.arrayUnion([self.currentUser!.ID])]) { (err) in
            if err != nil {
                print("error sending friend request")
                return
            } else {
                print("FRIEND REQUEST SUCCESSFULLY SENT FROM " + friendUID + " ")
                db.collection("users").document(self.currentUser!.ID).updateData(["pendingSentFriendRequestsIDs" : FieldValue.arrayUnion([friendUID])]) { err in
                    if err != nil {
                        print("error sending friend request")
                        return
                    } else {
                        print("pendingSentFriendRequestsIDs successfully added")
                    }
                }
            }
        }
    }
    
    func removeIncomingFriendRequest(friendUID: String) {
        let db = Firestore.firestore()
        
        self.userIncomingFriendRequests = self.userIncomingFriendRequests.filter { (user) -> Bool in
            return !(user.ID == friendUID)
        }
        
        db.collection("users").document(self.currentUser!.ID).updateData(["incomingFriendRequestIDs" : FieldValue.arrayRemove([friendUID])]) { (err) in
            if err != nil {
                print("error sending friend request")
                return
            } else {
                print("FRIEND REQUEST SUCCESSFULLY SENT FROM " + friendUID + " ")
            }
        }
    }
    
    func addFriend(friendUID: String) {
        
        
        let db = Firestore.firestore()
        
        db.collection("users").document(self.currentUser!.ID).updateData(["friendIDs" : FieldValue.arrayUnion([friendUID])]) { (err) in
            if err != nil {
                print("error sending friend request")
                return
            } else {
                print("FRIEND" + friendUID + "SUCCESSFULLY SENT TO USER LIST")
            }
        }
        
    }
    
    func addUserToFriendList(friendUID: String) {
        let db = Firestore.firestore()
        
        db.collection("users").document(friendUID).updateData(["friendIDs" : FieldValue.arrayUnion([self.currentUser!.ID])]) { (err) in
            
            if err != nil {
                print("error sending friend request")
                return
            } else {
                print("USER SUCCESSFULLY SENT TO " + friendUID + " ")
            }
 
        }
    }
    

        
 
    
    func signOut() {
        print("SIGN OUT 1")
        triedToLoadUser = false
        startedToLoadUser = false
        removeNotificationToken()
        try! Auth.auth().signOut()
        
        if AccessToken.current != nil {
            AccessToken.current = nil
        }
        print("SIGN OUT 2")
        if listener != nil {
            listener!.remove()
        }
        print("SIGN OUT 3")
        Purchases.shared.logOut { purchaserInfo, err in
            if err != nil {
                print(err?.localizedDescription ?? "nil")
                
            }
            else {
                print("Log out purchases")
            }
        }

        print("SIGN OUT 5")

    }
    func removeNotificationToken() {
        let db = Firestore.firestore()
        if tokenDict != nil {
            db.collection("users").document(currentUser!.ID).updateData([
                            "token" : FieldValue.arrayRemove([tokenDict!["token"]!])
            ]) {
                err in
                if err != nil {
                    print("error removing notification token")
                    return
                } else {
                    print("Token removed. no notification will be sent")
                }
     
            
            }
        }
        
    }
    func sendCommunityPodApplicationToFirebase(podApplication: PodApplication) {
        
        let db = Firestore.firestore()
        let podPending = PendingPod(UID: currentUser!.ID, id: podApplication.appID, communityOrFriendGroup: "Community", podIDIfFriend: nil, friendWhoSentInvite: nil, friendInviteMessage: nil, friendNameWhoSentInvite: nil, communityCategoryAppliedFor: podApplication.subCatagory == "N/A" ? podApplication.catagory!: podApplication.subCatagory!, communityPodETABottom: nil, communityPodETATop: nil, commitmentLength: podApplication.commitmentLength!, isFriendPodLockedIn: nil)
        pendingPods.append(podPending)
        
        currentUser!.pendingPodIDs.append(podPending.id)
        pendingPods.append(podPending)
        do {
            try db.collection("podApplications").document(podApplication.appID).setData(from: podApplication) { err in
                if err == nil{
                    print("PodApplication added with ID: \(podApplication.appID)")

                    } else {
                    print("error inside try: \(String(describing: err))")
                    
                }
            }
        }
        catch let error {
                print("error outside try: \(error)")
        }
        
        do
        {
        try db.collection("pendingPods").document(podApplication.appID).setData(from: podPending) { err in
                   if err == nil {
                      print("Added Pending Pod")
                   } else {
                      print(err!)
                   }
              }
        }
            catch let error {
                
                print(error)
                
            }
                
        db.collection("users").document(currentUser!.ID).updateData( [
                    "pendingPodIDs" : FieldValue.arrayUnion([podPending.id])
                ]) { err in
                       if err == nil {
                          print("Added Pending Pod id to user data")
                       } else {
                          print(err!)
                       }
                  
        }
                

        
    }
    
    func addUserToBannedList(UID: String) {
        let db = Firestore.firestore()
        
        db.collection("users").document(currentUser!.ID).updateData( [
            "userBannedList" : FieldValue.arrayUnion([UID])
        ]) {
            err in
                if err != nil {
                    print("Error adding user to currentUser banned list: " + err!.localizedDescription)
                } else {
                    print("Successfully added \(UID) to current user banned list")
                }
            
        }
        
    }
    
    func sendFriendPodApplication(podApplication: PodApplication) {
        if podApplication.associatedPod != nil {
            pendingPods = pendingPods.filter({ pendingPod in
                if pendingPod.podIDIfFriendInvite == nil {
                    return true
                } else {
                    return pendingPod.podIDIfFriendInvite! != podApplication.associatedPod!
                }
            })
        } else {
            self.userPods.append(PodWrapper(id: podApplication.associatedPod ?? "Waiting for New pod", UID: self.currentUser!.ID))
        }
        let db = Firestore.firestore()
        do {
            try  db.collection("friendPodApplications").document(podApplication.appID).setData(from: podApplication) {
                err in
                if err != nil {
                    print(err!.localizedDescription)
                } else {
                    print("friendPodApplication uploaded succesfully")
                }
            }
        }
        catch let err {
            print(err.localizedDescription)
        }

    }
    func deleteFriendPodInvite(pendingPod: PendingPod) {
        currentUser!.pendingPodIDs = currentUser!.pendingPodIDs.filter { (appID) -> Bool in
            return appID != pendingPod.id
        }
        self.pendingPods = self.pendingPods.filter { (pendingPod) -> Bool in
            triedToLoadPendingPods = true
            print("LOADED USER PODS")
            return self.currentUser!.pendingPodIDs.contains(pendingPod.id)
        }
        let db = Firestore.firestore()
        db.collection("users").document(self.currentUser!.ID).updateData(["pendingPodIDs" : currentUser!.pendingPodIDs]) { err in
            if err != nil {
                print(err!.localizedDescription)
            } else {
                print("delete request successfully sent")
                db.collection("pendingPods").document(pendingPod.id).delete { (error) in
                    if error != nil {
                        print(error!.localizedDescription)
                    } else {
                        print("pendingPodDeleted")
                        db.collection("pods").document(pendingPod.podIDIfFriendInvite!).updateData(["invitedFriendIDs": FieldValue.arrayRemove([self.currentUser!.ID])])
                    }
                }

            }
        }
    }
    
    func deletePodApplication(pendingPod: PendingPod) {
        let db = Firestore.firestore()
        currentUser!.pendingPodIDs = currentUser!.pendingPodIDs.filter { (appID) -> Bool in
            return appID != pendingPod.id
        }
        self.pendingPods = self.pendingPods.filter { (pendingPod) -> Bool in
            triedToLoadPendingPods = true
            print("LOADED USER PODS")
            return self.currentUser!.pendingPodIDs.contains(pendingPod.id)
        }
        db.collection("users").document(self.currentUser!.ID).updateData(["pendingPodIDs" : currentUser!.pendingPodIDs]) { err in
            if err != nil {
                print(err!.localizedDescription)
            } else {
                db.collection("pendingPods").document(pendingPod.id).delete { (error) in
                    if error != nil {
                        print(error!.localizedDescription)
                    } else {
                        print("pendingPodDeleted")
                        db.collection("podApplications").document(pendingPod.id).delete() {
                            err in
                            if err != nil {
                                print(error!.localizedDescription)
                            } else {
                                print("podApplication deleted")
                            }
                        }
                    }
                }
            }
        }
    }
    
    func finishedTutorial() {
        currentUser!.doneAppTutorial = true
        let db = Firestore.firestore()
        db.collection("users").document(currentUser!.ID).updateData(["doneAppTutorial" : true]) {
            err in
                if err != nil {
                    print(err!.localizedDescription)
                }
                else {
                    print("successfully set doneAPpTutorial = true")
                
                }
        }
    }
    
    func setNotificationTokenDict(tokenDict: [String:String]?) {
        
        if currentUser == nil {
            print("currentUser == nil. NOT SETTING TOKEN DICT")
            return
            
        }
        
        if tokenDict == nil {
            print("------tokenDict == nil----------------")
            return
        }
        if tokenDict!["token"] == nil {
            print("------tokenDict[token] == nil----------------")
            return
        }
        
        let db = Firestore.firestore()
            db.collection("users").document(currentUser!.ID).updateData([
                            "token" : FieldValue.arrayUnion([tokenDict!["token"]!])
            ]) {
                err in
                if err != nil {
                    print("error updating users")
                    return
                } else {
                    print("token added")
                }
     
            
            
            }
    }
    
    func cloudFunctionsOnFriendRequestSent(recieverID: String) {
        let functions = Functions.functions()
        
        functions.httpsCallable("onFriendRequestSent").call(["senderID": currentUser!.ID, "recieverID": recieverID]) { (result, error) in
            
            if let error = error as NSError? {
              if error.domain == FunctionsErrorDomain {
                let code = FunctionsErrorCode(rawValue: error.code)
                let message = error.localizedDescription
                let details = error.userInfo[FunctionsErrorDetailsKey]
                
                print("ERRORED FUNCTION TEST RESULT: ", code!, message, details!)
              }
              // ...
            }
            if let text = result?.data as? String {
              print("SUCCESSFUL FUNCTION TEST RESULT: " + text)
            }
        }
    }
    
    func cloudFunctionsOnFriendRequestAccepted(friendID: String) {
        let functions = Functions.functions()
        
        functions.httpsCallable("onFriendRequestAccepted").call(["userID": currentUser!.ID, "friendID": friendID]) { (result, error) in
            
            if let error = error as NSError? {
              if error.domain == FunctionsErrorDomain {
                let code = FunctionsErrorCode(rawValue: error.code)
                let message = error.localizedDescription
                let details = error.userInfo[FunctionsErrorDetailsKey]
                
                print("ERRORED FUNCTION TEST RESULT: ", code!, message, details!)
              }
              // ...
            }
            if let text = result?.data as? String {
              print("SUCCESSFUL FUNCTION TEST RESULT: " + text)
            }
        }
    }
    
    
    
    func getFAQs(completion: @escaping (([String:String]) -> ())) {
        let db = Firestore.firestore()
        var FAQS: [String : String] = [:]
        
        db.collection("communityFAQS").getDocuments { (snapshot, err) in
            if err == nil {
                let documents = snapshot!.documents
                for doc in documents {
                    let data = doc.data()
                    let question = data["Question"] as! String
                    let answer = data["Answer"] as! String
                    FAQS[question] = answer
                }
                completion(FAQS)

            } else {
                print(err!.localizedDescription)
            }
        }

    }
    func getPhraseExamples(){
        let db = Firestore.firestore()
        db.collection("phraseExamples").getDocuments { (snapshot, err) in
            if err == nil {
                let documents = snapshot!.documents
                for doc in documents {
                    let result = Result {
                        try doc.data(as: PhraseExample.self)
                    }
                    switch result {
                        case .success(let phraseExample):
                            if let phraseExample = phraseExample {
                                
                                self.phraseExamples.append(phraseExample)
                            } else {
                                print("phraseExample does not exist")
                            }
                    case .failure(let error):
                        print("error decoding document: \(error)")
                }
                }
            } else {
                print(err!.localizedDescription)
            }
        }
    }
    func getFriendIDList(friendIDsAndBool: [(User, Bool)] ) -> [String]
    {
        var friendIDs: [String] = []
        for tuple in friendIDsAndBool {
            if tuple.1 {
                let user: User = tuple.0
                let uid: String = user.ID
                friendIDs.append(uid)
            }
        }
        return friendIDs
    }
    
    func getFriendNameWithID(friendID: String) -> String? {
        for friendUser in userFriends {
            if friendUser.ID == friendID {
                return friendUser.firstName
            }
        }
        return nil
        
    }
    
    func getUserNameFromID(ID: String, completion: @escaping ((String)-> (String))) -> String{
        let db = Firestore.firestore()
        var fullName: String = ""
        db.collection("users").document(ID).getDocument { (snapshot, err) in
            if snapshot != nil {
                let result = Result {
                    try snapshot!.data(as: User.self)
                }
                switch result {
                    case .success(let user):
                        if let user = user {
                            fullName = user.firstName + " " + user.lastName
                            print("FULL NAME FOR FRIEND USER TO BE IN POD FOUND FROM FIREBASE: ", fullName)
                        } else {
                            print("message does not exist")
                        }
                case .failure(let error):
                    print("error decoding document: \(error)")
                }
            } else {
                print(err!.localizedDescription)
            }
        }
        return completion(fullName)
    }
    func getPendingPods(completion: @escaping (() -> ())) {
        let db = Firestore.firestore()
        for pendingPodID in currentUser!.pendingPodIDs {
            db.collection("pendingPods").document(pendingPodID).getDocument { (snapshot, err) in
                if snapshot != nil {
                    let result = Result {
                        try snapshot!.data(as: PendingPod.self)
                    }
                    switch result {
                    case .success(let pendingPod):
                        if let pendingPod = pendingPod {
                            if !self.pendingPods.contains(pendingPod) {
                                self.pendingPods.append(pendingPod)
                                print("ADDING PENDING POD")
                                completion()
                            } else {
                                print("ALREADY LOADED THIS PENDING POD")
                            }
                        } else {
                            print("pending pod doesn't exist")
                        }
                    case .failure(let error):
                        print("error decoding document: ", error)

                        }
                } else {
                    print(err!.localizedDescription)
                }
            }
        }
    }
    
    func getFinishedPods() {
        let db = Firestore.firestore()
        for finishedPodID in currentUser!.finishedPodIDs {
            db.collection("finishedPods").document(finishedPodID).getDocument { (snapshot, err) in
                if snapshot != nil {
                    let result = Result {
                        try snapshot!.data(as: Pod.self)
                    }
                    switch result {
                    case .success(let finishedPod):
                        if let finishedPod = finishedPod {
                            if !self.finishedPods.contains(finishedPod) {
                                self.finishedPods.append(finishedPod)
                                print("ADDING FINISHED POD")
                                
                            } else {
                                print("ALREADY LOADED THIS finished Pod")
                            }
                        } else {
                            print("finished pod doesn't exist")
                        }
                    case .failure(let error):
                        print("error decoding finishedPod: ", error)

                        }
                } else {
                    print(err!.localizedDescription)
                }
            }
        }
    }

    func removeUserDataFromPodLocally(podID: String) {
        currentUser!.podsApartOfID = currentUser!.podsApartOfID.filter { id in
            return id != podID
        }
        userPods = userPods.filter { podWrapper in
            return podWrapper.podID != podID
        }
    }
    
    func sendInComplaint(complaint: Complaint) {
        let db = Firestore.firestore()
        do {
            try db.collection("complaints").document(complaint.complaintID).setData(from: complaint) { err in
                if err == nil{
                    print("Complaint added: \(complaint)")
                    print("For podID \(complaint.associatedPodID)")
                    self.leavePodCloudFuntion(complaint: complaint)
                } else {
                    print("error inside try: \(String(describing: err))")
                }
            }

        }
        catch let error {
                print("error outside try: \(error)")
        }
            
    }
    
    func leavePodCloudFuntion(complaint: Complaint) {
        let functions = Functions.functions()
        
        functions.httpsCallable("leavePod").call(["complaintID" : complaint.complaintID]) { (result, error) in
            
            if let error = error as NSError? {
              if error.domain == FunctionsErrorDomain {
                let code = FunctionsErrorCode(rawValue: error.code)
                let message = error.localizedDescription
                let details = error.userInfo[FunctionsErrorDetailsKey]
                
                print("ERRORED FUNCTION TEST RESULT: ", code!, message, details ?? "no Details")
              }
            }
            if let text = result?.data as? String {
              print("SUCCESSFUL FUNCTION TEST RESULT: " + text)
            }
        }
    }
    
    
    
    
    
    //ALL PURCHASES STUFF
    
    
    
    
    
    @Published var isPremium : Bool = false
    @Published var packages: [Purchases.Package]?
    @Published var purchaseStatus: String?
    @Published var unableToLoadPurchases: Bool = false //CURRENTLY NOT USED

    func enterPromoCode() {
        Purchases.shared.presentCodeRedemptionSheet()
    }
    
    func logInRevenueCat(userID: String, completion : @escaping ((Bool) -> ())) {
        Purchases.shared.logIn(userID) { purchaserInfo, created, error in
            if error == nil {
                print("sucessfully Logged in Revenue cat")
                if purchaserInfo!.entitlements.active["unlimited"]?.isActive != nil {
                    
                    print("successfully checked if premium. purchaserInfo!.entitlements.active[unlimited]!.isActive = ", purchaserInfo!.entitlements.active["unlimited"]!.isActive)
                    completion(purchaserInfo!.entitlements.active["unlimited"]!.isActive)
                } else {
                    print("purchaserInfo!.entitlements.active[unlimited]?.isActive == nil")
                    completion(false)
                }
            } else {
                print("ERROR Logging in: ", error!.localizedDescription)
                self.unableToLoadPurchases = true
                completion(false)
            }
        }
    }
    func checkIfPremium(completion : @escaping ((Bool) -> ())){
        
        print("checking if premium")
        Purchases.shared.purchaserInfo { (purchaserInfo, error) in
            if error == nil {
                if purchaserInfo!.entitlements.active["unlimited"]?.isActive != nil {
                    
                    print("successfully checked if premium. purchaserInfo!.entitlements.active[unlimited]!.isActive = ", purchaserInfo!.entitlements.active["unlimited"]!.isActive)
                    completion(purchaserInfo!.entitlements.active["unlimited"]!.isActive)
                } else {
                    print("purchaserInfo!.entitlements.active[unlimited]?.isActive == nil")
                    completion(false)
                }
            } else {
                print("ERROR CHECKING IF PREMIUM: ", error!.localizedDescription)
                completion(false)
            }
        }

    }
    
    func purchaseSubscription(packageToPurchase: Purchases.Package) {
        
        //        let db = Firestore.firestore()

        Purchases.shared.purchasePackage(packageToPurchase) { (transaction, purchaserInfo, err, userCancelled) in
            
            if purchaserInfo?.entitlements.all["unlimited"]?.isActive == true {
                self.isPremium = true
                print("SUBSCRIPTION PURCHASE SUCCESSFUL FOR " + packageToPurchase.identifier)
                self.purchaseStatus = "Purchase Sucessful"
                
//                        db.collection("users").document(self.currentUser!.ID).updateData(["isPaid" : true]) { err in
//                            if err != nil {
//                                print("Database error with purchase. Please try again or contact support at NickBuddyUp@gmail.com")
//                                completion("Database error with purchase. Please try again or contact support at NickBuddyUp@gmail.com")
//                            } else {
//                                print("Purchase Successful")
//                                completion("Purchase Successful")
//                            }
//                        }
                
            } else if userCancelled {
                print("User Cancelled Payment")
                self.purchaseStatus = "User Cancelled Payment"
            } else if err != nil {
                
                print(err!.localizedDescription)
                self.purchaseStatus = "Error making payment. Please try again or contact support at NickBuddyUp@gmail.com"
                
                
            } else if transaction?.error != nil {
               
                switch  Purchases.ErrorCode(_nsError: (transaction?.error!)! as NSError).code {
                case .purchaseNotAllowedError:
                    print("Purchases not allowed on this device. Please try again or contact support at NickBuddyUp@gmail.com")
                    self.purchaseStatus = "Purchases not allowed on this device. Please try again or contact support at NickBuddyUp@gmail.com"
                case .purchaseInvalidError:
                    print("Purchase invalid, check payment source. Please try again or contact support at NickBuddyUp@gmail.com")
                    self.purchaseStatus = "Purchase invalid, check payment source. Please try again or contact support at NickBuddyUp@gmail.com"
                default:
                    print("_________ default transaction error __________")
                    self.purchaseStatus = "Transaction Error. Please try again or contact support at NickBuddyUp@gmail.com"
                    break
                }
            }
        }
    }
    
    
    func getPackages(completion : @escaping (([Purchases.Package]?) -> ()))  {
        print("\n\n getting packages")
        Purchases.shared.offerings { (offerings, error) in
            if let packages = offerings?.current?.availablePackages {
                
                
//                let basicMonthlyProSubscriptionPackage = packages[0]
//                let product = basicMonthlyProSubscriptionPackage.product
//                let title = product.localizedTitle
//                let price = product.price
//                let identifier = product.productIdentifier
//                let subscriptionPeriod = product.subscriptionPeriod
//                var duration = ""
//
//                switch subscriptionPeriod!.unit {
//
//                case SKProduct.PeriodUnit.month:
//                    duration = "\(subscriptionPeriod!.numberOfUnits) Month"
//
//                case SKProduct.PeriodUnit.year:
//                    duration = "\(subscriptionPeriod!.numberOfUnits) Year"
//
//                default:
//                    duration = ""
//                }
                print("__________")
                print("SUCCESSFULLY GOT PACKAGES")
                print("__________")

                completion(packages)

            } else if error != nil {
                print("__________")

                print("GOT ERROR RETRIEVING PACKAGES: ", error!.localizedDescription)
                print("__________")

                completion(nil)
                
            } else {
                print("WEIRD ERROR RETRIEVING PACKAGES")
                print("offerings.debugDescription = ", offerings.debugDescription, offerings ?? "nil")
                print("offerings.current = ", offerings?.current ?? "nil")
                print("offerings?.current?.availablePackages = ", offerings?.current?.availablePackages ?? "nil")
                completion(nil)
            }
            
        }
        
        

    }
    func formPackageDisplayString(package: Purchases.Package) -> String {
    
        
        let packageIdentifier = package.identifier
        let packageLoacalizedPriceString = package.localizedPriceString
        



        print("packageIdentifier : " + packageIdentifier)
        print("packageLoacalizedPriceString : " + packageLoacalizedPriceString)

            let product = package.product

            let title = product.localizedTitle
            print("productTitle: " + title)


            let price = product.price
            print("price: ", price)
            let subscriptionPeriod = product.subscriptionPeriod
            print("subscriptionPeriod: ", subscriptionPeriod ?? "nil")
            var duration = ""

            switch subscriptionPeriod!.unit {

            case SKProduct.PeriodUnit.month:
                duration = "\(subscriptionPeriod!.numberOfUnits) Month"

            case SKProduct.PeriodUnit.year:
                duration = "\(subscriptionPeriod!.numberOfUnits) Year"

            default:
                duration = ""
            }
        print("duration: " + duration)
            //if duration == "1 Year" &&
            return (product.priceLocale.currencySymbol ?? "") + price.stringValue + " / " + duration
    }
    
    
    
    
    
    func fetchContacts() {
        
        let store = CNContactStore()
        
        let containerId = store.defaultContainerIdentifier()
        let predicate = CNContact.predicateForContactsInContainer(withIdentifier: containerId)
        // 4
        let keysToFetch = [CNContactGivenNameKey as CNKeyDescriptor,
                           CNContactFamilyNameKey as CNKeyDescriptor,
                           CNContactPhoneNumbersKey as CNKeyDescriptor,
                           CNContactEmailAddressesKey as CNKeyDescriptor
        ]
        
        
        do {
            let contacts = try store.unifiedContacts(matching: predicate, keysToFetch: keysToFetch)
//            var matchedUserList: [User] = []

            
            
            
            
            
            
            
            let contactsFilteredForEmails = contacts.filter { CNContact in
                return CNContact.emailAddresses.count > 0 && CNContact.emailAddresses.contains(where: { emailLabeledValue in
                    return String(CNContact.emailAddresses.first!.value).isValidEmail()
                    //MAYBE INSTEAD OF RETURNING FIRST, RETURN ARRAY AND FLATTEN
                })
            }
            
           var contactEmails = contactsFilteredForEmails.map { CNContact in
            return String(CNContact.emailAddresses.first!.value)
            //TODO: RIGHT NOW I AM ONLY TAKING THE FIRST EMAIL TO COME BACK IN CONTACTS. OBVIOUSLY IT WOULD BE MORE ROBUST TO TAKE ALL OF THEM
           }
            
            //PULLING MATCHED USERS IN BATCHES BECAUSE FIRESTORE CAN ONLY TAKE COMPARE TO 10 ELEMENTS AT A TIE
            while true {
                var contactEmailSlice: [String] = []
                if contactEmails.count > 10 {
                    
                    print("Total Email Count: ", contactEmails.count)
                    
                    
                    contactEmailSlice = Array(contactEmails[0...9])
                    contactEmails = Array(contactEmails[9...])
                    
                    findEmailMatchingContactsOnApp(emails: contactEmailSlice) { usersMatched in
                        let matchedWithoutDoubles = usersMatched.filter({ user in
                            return !self.contactsMatchedToUsers.contains(user)
                        })
                        self.contactsMatchedToUsers += matchedWithoutDoubles
//                        print("MATCHED USER LIST COUNT: ", matchedUserList.count) //NOTE: THIS NUMBER SHOULD BE NINE
                        
                    }
                    
                } else {
                    print("Total Email Count: ", contactEmails.count)
                    print("ENDING LOOP WITH REMAINDERS")
                    contactEmailSlice = contactEmails
                    
                    findEmailMatchingContactsOnApp(emails: contactEmailSlice) { usersMatched in
                        let matchedWithoutDoubles = usersMatched.filter({ user in
                            return !self.contactsMatchedToUsers.contains(user)
                        })
                        self.contactsMatchedToUsers += matchedWithoutDoubles
                    }
                    
                    break
                }
            }
            
            
            
            
            
            let contactsFilteredForPhone = contacts.filter { CNContact in
                return CNContact.phoneNumbers.count > 0
            }
            
            let contactPhoneNumbersNotNil = contactsFilteredForPhone.map { CNContact in
                return CNContact.phoneNumbers.first!.value.stringValue
             //return String(CNContact.phoneNumbers.first!.value)
             //TODO: RIGHT NOW I AM ONLY TAKING THE FIRST EMAIL TO COME BACK IN CONTACTS. OBVIOUSLY IT WOULD BE MORE ROBUST TO TAKE ALL OF THEM
            }
            
            
            
            
            
            
            
            
            var extraPhoneNumbersToCheck: [String] = []

            
            let prefixCodes : [String: String] = ["AF": "93", "AE": "971", "AL": "355", "AN": "599", "AS":"1", "AD": "376", "AO": "244", "AI": "1", "AG":"1", "AR": "54","AM": "374", "AW": "297", "AU":"61", "AT": "43","AZ": "994", "BS": "1", "BH":"973", "BF": "226","BI": "257", "BD": "880", "BB": "1", "BY": "375", "BE":"32","BZ": "501", "BJ": "229", "BM": "1", "BT":"975", "BA": "387", "BW": "267", "BR": "55", "BG": "359", "BO": "591", "BL": "590", "BN": "673", "CC": "61", "CD":"243","CI": "225", "KH":"855", "CM": "237", "CA": "1", "CV": "238", "KY":"345", "CF":"236", "CH": "41", "CL": "56", "CN":"86","CX": "61", "CO": "57", "KM": "269", "CG":"242", "CK": "682", "CR": "506", "CU":"53", "CY":"537","CZ": "420", "DE": "49", "DK": "45", "DJ":"253", "DM": "1", "DO": "1", "DZ": "213", "EC": "593", "EG":"20", "ER": "291", "EE":"372","ES": "34", "ET": "251", "FM": "691", "FK": "500", "FO": "298", "FJ": "679", "FI":"358", "FR": "33", "GB":"44", "GF": "594", "GA":"241", "GS": "500", "GM":"220", "GE":"995","GH":"233", "GI": "350", "GQ": "240", "GR": "30", "GG": "44", "GL": "299", "GD":"1", "GP": "590", "GU": "1", "GT": "502", "GN":"224","GW": "245", "GY": "595", "HT": "509", "HR": "385", "HN":"504", "HU": "36", "HK": "852", "IR": "98", "IM": "44", "IL": "972", "IO":"246", "IS": "354", "IN": "91", "ID":"62", "IQ":"964", "IE": "353","IT":"39", "JM":"1", "JP": "81", "JO": "962", "JE":"44", "KP": "850", "KR": "82","KZ":"77", "KE": "254", "KI": "686", "KW": "965", "KG":"996","KN":"1", "LC": "1", "LV": "371", "LB": "961", "LK":"94", "LS": "266", "LR":"231", "LI": "423", "LT": "370", "LU": "352", "LA": "856", "LY":"218", "MO": "853", "MK": "389", "MG":"261", "MW": "265", "MY": "60","MV": "960", "ML":"223", "MT": "356", "MH": "692", "MQ": "596", "MR":"222", "MU": "230", "MX": "52","MC": "377", "MN": "976", "ME": "382", "MP": "1", "MS": "1", "MA":"212", "MM": "95", "MF": "590", "MD":"373", "MZ": "258", "NA":"264", "NR":"674", "NP":"977", "NL": "31","NC": "687", "NZ":"64", "NI": "505", "NE": "227", "NG": "234", "NU":"683", "NF": "672", "NO": "47","OM": "968", "PK": "92", "PM": "508", "PW": "680", "PF": "689", "PA": "507", "PG":"675", "PY": "595", "PE": "51", "PH": "63", "PL":"48", "PN": "872","PT": "351", "PR": "1","PS": "970", "QA": "974", "RO":"40", "RE":"262", "RS": "381", "RU": "7", "RW": "250", "SM": "378", "SA":"966", "SN": "221", "SC": "248", "SL":"232","SG": "65", "SK": "421", "SI": "386", "SB":"677", "SH": "290", "SD": "249", "SR": "597","SZ": "268", "SE":"46", "SV": "503", "ST": "239","SO": "252", "SJ": "47", "SY":"963", "TW": "886", "TZ": "255", "TL": "670", "TD": "235", "TJ": "992", "TH": "66", "TG":"228", "TK": "690", "TO": "676", "TT": "1", "TN":"216","TR": "90", "TM": "993", "TC": "1", "TV":"688", "UG": "256", "UA": "380", "US": "1", "UY": "598","UZ": "998", "VA":"379", "VE":"58", "VN": "84", "VG": "1", "VI": "1","VC":"1", "VU":"678", "WS": "685", "WF": "681", "YE": "967", "YT": "262","ZA": "27" , "ZM": "260", "ZW":"263"]
            

            var contactPhoneNumbersFormatted : [String] = contactPhoneNumbersNotNil.map { phoneString -> String in
            var copy = phoneString
                
                
                //if covers +YY (XXX)-XXX-XX or +YY XXX XXX XXX phone numbers, else if covers 0XXXXXXXXX , else covers +YYXXXXXXXXX or YYXXXXXXXXXX or XXXXXXXXXX or (XXX) XXX-XXX
                
                if copy.contains("+") && copy.contains(" ") { //WE KNOW WHERE PREFIX IS SO WE CAN EASILY DELETE IT
                    print("before split: ", copy)
                    let splitCopy = copy.split(separator: " ", maxSplits: 1, omittingEmptySubsequences: true)
                    copy = splitCopy[1].string
                    print("After split: ", copy)
                    
                    copy.removeAll(where: {  ["+", " ", "-", "(", ")"].contains($0) })

                    
                    
                } else if copy[0] == "0" { //WE KNOW IT IS A DOMESTIC NUMBER SO WE CAN DELETE THE 0 AND NOT WORRY ABOUT INTERNATIONAL PREFIX
                    copy.remove(at: copy.startIndex)
                    copy.removeAll(where: {  ["+", " ", "-", "(", ")"].contains($0) })
                    
                } else { // WE DON'T KNOW IF IT IS A PREFIX
                    
                    if copy.contains("+") { //WE KNOW PHONE NUMBER IS INTERNATIONAL BUT WE DON'T KNOW WHAT THE PREFIX IS. SO WE SEARCH FOR IT AND DELETE.
                        copy.removeAll(where: {  ["+", " ", "-", "(", ")"].contains($0) })

                        for code in prefixCodes.values {
                            if copy.hasPrefix(code) {
                                print("phone number:  ", copy)
                                print("prefix Code: ",  code)
                                copy = copy.deletingPrefix( code)
                                copy.removeAll(where: {  [" ", "-", "(", ")"].contains($0) })
                            }
                        }
                        
                    } else { //WE DON'T KNOW IF IT HAS A PREFIX SO WE ADD ALL POSSIBLE INTERNATIONAL AND DOMESTIC VERSIONS OF THE NUMBER
                        copy.removeAll(where: {  [" ", "-", "(", ")"].contains($0) })
                        for code in prefixCodes.values {
                            if copy.hasPrefix(code) {
                                
                                print("phone number:  ", copy)
                                print("prefix Code: ", code)
                                copy.removeAll(where: {  [" ", "-", "(", ")"].contains($0) })
                                if copy.deletingPrefix(code)[0] == "0" { //NOT POSSIBLE. NUMBER DOESNT HAVE PREFIX
                                    break
                                } else {
                                    extraPhoneNumbersToCheck.append(copy)
                                    copy = copy.deletingPrefix(code)
                                    break //ONCE WE FOUND A PREFIX THAT FITS, NO OTHER PREFIX IS POSSIBLE EX: becuase USA has +1, there are no other countries with +1X or +1XX
                                }

                                 
                            }
                        }
                    }

                }

                return copy
            }
            
            print(contactPhoneNumbersFormatted)
            print("EXTRA PHONE NUMBERS:  ", extraPhoneNumbersToCheck)
            
            contactPhoneNumbersFormatted = contactPhoneNumbersFormatted + extraPhoneNumbersToCheck
         
            while true {
                var contactPhoneSlice: [String] = []
                if contactPhoneNumbersFormatted.count > 10 {
                    
                    print("Total PHone Count: ", contactPhoneNumbersFormatted.count)
                    
                    
                    contactPhoneSlice = Array(contactPhoneNumbersFormatted[0...9])
                    contactPhoneNumbersFormatted = Array(contactPhoneNumbersFormatted[9...])
                    
                    findPhoneMatchingContactsOnApp(phoneNumbers: contactPhoneSlice) { usersMatched in
                        let matchedWithoutDoubles = usersMatched.filter({ user in
                            return !self.contactsMatchedToUsers.contains(user)
                        })
                        self.contactsMatchedToUsers += matchedWithoutDoubles
//                        print("MATCHED USER LIST COUNT: ", matchedUserList.count) //NOTE: THIS NUMBER SHOULD BE NINE
                        
                    }
                    
                } else {
                    print("Total Phone Count: ", contactPhoneNumbersFormatted.count)
                    print("ENDING LOOP WITH REMAINDERS")
                    contactPhoneSlice = contactPhoneNumbersFormatted
                    
                    findPhoneMatchingContactsOnApp(phoneNumbers: contactPhoneSlice){ usersMatched in
                        let matchedWithoutDoubles = usersMatched.filter({ user in
                            return !self.contactsMatchedToUsers.contains(user)
                        })
                        self.contactsMatchedToUsers += matchedWithoutDoubles
                    }
                    
                    break
                }
            }
            
            

            
            
            
            
            
            //REPEAT FOR PHONE NUMBERS
            
            
            
            
            
            
        }
        catch {
            print("error fetching Contact")
        }
    }
    
    func findPhoneMatchingContactsOnApp(phoneNumbers: [String], completion : @escaping (([User]) -> ())) {
        //TODO: SHOULD WORK MOST LIKE EMAIL COUNTERPART, EXCEPT NEED TO FIND A WAY TO MATCH PHONE NUMBERS WITH INCONSISTENT COUNTRY CODES AND PHONE NUMBER LENGTHS. MAYBE WITH STRING SEGMENTS
        
        let db = Firestore.firestore()
        var userList: [User] = []
        db.collection("users").whereField("phoneNumber", in: phoneNumbers).getDocuments { (querySnapshot, error) in
            if error != nil {
                print("error retrieving document: " + error.debugDescription)
                return
            }
            else {
                for doc in querySnapshot!.documents {
                    let result = Result {
                        try doc.data(as: User.self)
                    }
                    switch result {
                        case .success(let user):
                            if let user = user {
                                if user != self.currentUser && !userList.contains(user) {
                                    print("Matched user with ID: " + user.ID + " and name: " + user.firstName + " " + user.lastName)
                                    userList.append(user)
                                }
                                
                            } else {
                                print("user does not exist")
                            }
                    case .failure(let error):
                        print("error decoding document: \(error)")
                    }
                }
                completion(userList)
            }
        }
        
    }
//
    
    func findEmailMatchingContactsOnApp(emails: [String], completion : @escaping (([User]) -> ())) {
        let db = Firestore.firestore()
        var userList: [User] = []
        db.collection("users").whereField("email", in: emails).getDocuments { (querySnapshot, error) in
            if error != nil {
                print("error retrieving document: " + error.debugDescription)
                return
            }
            else {
                for doc in querySnapshot!.documents {
                    let result = Result {
                        try doc.data(as: User.self)
                    }
                    switch result {
                        case .success(let user):
                            if let user = user {
                                if user != self.currentUser && !userList.contains(user) {
                                    print("Matched user with ID: " + user.ID + " and name: " + user.firstName + " " + user.lastName)
                                    userList.append(user)
                                }
                                
                            } else {
                                print("user does not exist")
                            }
                    case .failure(let error):
                        print("error decoding document: \(error)")
                    }
                }
                completion(userList)
            }
        }
            
    }

    func addPhoneNumber(phoneNumber: String, completion: @escaping ((Bool) ->())) {
        let db = Firestore.firestore()
        var copy = phoneNumber
        if copy[0] == "0" { //EASIER TO STANDARDIZE WITHOUT THE 0. WE REMOVE THE 0 WHEN SEARCHING.
            copy.remove(at: copy.startIndex)
        }
        
        
        db.collection("users").document(currentUser!.ID).updateData([
            
                        "phoneNumber" : copy
        ]) {
            err in
            if err != nil {
                print("error updating users")
                completion(false)
                return
            } else {
                print("token added")
                completion(true)
            }
 
        
        
        }
        
    }

    
}
