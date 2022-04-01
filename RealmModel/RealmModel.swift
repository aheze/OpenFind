//
//  RealmModel.swift
//  Find
//
//  Created by A. Zheng (github.com/aheze) on 1/27/22.
//  Copyright © 2022 A. Zheng. All rights reserved.
//

import SwiftUI

class RealmModel: ObservableObject {
    var container = RealmContainer()

    @Published var lists = [List]()
    @Published var photoMetadatas = [PhotoMetadata]()

    init() {
        container.listsUpdated = { [weak self] lists in
            self?.lists = lists
        }
        container.photoMetadatasUpdated = { [weak self] photoMetadatas in
            self?.photoMetadatas = photoMetadatas
        }

        container.loadLists()
        container.loadPhotoMetadatas()
    }
}
