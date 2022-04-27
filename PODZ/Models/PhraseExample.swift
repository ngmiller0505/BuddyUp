//
//  PhraseExample.swift
//  PODZ
//
//  Created by Nick Miller on 3/28/21.
//  Copyright © 2021 Nick Miller. All rights reserved.
//

import Foundation


class PhraseExample: Identifiable, Codable {
    let habitType : String
    let logPhrases: [String]
    let reminderPhrases: [String]
    
    init(habitType: String, logPhrases: [String], reminderPhrases: [String]) {
        self.habitType = habitType
        self.logPhrases = logPhrases
        self.reminderPhrases = reminderPhrases
    }
}

