//
//  RC+Lists.swift
//  Find
//
//  Created by A. Zheng (github.com/aheze) on 3/31/22.
//  Copyright © 2022 A. Zheng. All rights reserved.
//

import Foundation

extension RealmContainer {
    func loadLists() {
        listsUpdated?(lists)
    }
    
    func addList(list: List) {
        self.lists.append(list)
    }

    func updateList(list: List) {
        if let firstIndex = lists.firstIndex(where: { $0.id == list.id }) {
            lists[firstIndex] = list
        }
    }

    func deleteList(list: List) {
        if let firstIndex = lists.firstIndex(where: { $0.id == list.id }) {
            lists.remove(at: firstIndex)
        }
    }
}
