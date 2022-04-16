//
//  ListsViewModel.swift
//  Lists
//
//  Created by Zheng on 12/3/21.
//  Copyright © 2021 Andrew. All rights reserved.
//

import UIKit

class ListsViewModel: ObservableObject {
    
    /// if `viewDidLoad` called
    @Published var loaded = false
    
    /// lists shown by the collection view, can be filtered
    @Published private(set) var displayedLists = [DisplayedList]()
    
    @Published var isSelecting = false
    @Published var selectedLists = [List]()
    
    var deleteSelected: (() -> Void)?
    var shareSelected: (() -> Void)?
    
    /// add a new list from anywhere
    var addNewList: (() -> Void)?
    
    /// reload the collection view to make it empty
    var updateSearchCollectionView: (() -> Void)?
    
    func updateDisplayedLists(to displayedLists: [DisplayedList]) {
        self.displayedLists = self.removeDuplicateElements(displayedLists: displayedLists)
    }
    
    func updateDisplayedList(at index: Int, with displayedList: DisplayedList) {
        self.displayedLists[index] = displayedList
    }
    
    func removeDisplayedList(at index: Int) {
        self.displayedLists.remove(at: index)
    }
    
    /// avoid crashes with diffable
    func removeDuplicateElements(displayedLists: [DisplayedList]) -> [DisplayedList] {
        var uniqueDisplayedLists = [DisplayedList]()
        for displayedList in displayedLists {
            if !uniqueDisplayedLists.contains(where: { $0.list.id == displayedList.list.id }) {
                uniqueDisplayedLists.append(displayedList)
            }
        }
        
        return uniqueDisplayedLists
    }
}
