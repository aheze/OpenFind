//
//  ListsVC+Find.swift
//  Find
//
//  Created by A. Zheng (github.com/aheze) on 4/7/22.
//  Copyright © 2022 A. Zheng. All rights reserved.
//

import UIKit

extension ListsViewController {
    func find(text: [String]) {
        let displayedLists = realmModel.lists.map { DisplayedList(list: $0) }
        guard !text.isEmpty else {
            model.displayedLists = displayedLists
            update()
            return
        }

        let filteredDisplayedLists = displayedLists.filter { displayedList in

            Finding.checkIf(realmModel: self.realmModel, string: displayedList.list.displayedTitle, matches: text)
                || Finding.checkIf(realmModel: self.realmModel, string: displayedList.list.description, matches: text)
        }

        model.displayedLists = filteredDisplayedLists
        update()
    }
}
