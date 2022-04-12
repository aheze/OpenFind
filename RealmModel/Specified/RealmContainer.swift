//
//  RealmContainer.swift
//  Find
//
//  Created by A. Zheng (github.com/aheze) on 3/31/22.
//  Copyright © 2022 A. Zheng. All rights reserved.
//

import RealmSwift

class RealmContainer {
    let realm = try! Realm()

    var lists = [List]() {
        didSet {
            listsUpdated?(lists)
        }
    }

    var photoMetadatas = [PhotoMetadata]()
    
    var listsUpdated: (([List]) -> Void)?
}
