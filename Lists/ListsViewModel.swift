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
            contents: ["Leaf", "Ant", "Stick", "Branch", "Tree", "Ant", "Stick", "Branch", "Tree"],
            dateCreated: Date()
        ),
        List(
            name: "Dairy-free",
            desc: "Milk and stuff",
            image: "square.and.arrow.up.trianglebadge.exclamationmark",
            color: 0x004C7F,
            contents: ["Milk", "Cheese", "Dairy", "Yogurt", "Ice Cream", "Butter", "Whipped Cream", "Cream", "Crackers", "Mochas", "Graham Crackers", "Cream"],
            dateCreated: Date()
        ),
        List(
            name: "Photo Editing",
            desc: "Photoshop maybe",
            image: "lasso.and.sparkles",
            color: 0x004C7F,
            contents: ["Computer", "Leaf", "Ant", "Stick", "Branch", "Tree", "Stick", "Branch", "Tree", "Stick", "Branch", "Tree"],
            dateCreated: Date()
        ),
        List(
            name: "Plans",
            desc: "Some words about plans",
            image: "calendar.day.timeline.left",
            color: 0x004C7F,
            contents: ["Computer", "Leaf", "Ant", "Stick", "Branch", "Tree", "Stick", "Branch", "Tree", "Stick", "Branch", "Tree"],
            dateCreated: Date()
        ),
        List(
            name: "Computer Stuff",
            desc: "Keyboard",
            image: "keyboard.fill",
            color: 0x004C7F,
            contents: ["Computer", "Leaf", "Ant", "Stick", "Branch", "Tree", "Stick", "Branch", "Tree", "Stick", "Branch", "Tree"],
            dateCreated: Date()
        ),
        List(
            name: "Video Editing",
            desc: "DaVinci Resolve",
            image: "sparkles.square.filled.on.square",
            color: 0xE2AC00,
            contents: ["Leaf", "Ant", "Stick", "Branch", "Tree"],
            dateCreated: Date()
        ),
        List(
            name: "Popovers",
            desc: "A library to present popovers",
            image: "rectangle.trailinghalf.inset.filled.arrow.trailing",
            color: 0xE2AC00,
            contents: ["Leaf", "Ant", "Stick", "Branch", "Tree"],
            dateCreated: Date()
        ),
        List(
            name: "Drama",
            desc: "Words about drama",
            image: "theatermasks",
            color: 0xE2AC00,
            contents: ["Leaf", "Ant", "Stick", "Branch", "Tree"],
            dateCreated: Date()
        ),
        List(
            name: "Drama",
            desc: "Words about drama",
            image: "theatermasks",
            color: 0xE2AC00,
            contents: ["Leaf", "Ant", "Stick", "Branch", "Tree"],
            dateCreated: Date()
        ),
        List(
            name: "Drama",
            desc: "Words about drama",
            image: "theatermasks",
            color: 0xE2AC00,
            contents: ["Leaf", "Ant", "Stick", "Branch", "Tree"],
            dateCreated: Date()
        ),
        List(
            name: "Drama",
            desc: "Words about drama",
            image: "theatermasks",
            color: 0xE2AC00,
            contents: ["Leaf", "Ant", "Stick", "Branch", "Tree"],
            dateCreated: Date()
        ),
        List(
            name: "Drama",
            desc: "Words about drama",
            image: "theatermasks",
            color: 0xE2AC00,
            contents: ["Leaf", "Ant", "Stick", "Branch", "Tree"],
            dateCreated: Date()
        )
    ]
    
    /// lists shown by the collection view, can be filtered
    @Published var displayedLists = [DisplayedList]()
}
