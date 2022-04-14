//
//  ListsViewModel.swift
//  Lists
//
//  Created by Zheng on 12/3/21.
//  Copyright © 2021 Andrew. All rights reserved.
//

import UIKit

class ListsViewModel: ObservableObject {
    /// lists shown by the collection view, can be filtered
    @Published var displayedLists = [DisplayedList]()
    
    @Published var isSelecting = false
    @Published var selectedLists = [List]()
    
    var deleteSelected: (() -> Void)?
    var shareSelected: (() -> Void)?
    
    /// add a new list from anywhere
    var addNewList: (() -> Void)?
}
