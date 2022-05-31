//
//  PhotosFinding+Sentences.swift
//  Find
//
//  Created by A. Zheng (github.com/aheze) on 5/31/22.
//  Copyright © 2022 A. Zheng. All rights reserved.
//

import RealmSwift
import UIKit

extension RealmSwift.List where Element == RealmSentence {
    /// check if a sentence contains the search
    func checkIf(realmModel: RealmModel, matches searches: [String]) -> Bool {
        for sentence in self {
            guard let string = sentence.string else { continue }
            if Finding.checkIf(realmModel: realmModel, stringToSearchFrom: string, matches: searches) {
                return true
            }
        }
        return false
    }
}
