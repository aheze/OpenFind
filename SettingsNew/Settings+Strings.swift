//
//  SettingsVM+Strings.swift
//  Find
//
//  Created by A. Zheng (github.com/aheze) on 4/5/22.
//  Copyright © 2022 A. Zheng. All rights reserved.
//

import SwiftUI

extension Settings.StringIdentifier {
    func getString(realmModel: RealmModel) -> String {
        switch self {
        case .keepWhitespace:
            if realmModel.findingKeepWhitespace {
                return "Keep leading and trailing whitespace in entered text in the search bar. Also affects words inside lists."
            } else {
                return "Trim whitespace from entered text in the search bar. Also affects words inside lists."
            }
        case .filterLists:
            if realmModel.findingFilterLists {
                return "Filter lists when typing in the search bar."
            } else {
                return "Always show all lists in the search bar."
            }
        }
    }
}
