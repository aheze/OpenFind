//
//  RealmModel+Lists.swift
//  Find
//
//  Created by A. Zheng (github.com/aheze) on 4/16/22.
//  Copyright © 2022 A. Zheng. All rights reserved.
//

import UIKit

extension RealmModel {
    
    /// load and sort lists for direct use in `Lists`
    func loadAndSortLists(_ lists: [List]) {
        guard let sortBy = Settings.Values.ListsSortByLevel(rawValue: listsSortBy) else {
            self.lists = lists
            return
        }

        /// newest first
        switch sortBy {
        case .newestFirst:
            let sortedLists = lists.sorted { $0.dateCreated > $1.dateCreated }
            self.lists = sortedLists
        case .oldestFirst:
            let sortedLists = lists.sorted { $0.dateCreated > $1.dateCreated }
            self.lists = sortedLists
        case .title:
            let sortedLists = lists
                .sorted {
                    let a = $0.displayedTitle.trimmingCharacters(in: .whitespacesAndNewlines)
                    let b = $1.displayedTitle.trimmingCharacters(in: .whitespacesAndNewlines)
                    return a < b
                }

            self.lists = sortedLists
        }
    }
}
