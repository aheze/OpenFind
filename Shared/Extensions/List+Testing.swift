//
//  List+Testing.swift
//  Find
//
//  Created by A. Zheng (github.com/aheze) on 1/28/22.
//  Copyright © 2022 A. Zheng. All rights reserved.
//

import UIKit

extension List {
    static func getSampleLists() -> [List] {
        let lists = [
            List(
                title: "Nature",
                description: "Words",
                icon: "leaf.fill",
                color: 0x1f7000,
                words: ["Leaf", "Ant", "Stick", "Branch", "Tree", "Ant", "Stick", "Branch", "Tree"],
                dateCreated: Date()
            ),
            List(
                title: "Dairy-free",
                description: "Milk and stuff",
                icon: "square.and.arrow.up.trianglebadge.exclamationmark",
                color: 0x004c7f,
                words: ["Milk", "Cheese", "Dairy", "Yogurt", "Ice Cream", "Butter", "Whipped Cream", "Cream", "Crackers", "Mochas", "Graham Crackers", "Cream"],
                dateCreated: Date()
            ),
            List(
                title: "Photo Editing",
                description: "Should learn this",
                icon: "lasso.and.sparkles",
                color: 0xda00ff,
                words: ["Computer", "Leaf", "Ant", "Stick", "Branch", "Tree", "Stick", "Branch", "Tree", "Stick", "Branch", "Tree"],
                dateCreated: Date()
            ),
            List(
                title: "Plans",
                description: "Some words about plans",
                icon: "calendar.day.timeline.left",
                color: 0x008bd8,
                words: ["Computer", "Leaf", "Ant", "Stick", "Branch", "Tree", "Stick", "Branch", "Tree", "Stick", "Branch", "Tree"],
                dateCreated: Date()
            ),
            List(
                title: "Computer Stuff",
                description: "Keyboard",
                icon: "keyboard.fill",
                color: 0xdd000e,
                words: ["Computer", "Leaf", "Ant", "Stick", "Branch", "Tree", "Stick", "Branch", "Tree", "Stick", "Branch", "Tree"],
                dateCreated: Date()
            ),
            List(
                title: "Video Editing",
                description: "DaVinci Resolve",
                icon: "sparkles.square.filled.on.square",
                color: 0xaddd00,
                words: ["Leaf", "Ant", "Stick", "Branch", "Tree"],
                dateCreated: Date()
            ),
            List(
                title: "Popovers",
                description: "A library to present popovers",
                icon: "rectangle.trailinghalf.inset.filled.arrow.trailing",
                color: 0x007eef,
                words: ["Leaf", "Ant", "Stick", "Branch", "Tree"],
                dateCreated: Date()
            ),
            List(
                title: "Drama",
                description: "Words about drama",
                icon: "theatermasks",
                color: 0xe2ac00,
                words: ["Leaf", "Ant", "Stick", "Branch", "Tree"],
                dateCreated: Date()
            ),
            List(
                title: "Drama",
                description: "Words about drama",
                icon: "theatermasks",
                color: 0xe2ac00,
                words: ["Leaf", "Ant", "Stick", "Branch", "Tree"],
                dateCreated: Date()
            )
        ]

        return lists
    }
}
