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

        do {
            try realm.write {
                realm.add(realmList)
            }
        } catch {
            print("Error writing list: \(error)")
        }
        
        loadLists()
    }

    func updateList(list: List) {
        if let realmList = realm.object(ofType: RealmList.self, forPrimaryKey: list.id) {
            do {
                try realm.write {
                    realmList.name = list.name
                    realmList.desc = list.desc
                    realmList.words.removeAll()
                    realmList.words.append(objectsIn: list.words)
                    realmList.icon = list.icon
                    realmList.color = Int(list.color)
                    realmList.dateCreated = list.dateCreated
                }
            } catch {
                print("Error updating list: \(error)")
            }
        }
        
        loadLists()
    }
    
    func deleteList(list: List) {
        if let realmList = realm.object(ofType: RealmList.self, forPrimaryKey: list.id) {
            do {
                try realm.write {
                    realm.delete(realmList)
                }
            } catch {
                print("Error deleting list: \(error)")
            }
        }
        
        loadLists()
    }
}
