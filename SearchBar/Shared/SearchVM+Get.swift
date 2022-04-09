//
//  SearchVM+Get.swift
//  Find
//
//  Created by A. Zheng (github.com/aheze) on 3/18/22.
//  Copyright © 2022 A. Zheng. All rights reserved.
//
    
import UIKit

extension SearchViewModel {
    /// array of values
    var values: [Field.FieldValue] {
        return fields.dropLast().map { $0.value }
    }
    
    /// array of text
    var text: [String] {
        return values.map { $0.getText().trimmingCharacters(in: .whitespacesAndNewlines) }.filter { !$0.isEmpty }
    }
    
    /// if the search text is empty or not
    var isEmpty: Bool {
        
        /// check if fields contains at least one list or a word
        let containsText = values.contains { value in
            switch value {
            case .word(let word):
                return !word.string.isEmpty
            case .list:
                return true
            case .addNew:
                return false
            }
        }
        return !containsText
    }
    
    /// describes the current words
    func getSummaryString() -> String {
        let strings = text.filter { !$0.isEmpty }
        let quotes = strings.map { #""\#($0)""# }
        let summary = quotes.sentence
        return summary
    }
    
    func getBackgroundColor() -> UIColor {
        if !isEmpty {
            //// active
            return configuration.fieldActiveBackgroundColor
        } else {
            return configuration.fieldBackgroundColor
        }
    }

    func getTotalHeight() -> CGFloat {
        if isLandscape {
            return getCellHeight() + configuration.barTopPaddingLandscape + configuration.barBottomPaddingLandscape
        } else {
            return getCellHeight() + configuration.barTopPadding + configuration.barBottomPadding
        }
    }
    
    func getCellHeight() -> CGFloat {
        if isLandscape {
            return configuration.cellHeightLandscape
        } else {
            return configuration.cellHeight
        }
    }
}
