//
//  ListsViewModel.swift
//  Lists
//
//  Created by Zheng on 12/3/21.
//  Copyright © 2021 Andrew. All rights reserved.
//

import UIKit

class ListsViewModel: ObservableObject {
    @Published var lists: [List] = [
        List(
            name: "Nature",
            desc: "Words",
            contents: ["Leaf", "Ant", "Stick", "Branch", "Tree"],
            iconImageName: "leaf.fill",
            iconColorName: 0x1F7000,
            dateCreated: Date()
        ),
        List(
            name: "Dairy-free",
            desc: "Words",
            contents: ["Leaf", "Ant", "Stick", "Branch", "Tree"],
            iconImageName: "leaf.fill",
            iconColorName: 0x004C7F,
            dateCreated: Date()
        ),
        List(
            name: "Gluten-free foods",
            desc: "Words",
            contents: ["Leaf", "Ant", "Stick", "Branch", "Tree"],
            iconImageName: "leaf.fill",
            iconColorName: 0xE2AC00,
            dateCreated: Date()
        )
    ]
}

struct List {
    var name = ""
    var desc = ""
    var contents = [String]()
    var iconImageName = ""
    var iconColorName: UInt = 0xAEEF
    var dateCreated = Date()
}
