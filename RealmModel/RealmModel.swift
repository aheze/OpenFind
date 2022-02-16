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
    let realm = try! Realm()

    @Published var lists = [List]()
    @Published var photoMetadatas = [PhotoMetadata]()

    func listsUpdated() {
        NotificationCenter.default.post(name: .listsUpdated, object: nil)
    }
    
    func photoMetadatasUpdated() {
        NotificationCenter.default.post(name: .photoMetadatasUpdated, object: nil)
    }
}

extension Notification.Name {
    static var listsUpdated = Notification.Name("Lists Updated")
    static var photoMetadatasUpdated = Notification.Name("Photo Metadatas Updated")
}
