//
//  Bridge.swift
//  Lists
//
//  Created by Zheng on 11/18/21.
//

import UIKit

struct ListsBridge {
    static func makeController(listsViewModel: ListsViewModel, toolbarViewModel: ToolbarViewModel) -> ListsController {
        let lists = ListsController(listsViewModel: listsViewModel, toolbarViewModel: toolbarViewModel)
        return lists
    }
}
