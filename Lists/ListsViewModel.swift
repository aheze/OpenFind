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
            icon: "leaf.fill",
            color: 0x1F7000,
            words: ["Leaf", "Ant", "Stick", "Branch", "Tree", "Ant", "Stick", "Branch", "Tree"],
            dateCreated: Date()
        ),
        List(
            name: "Dairy-free",
            desc: "Milk and stuff",
            icon: "square.and.arrow.up.trianglebadge.exclamationmark",
            color: 0x004C7F,
            words: ["Milk", "Cheese", "Dairy", "Yogurt", "Ice Cream", "Butter", "Whipped Cream", "Cream", "Crackers", "Mochas", "Graham Crackers", "Cream"],
            dateCreated: Date()
        ),
        List(
            name: "Photo Editing",
            desc: "Should learn this",
            icon: "lasso.and.sparkles",
            color: 0xda00ff,
            words: ["Computer", "Leaf", "Ant", "Stick", "Branch", "Tree", "Stick", "Branch", "Tree", "Stick", "Branch", "Tree"],
            dateCreated: Date()
        ),
        List(
            name: "Plans",
            desc: "Some words about plans",
            icon: "calendar.day.timeline.left",
            color: 0x008bd8,
            words: ["Computer", "Leaf", "Ant", "Stick", "Branch", "Tree", "Stick", "Branch", "Tree", "Stick", "Branch", "Tree"],
            dateCreated: Date()
        ),
        List(
            name: "Computer Stuff",
            desc: "Keyboard",
            icon: "keyboard.fill",
            color: 0xdd000e,
            words: ["Computer", "Leaf", "Ant", "Stick", "Branch", "Tree", "Stick", "Branch", "Tree", "Stick", "Branch", "Tree"],
            dateCreated: Date()
        ),
        List(
            name: "Video Editing",
            desc: "DaVinci Resolve",
            icon: "sparkles.square.filled.on.square",
            color: 0xaddd00,
            words: ["Leaf", "Ant", "Stick", "Branch", "Tree"],
            dateCreated: Date()
        ),
        List(
            name: "Popovers",
            desc: "A library to present popovers",
            icon: "rectangle.trailinghalf.inset.filled.arrow.trailing",
            color: 0x007eef,
            words: ["Leaf", "Ant", "Stick", "Branch", "Tree"],
            dateCreated: Date()
        ),
        List(
            name: "Drama",
            desc: "Words about drama",
            icon: "theatermasks",
            color: 0xE2AC00,
            words: ["Leaf", "Ant", "Stick", "Branch", "Tree"],
            dateCreated: Date()
        ),
        List(
            name: "Drama",
            desc: "Words about drama",
            icon: "theatermasks",
            color: 0xE2AC00,
            words: ["Leaf", "Ant", "Stick", "Branch", "Tree"],
            dateCreated: Date()
        )
    ]
    
    /// lists shown by the collection view, can be filtered
    @Published var displayedLists = [DisplayedList]()
}
