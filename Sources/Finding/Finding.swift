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
    static func checkIf(realmModel: RealmModel, stringToSearchFrom: String, matches searches: [String]) -> Bool {
        return searches.contains { search in
            checkIf(realmModel: realmModel, stringToSearchFrom: stringToSearchFrom, contains: search)
        }
    }

    static func checkIf(realmModel: RealmModel, stringToSearchFrom: String, contains search: String) -> Bool {
        if realmModel.findingMatchCase {
            if realmModel.findingMatchAccents {
                /// match both case and accents.
                return stringToSearchFrom.contains(search)
            } else {
                /// match case, accents don't matter. Could be taxing on the CPU
                return stringToSearchFrom
                    .folding(options: .diacriticInsensitive, locale: .current)
                    .contains(
                        search.folding(options: .diacriticInsensitive, locale: .current)
                    )
            }
        } else {
            if realmModel.findingMatchAccents {
                /// match accents but not case
                return stringToSearchFrom.localizedCaseInsensitiveContains(search)
            } else {
                /// don't match anything
                return stringToSearchFrom.localizedStandardContains(search)
            }
        }
    }

    static func getNumberOfMatches(realmModel: RealmModel, stringToSearchFrom: String, matches searches: [String]) -> Int {
        let stringToSearchFrom = stringToSearchFrom.applyDefaults(realmModel: realmModel)

        var count = 0
        for search in searches {
            let stringToSearch = search.applyDefaults(realmModel: realmModel)
            let indices = stringToSearchFrom.indicesOf(string: stringToSearch)
            count += indices.count
        }
        return count
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
