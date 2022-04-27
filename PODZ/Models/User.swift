//
//  User.swift
//  PODZ
//
//  Created by Nick Miller on 6/15/20.
//  Copyright © 2020 Nick Miller. All rights reserved.
//

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift




class User: Identifiable, Codable, Equatable {
    
    static func == (lhs: User, rhs: User) -> Bool {
        return lhs.ID == rhs.ID
    }
    
    
    var podsApartOfID: [String]
    var firstName: String
    var lastName: String
    var ID: String
    var email: String
    var friendIDs: [String]
    var incomingFriendRequestIDs: [String]
    var pendingSentFriendRequestsIDs: [String]
    var userIsPaid: Bool
    var userBannedList: [String]
    var doneAppTutorial: Bool
    var donePodTutorial: Bool
    var token: [String]
    var dateCreated: Timestamp
    var pendingPodIDs: [String]
    var finishedPodIDs: [String]
    var phoneNumber: String?
    
    init(fn: String, ln: String, uid: String, email: String, paid: Bool, dateCreated: Timestamp) {
        self.podsApartOfID = []
        self.ID = uid
        self.firstName = fn
        self.lastName = ln
        self.friendIDs = []
        self.incomingFriendRequestIDs = []
        self.userBannedList = []
        self.email = email
        self.userIsPaid = paid
        self.doneAppTutorial = false
        self.donePodTutorial = false
        self.dateCreated = dateCreated
        self.pendingPodIDs = []
        self.finishedPodIDs = []
        self.pendingSentFriendRequestsIDs = []
        self.token = []
        self.phoneNumber = nil
    }
    

    
}
