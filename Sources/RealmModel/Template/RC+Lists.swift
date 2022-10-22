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
        var lists = List.defaultLists

        guard
            let model = getModel?(),
            let sortBy = Settings.Values.ListsSortByLevel(rawValue: model.listsSortBy)
        else { return }

        switch sortBy {
        case .newestFirst:
            lists = lists.sorted { $0.dateCreated > $1.dateCreated }
        case .oldestFirst:
            lists = lists.sorted { $0.dateCreated < $1.dateCreated }
        case .title:
            lists = lists.sorted {
                let a = $0.displayedTitle.trimmingCharacters(in: .whitespacesAndNewlines)
                let b = $1.displayedTitle.trimmingCharacters(in: .whitespacesAndNewlines)
                return a < b
            }
        }

        model.lists = lists
    }

    func addList(list: List) {}

    func updateList(list: List) {}

    func deleteList(list: List) {}
}
