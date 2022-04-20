//
//  Finding.swift
//  Find
//
//  Created by A. Zheng (github.com/aheze) on 4/7/22.
//  Copyright © 2022 A. Zheng. All rights reserved.
//

import UIKit

enum Finding {
    /// check if a string matches the search (the string contains at least one of the searches)
    static func checkIf(realmModel: RealmModel, string: String, matches search: [String]) -> Bool {
        let stringToSearchFrom = string.applyDefaults(realmModel: realmModel)
        return search.contains { text in
            let stringToSearch = text.applyDefaults(realmModel: realmModel)
            return stringToSearchFrom.contains(stringToSearch)
        }
    }

    static func checkIf(realmModel: RealmModel, string: String, contains text: String) -> Bool {
        let stringToSearchFrom = string.applyDefaults(realmModel: realmModel)
        let stringToSearch = text.applyDefaults(realmModel: realmModel)
        return stringToSearchFrom.contains(stringToSearch)
    }
}

extension String {
    /// apply `findingMatchCase` and `findingMatchAccents` to a string
    func applyDefaults(realmModel: RealmModel) -> String {
        var string = self
        if !realmModel.findingMatchCase {
            string = string.lowercased()
        }
        if !realmModel.findingMatchAccents {
            string = string.folding(options: .diacriticInsensitive, locale: .current)
        }
        return string
    }
}
