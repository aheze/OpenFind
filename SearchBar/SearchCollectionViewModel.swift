//
//  SearchCollectionViewModel.swift
//  Find
//
//  Created by A. Zheng (github.com/aheze) on 2/22/22.
//  Copyright © 2022 A. Zheng. All rights reserved.
//
    
import UIKit

/// Model for the collection view
class SearchCollectionViewModel: ObservableObject {
    /// index of focused/expanded cell
    @Published var focusedCellIndex: Int? {
        didSet {
            focusedCellIndexChanged?(oldValue, focusedCellIndex)
        }
    }
    
    var keyboardShown = false
    
    /// prepared before?
    var preparedOnce = false
    
    var currentConvertingAddNewCellToRegularCell = false /// if in progress of converting
    
    /// collection view is about to reach the end (auto-scrolling) or has reached the end
    var reachedEndBeforeAddWordField = false
    
    /// call this from the scroll view delegate when
    /// 1. finger is down
    /// 2. `reachedEnd` is true
    var shouldUseOffsetWithAddNew = false
    
    /// when deleting cells
    var deletedIndex: Int?
    var fallbackIndex: Int?
    
    /// showing (past the point where it will auto-scroll) the last field or not
    var highlightingAddWordField = false
    
    /// old / new
    var focusedCellIndexChanged: ((Int?, Int?) -> Void)?
    
    /// pass back data - highlight (make blue) the add new field
    var highlightAddNewField: ((Bool) -> Void)?
    
    /// fast swipe, instantly convert
    var convertAddNewCellToRegularCell: ((@escaping () -> Void) -> Void)?
    
    /// get the widths of cells
    var getFullCellWidth: ((Int) -> CGFloat)?
}

extension SearchCollectionViewModel {
    func replaceInPlace(with model: SearchCollectionViewModel) {
        focusedCellIndex = model.focusedCellIndex
        keyboardShown = model.keyboardShown
        preparedOnce = model.preparedOnce
        reachedEndBeforeAddWordField = model.reachedEndBeforeAddWordField
        shouldUseOffsetWithAddNew = model.shouldUseOffsetWithAddNew
        deletedIndex = model.deletedIndex
        fallbackIndex = model.fallbackIndex
        highlightingAddWordField = model.highlightingAddWordField
    }
}
