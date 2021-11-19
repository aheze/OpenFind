//
//  Bridge.swift
//  Lists
//
//  Created by Zheng on 11/18/21.
//

import UIKit

public struct Bridge {
    public static func makeController() -> ListsController {
        let lists = ListsController()
        return lists
    }
}
