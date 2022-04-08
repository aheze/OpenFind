//
//  SearchVM+Get.swift
//  Find
//
//  Created by A. Zheng (github.com/aheze) on 3/18/22.
//  Copyright © 2022 A. Zheng. All rights reserved.
//
    

import UIKit

extension SearchViewModel {
    
    /// describes the current words
    func getSummaryString() -> String {
        let strings = text.filter { !$0.isEmpty }
        let quotes = strings.map { #""\#($0)""# }
        let summary = quotes.sentence
        return summary
    }
    
    func getBackgroundColor() -> UIColor {
        if !stringToGradients.isEmpty {
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
