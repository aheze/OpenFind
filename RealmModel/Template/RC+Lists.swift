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
        listsUpdated?(List.getSampleLists())
    }

    func addList(list: List) {}

    func updateList(list: List) {}

    func deleteList(list: List) {}
}
