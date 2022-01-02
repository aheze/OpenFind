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
            image: "leaf.fill",
            color: 0x1F7000,
            contents: ["Leaf", "Ant", "Stick", "Branch", "Tree"],
            dateCreated: Date()
        ),
        List(
            name: "Dairy-free",
            desc: "Words",
            image: "leaf.fill",
            color: 0x004C7F,
            contents: ["Leaf", "Ant", "Stick", "Branch", "Tree"],
            dateCreated: Date()
        ),
        List(
            name: "Gluten-free foods",
            desc: "Words",
            image: "leaf.fill",
            color: 0xE2AC00,
            contents: ["Leaf", "Ant", "Stick", "Branch", "Tree"],
            dateCreated: Date()
        )
    ]
}
