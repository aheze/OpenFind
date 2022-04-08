//
//  Sentence+Find.swift
//  Find
//
//  Created by A. Zheng (github.com/aheze) on 3/12/22.
//  Copyright © 2022 A. Zheng. All rights reserved.
//

import UIKit

extension Array where Element == Sentence {
    /// scanned
    func getHighlights(stringToGradients: [String: Gradient]) -> [Highlight] {
        var highlights = [Highlight]()
        for sentence in self {
            let search = Swift.Array(stringToGradients.keys)
            let rangeResults = sentence.ranges(of: search)
            for rangeResult in rangeResults {
                let gradient = stringToGradients[rangeResult.string] ?? Gradient()
                for range in rangeResult.ranges {
                    let highlight = Highlight(
                        string: rangeResult.string,
                        colors: gradient.colors,
                        alpha: gradient.alpha,
                        position: sentence.position(for: range)
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
    func getHighlights(stringToGradients: [String: Gradient]) -> [Highlight] {
        var highlights = [Highlight]()
        for sentence in self {
            for (string, gradient) in stringToGradients {
                let indices = sentence.string.lowercased().indicesOf(string: string.lowercased())
                for index in indices {
                    let word = sentence.getWord(word: string, at: index)

                    let highlight = Highlight(
                        string: word.string,
                        colors: gradient.colors,
                        alpha: gradient.alpha,
                        position: .init(
                            originalPoint: .zero,
                            pivotPoint: .zero,
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
