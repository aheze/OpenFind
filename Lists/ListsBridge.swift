//
//  Bridge.swift
//  Lists
//
//  Created by Zheng on 11/18/21.
//

import UIKit

struct ListsBridge {
    static func makeController(listsViewModel: ListsViewModel) -> ListsController {
        let lists = ListsController(listsViewModel: listsViewModel)
        return lists
    }
}
