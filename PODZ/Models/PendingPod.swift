//
//  pendingPod.swift
//  PODZ
//
//  Created by Nick Miller on 4/26/21.
//  Copyright © 2021 Nick Miller. All rights reserved.
//

import Foundation
import Firebase




//Pending Pods are for objects that show user what groups he has pending and add commitmentLength and FriendIDs to podApplication if it is a user accepting another user's friend group invite. They aren't used for anything on the backend. They can either be as type "friend" or type "community"
//if communityOrFriendGroup == "friend" : Pending pods are created for ALL INVITED friends ONLY. Pending Pod is not created for original group Creator (instead, regular is created for him). Friend Pending Pods are deleted from the front end when 
class PendingPod: Equatable, Encodable, Decodable, Identifiable {
    
    static func == (lhs: PendingPod, rhs: PendingPod) -> Bool {
        return lhs.id == rhs.id
    }
    
    
    
    let UID: String
    let id: String
    let communityOrFriendGroup: String //"Friend" or "Community"
    let podIDIfFriendInvite: String?
    var friendWhoSentInvite: String?
    var friendNameWhoSentInvite: String?
    var friendInviteMessage: String?
    let communityCategoryAppliedFor: String?
    var communityPodETABottom: Int?
    var communityPodETATop: Int?
    var dateCreated: Timestamp
    var commitmentLength : Int
    var isFriendPodLockedIn: Bool?
    
    init(UID: String, id: String, communityOrFriendGroup: String, podIDIfFriend: String?, friendWhoSentInvite: String?, friendInviteMessage: String?, friendNameWhoSentInvite: String?, communityCategoryAppliedFor: String?, communityPodETABottom: Int?, communityPodETATop: Int?, commitmentLength: Int, isFriendPodLockedIn: Bool?) {
        
        self.UID = UID
        self.id = id
        self.communityOrFriendGroup = communityOrFriendGroup
        self.podIDIfFriendInvite = podIDIfFriend
        self.friendWhoSentInvite = friendWhoSentInvite
        self.communityCategoryAppliedFor = communityCategoryAppliedFor
        self.communityPodETABottom = communityPodETABottom
        self.communityPodETATop = communityPodETATop
        self.dateCreated = Timestamp()
        self.friendNameWhoSentInvite = friendNameWhoSentInvite
        self.commitmentLength = commitmentLength
        self.isFriendPodLockedIn = isFriendPodLockedIn
        
    }
    
}
