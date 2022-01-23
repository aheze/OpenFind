//
//  ListsDetailViewModel.swift
//  Find
//
//  Created by A. Zheng (github.com/aheze) on 1/22/22.
//  Copyright © 2022 A. Zheng. All rights reserved.
//
    

import SwiftUI
import MobileCoreServices

class ListsDetailViewModel: ObservableObject {
    var list: List
    
    var isEditing = false
    var isEditingChanged: (() -> Void)?
    
    @Published var selectedIndices = [Int]()
    
    init(list: List) {
        self.list = list
    }
    
    
}

extension ListsDetailViewModel {
    /// The traditional method for rearranging rows in a table view.
    func moveItem(at sourceIndex: Int, to destinationIndex: Int) {
        guard sourceIndex != destinationIndex else { return }
        
        let word = list.words[sourceIndex]
        list.words.remove(at: sourceIndex)
        list.words.insert(word, at: destinationIndex)
    }
    
    /// The method for adding a new item to the table view's data model.
    func addItem(_ word: String, at index: Int) {
        list.words.insert(word, at: index)
    }
    
    /**
         A helper function that serves as an interface to the data model,
         called by the implementation of the `tableView(_ canHandle:)` method.
    */
    func canHandle(_ session: UIDropSession) -> Bool {
        return session.canLoadObjects(ofClass: NSString.self)
    }
    
    /**
         A helper function that serves as an interface to the data mode, called
         by the `tableView(_:itemsForBeginning:at:)` method.
    */
    func dragItems(for indexPath: IndexPath) -> [UIDragItem] {
        let word = list.words[indexPath.row]

        let data = word.data(using: .utf8)
        let itemProvider = NSItemProvider()
  
        itemProvider.registerDataRepresentation(forTypeIdentifier: kUTTypePlainText as String, visibility: .all) { completion in
            completion(data, nil)
            return nil
        }

        return [
            UIDragItem(itemProvider: itemProvider)
        ]
    }
}
