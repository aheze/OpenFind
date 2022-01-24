//
//  ListsDetailViewModel.swift
//  Find
//
//  Created by A. Zheng (github.com/aheze) on 1/22/22.
//  Copyright © 2022 A. Zheng. All rights reserved.
//
    
import MobileCoreServices
import SwiftUI

class ListsDetailViewModel: ObservableObject {
    var list: List
    var editableWords = [EditableWord]()
    
    var isEditing = false
    var isEditingChanged: (() -> Void)?
    
    @Published var selectedIndices = [Int]()
    
    init(list: List) {
        self.list = list
        self.editableWords = list.words.map { EditableWord(string: $0) }
    }
    
    var deleteSelected: (() -> Void)?
}

struct EditableWord {
    let id = UUID()
    var string: String
}

extension ListsDetailViewModel {
    /// The traditional method for rearranging rows in a table view.
    func moveItem(at sourceIndex: Int, to destinationIndex: Int) {
        guard sourceIndex != destinationIndex else { return }
        
        let word = editableWords[sourceIndex]
        editableWords.remove(at: sourceIndex)
        editableWords.insert(word, at: destinationIndex)
    }
    
    /// The method for adding a new item to the table view's data model.
    func addItem(_ string: String, at index: Int) {
        let newWord = EditableWord(string: string)
        editableWords.insert(newWord, at: index)
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
        let word = editableWords[indexPath.row].string

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
