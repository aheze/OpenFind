//
//  KeyboardToolbarViewModel.swift
//  Find
//
//  Created by A. Zheng (github.com/aheze) on 1/27/22.
//  Copyright © 2022 A. Zheng. All rights reserved.
//
    

import SwiftUI

class KeyboardToolbarViewModel: ObservableObject {
    var realmModel: RealmModel
    init(realmModel: RealmModel) {
        self.realmModel = realmModel
        displayedLists = realmModel.lists.sorted(by: { $0.dateCreated > $1.dateCreated })
    }
    
    @Published var displayedLists = [List]()
    func reloadDisplayedLists() {
        displayedLists = realmModel.lists.sorted(by: { $0.dateCreated > $1.dateCreated })
    }
    
    var listSelected: ((List) -> Void)?
}
