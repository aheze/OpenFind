//
//  Sentence+Find.swift
//  Find
//
//  Created by A. Zheng (github.com/aheze) on 3/12/22.
//  Copyright © 2022 A. Zheng. All rights reserved.
//

import UIKit

extension Sentence {
    /// get the ranges of search strings in the `string`
    func ranges(of searchStrings: [String], realmModel: RealmModel) -> [RangeResult] {
        var results = [RangeResult]()

        let stringToSearchFrom = self.string.applyDefaults(realmModel: realmModel)
        for searchString in searchStrings {
            let stringToSearch = searchString.applyDefaults(realmModel: realmModel)

            let indices = stringToSearchFrom.indicesOf(string: stringToSearch)
            if indices.isEmpty { continue }
            let ranges = indices.map { $0 ..< $0 + searchString.count }
            let result = RangeResult(string: searchString, ranges: ranges)
            results.append(result)
        }
        return results
    }
}

extension Array where Element == Sentence {
    /// scanned
    func getHighlights(stringToGradients: [String: Gradient], realmModel: RealmModel, imageSize: CGSize) -> [Highlight] {
        var highlights = [Highlight]()
        for sentence in self {
            let search = Swift.Array(stringToGradients.keys)
            let rangeResults = sentence.ranges(of: search, realmModel: realmModel)
            for rangeResult in rangeResults {
                let gradient = stringToGradients[rangeResult.string] ?? Gradient()
                
                for range in rangeResult.ranges {
                    let highlight = Highlight(
                        string: rangeResult.string,
                        colors: gradient.colors,
                        alpha: gradient.alpha,
                        position: sentence.getPosition(for: range, imageSize: imageSize)
                    )
                    highlights.append(highlight)
                }
            }
        }
        return highlights
    }
}

extension Array where Element == FastSentence {
    /// fast live preview
    func getHighlights(stringToGradients: [String: Gradient], realmModel: RealmModel) -> [Highlight] {
        var highlights = [Highlight]()
        for sentence in self {
            let stringToSearchFrom = sentence.string.applyDefaults(realmModel: realmModel)

            for (string, gradient) in stringToGradients {
                let stringToSearch = string.applyDefaults(realmModel: realmModel)

                let indices = stringToSearchFrom.indicesOf(string: stringToSearch)
                for index in indices {
                    let word = sentence.getWord(word: string, at: index)

                    let highlight = Highlight(
                        string: word.string,
                        colors: gradient.colors,
                        alpha: gradient.alpha,
                        position: .init(
                            center: word.frame.center,
                            size: word.frame.size,
                            angle: .zero
                        )
                    )
                    highlights.append(highlight)
                }
            }
        }
        return highlights
    }
}
