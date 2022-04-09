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
        return search.contains { text in
            string.localizedCaseInsensitiveContains(text)
        }
    }

    static func checkIf(realmModel: RealmModel, string: String, contains text: String) -> Bool {
        return string.localizedCaseInsensitiveContains(text)
    }
}
