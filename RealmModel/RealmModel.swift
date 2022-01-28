//
//  RealmModel.swift
//  Find
//
//  Created by A. Zheng (github.com/aheze) on 1/27/22.
//  Copyright © 2022 A. Zheng. All rights reserved.
//
    
import RealmSwift
import SwiftUI

class RealmModel: ObservableObject {
    static let realm = try! Realm()
    
    @Published var lists = [List]()
    
    static func loadLists() {
        let realmLists = realm.objects(RealmList.self)
        for realmList in realmLists {
            let list = List(
                id: realmList.id,
                name: realmList.name,
                desc: realmList.descriptionOfList,
                image: realmList.id,
                color: realmList.id,
                words: realmList.id,
                dateCreated: realmList.id
            )
        }
    }
//    static func
}
