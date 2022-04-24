//
//  ListsDefaults.swift
//  Find
//
//  Created by A. Zheng (github.com/aheze) on 4/20/22.
//  Copyright © 2022 A. Zheng. All rights reserved.
//

import UIKit

extension List {
    static var defaultLists: [List] {
        var lists: [List] = [
            .init(
                title: "Beef",
                description: "Meat from cows",
                icon: "capsule.fill",
                color: 0x612F00,
                words: [
                    "Cow",
                    "Beef",
                    "Steak",
                    "Ribeye",
                    "Tenderloin",
                    "Filet Mignon",
                    "Porterhouse",
                    "T-Bone",
                    "Flank",
                    "Ribs",
                    "Bovine",
                    "Burger",
                    "Pastrami"
                ],
                dateCreated: Date()
            ),
            .init(
                title: "Nuts",
                description: "Assorted nuts",
                icon: "capsule.portrait.fill",
                color: 0x9E6800,
                words: [
                    "Nut",
                    "Peanut",
                    "Macadamia",
                    "Almonds",
                    "Cashew",
                    "Chestnut",
                    "Walnut",
                    "Hazelnut",
                    "Pecans",
                    "Pistachio"
                ],
                dateCreated: Date()
            ),
            .init(
                title: "Dairy",
                description: "Milk/lactose",
                icon: "cup.and.saucer.fill",
                color: 0x008DC6,
                words: [
                    "Milk",
                    "Butter",
                    "Casein",
                    "Cheese",
                    "Cream",
                    "Custard",
                    "Whey",
                    "Lactalbumin",
                    "Lactoglobulin",
                    "Lactoferrin",
                    "Lactose",
                    "Margarine",
                    "Nisin",
                    "Nougat",
                    "Rennet",
                    "Yogurt"
                ],
                dateCreated: Date()
            ),
            .init(
                title: "Gluten",
                description: "Wheat and other stuff",
                icon: "cup.and.saucer.fill",
                color: 0xFFA701,
                words: [
                    "Gluten",
                    "Wheat",
                    "Barley",
                    "Bulgur",
                    "Couscous",
                    "Durum",
                    "Einkorn",
                    "Emmer",
                    "Farina",
                    "Farro",
                    "Graham flour",
                    "Kamut",
                    "Matzo",
                    "Orzo",
                    "Panko",
                    "Rye",
                    "Seitan",
                    "Semolina",
                    "Spelt",
                    "Triticale",
                    "Udon"
                ],
                dateCreated: Date()
            ),
            .init(
                title: "Eggs",
                description: "Eggs, eggs, eggs",
                icon: "oval.portrait",
                color: 0xF3FD8F,
                words: [
                    "Egg",
                    "Albumin",
                    "Apovitellin",
                    "Globulin",
                    "Livetin",
                    "Lysozyme",
                    "Ovalbumin",
                    "Ovoglobulin",
                    "Ovomucin",
                    "Ovomucoid",
                    "Ovotransferrin",
                    "Ovovitellin",
                    "Silici albuminate",
                    "Simplesse",
                    "Vitellin"
                ],
                dateCreated: Date()
            ),
            .init(
                title: "Soy",
                description: "Soy products",
                icon: "square.fill",
                color: 0xA20066,
                words: [
                    "Soy",
                    "Edamame",
                    "Miso",
                    "Natto",
                    "Tamari",
                    "Tempeh",
                    "Teriyaki sauce",
                    "TVP",
                    "Tofu",
                    "Soy",
                    "Edamame",
                    "Miso",
                    "Natto",
                    "Tamari",
                    "Tempeh"
                ],
                dateCreated: Date()
            ),
            .init(
                title: "Kosher Restrictions",
                description: "Common Foods",
                icon: "checkmark",
                color: 0x3A7921,
                words: [
                    "Pork",
                    "Rib",
                    "Shrimp",
                    "Lobster",
                    "Crab",
                    "Clam",
                    "Oyster",
                    "Sirloin",
                    "Flank",
                    "Shank"
                ],
                dateCreated: Date()
            ),
            .init(
                title: "Halal Restrictions",
                description: "Common Foods",
                icon: "checkmark",
                color: 0x009A00,
                words: [
                    "Pork",
                    "Rib"
                ],
                dateCreated: Date()
            )
        ]
        
        let startingDate = Date()
        for index in lists.indices {
            let offset = Double(index) /// add 1 second into the future
            let date = startingDate.addingTimeInterval(offset)
            lists[index].dateCreated = date
        }
        
        return lists
    }
}
