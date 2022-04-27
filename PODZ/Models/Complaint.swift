//
//  Complaint.swift
//  PODZ
//
//  Created by Nick Miller on 4/4/21.
//  Copyright © 2021 Nick Miller. All rights reserved.
//

import Foundation

class Complaint: Codable {
    
    var type: String //habit or person
    var associatedPodID: String
    var complainerID: String
    var complainerAlias: String
    var complainedAgainstIDs: [String]?
    var details: String
    var complaintID: String

    init(type: String, complainerID: String, complainedAgainstIDs: [String]?, details: String, associatedPod: String, complainerAlias: String) {
        self.type = type
        self.complainerID = complainerID
        self.complainedAgainstIDs = complainedAgainstIDs
        self.details = details
        self.associatedPodID = associatedPod
        self.complaintID = UUID().uuidString
        self.complainerAlias = complainerAlias
    }
}
