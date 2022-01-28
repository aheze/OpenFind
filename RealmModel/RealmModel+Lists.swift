//
//  RealmModel+Lists.swift
//  Find
//
//  Created by A. Zheng (github.com/aheze) on 1/28/22.
//  Copyright © 2022 A. Zheng. All rights reserved.
//

import RealmSwift

extension RealmModel {
    func loadLists() {
        var lists = [List]()

        /// convert realm lists to normal lists
        let realmLists = realm.objects(RealmList.self)
        for realmList in realmLists {
            let list = List(
                id: realmList.id,
                name: realmList.name,
                desc: realmList.desc,
                icon: realmList.icon,
                color: UInt(realmList.color),
                words: realmList.words.map { $0 },
                dateCreated: realmList.dateCreated
            )
            lists.append(list)
        }
        self.lists = lists
    }
    
    func addList(list: List) {
        let words = RealmSwift.List<String>()
        words.append(objectsIn: list.words)
        let realmList = RealmList(
            id: list.id,
            name: list.name,
            desc: list.desc,
            words: words,
            icon: list.icon,
            color: Int(list.color),
            dateCreated: list.dateCreated
        )
        
//        let realmList = RealmList()
//        realmList.id = list.id
//        realmList.name = list.name
//        realmList.desc = list.desc
//        realmList.words = words
//        realmList.icon = list.icon
//        realmList.color = Int(list.color)
//        realmList.dateCreated = list.dateCreated
        
        do {
            try realm.write {
                realm.add(realmList)
            }
        } catch {
            print("Error writing list: \(error)")
        }
    }
}


