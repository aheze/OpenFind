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
    
    
    /// about to present details, update the details search collection view to match the latest search view model
    var updateDetailsSearchCollectionView: (() -> Void)?
}
