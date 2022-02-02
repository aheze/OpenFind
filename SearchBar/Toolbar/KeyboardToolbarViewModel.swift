//
//  KeyboardToolbarViewModel.swift
//  Find
//
//  Created by A. Zheng (github.com/aheze) on 1/27/22.
//  Copyright © 2022 A. Zheng. All rights reserved.
//
    

import SwiftUI

class KeyboardToolbarViewModel: ObservableObject {
//    @Published var realmModel
    var realmModel: RealmModel
    init(realmModel: RealmModel) {
        self.realmModel = realmModel
    }
}
