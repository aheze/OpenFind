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
        let displayedLists = getLists().map { DisplayedList(list: $0) }
        guard !text.isEmpty else {
            model.displayedLists = displayedLists
            update()
            return
        }

        let filteredDisplayedLists = displayedLists.filter { displayedList in
            text.contains { word in
                displayedList.list.displayedTitle.localizedCaseInsensitiveContains(word)
                    || displayedList.list.description.localizedCaseInsensitiveContains(word)
            }
        }

        model.displayedLists = filteredDisplayedLists
        update()
    }
}
