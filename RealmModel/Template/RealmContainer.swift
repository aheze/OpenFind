//
//  RealmContainer.swift
//  Find
//
//  Created by A. Zheng (github.com/aheze) on 3/31/22.
//  Copyright © 2022 A. Zheng. All rights reserved.
//

class RealmContainer {
    var lists = List.getSampleLists() {
        didSet {
            listsUpdated?(lists)
        }
    }

    var photoMetadatas = [PhotoMetadata]() {
        didSet {
            photoMetadatasUpdated?(photoMetadatas)
        }
    }

    var listsUpdated: (([List]) -> Void)?
    var photoMetadatasUpdated: (([PhotoMetadata]) -> Void)?
}
