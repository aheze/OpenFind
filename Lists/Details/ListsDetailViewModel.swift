//
//  ListsDetailViewModel.swift
//  Find
//
//  Created by A. Zheng (github.com/aheze) on 1/22/22.
//  Copyright © 2022 A. Zheng. All rights reserved.
//
    

import SwiftUI

class ListsDetailViewModel: ObservableObject {
    var list: List
    
    var isEditing = false
    var isEditingChanged: (() -> Void)?
    
    @Published var selectedIndices = [Int]()
    
    init(list: List) {
        self.list = list
    }
}
