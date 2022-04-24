//
//  GeneralExtensions.swift
//  Find
//
//  Created by A. Zheng (github.com/aheze) on 3/12/22.
//  Copyright © 2022 A. Zheng. All rights reserved.
//

import UIKit

/**
 Should be compilable for all targets
 */

// MARK: Finding

struct RangeResult: Hashable {
    var string: String
    var ranges: [Range<Int>]
}

extension String {
    func indicesOf(string: String) -> [Int] {
        var indices = [Int]()
        var searchStartIndex = startIndex

        while
            searchStartIndex < endIndex,
            let range = range(of: string, range: searchStartIndex ..< endIndex),
            !range.isEmpty
        {
            let index = distance(from: startIndex, to: range.lowerBound)
            indices.append(index)
            searchStartIndex = range.upperBound
        }

        return indices
    }
}

enum PhotosSectionCategorization: Equatable, Hashable {
    case date(year: Int, month: Int)

    func getTitle() -> String {
        switch self {
        case .date(let year, let month):
            let dateComponents = DateComponents(year: year, month: month)
            if let date = Calendar.current.date(from: dateComponents) {
                let formatter = DateFormatter()
                if date.isInThisYear {
                    formatter.dateFormat = "MMMM"
                } else {
                    formatter.dateFormat = "MMMM yyyy" /// add year if before
                }
                let string = formatter.string(from: date)
                return string
            }
        }

        return ""
    }
}

