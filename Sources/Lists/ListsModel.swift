//
//  ListsModel.swift
//  Find
//
//  Created by A. Zheng (github.com/aheze) on 1/21/22.
//  Copyright © 2022 A. Zheng. All rights reserved.
//

import UIKit

struct DisplayedList: Hashable {
    var list = List()
    var frame = ListFrame()
    var wordsLeft: Int? /// +15 words

    static func == (lhs: DisplayedList, rhs: DisplayedList) -> Bool {
        lhs.list.id == rhs.list.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(list.id)
    }
}

struct ListFrame {
    var chipFrames = [ChipFrame]()

    struct ChipFrame {
        var frame = CGRect.zero
        var string = ""
        var chipType = ChipType.word
    }

    enum ChipType {
        case word
        case wordsLeft
        case addWords
    }
}

extension List {
    func getVoiceoverDescription() -> String {
        var string = displayedTitle
        if !description.isEmpty {
            string += ". \(description)"
        }
        return string
    }
}

extension DisplayedList {
    func getVoiceoverDescription() -> String {
        let listDescription = list.getVoiceoverDescription()

        if list.containsWords {
            let chips = frame.chipFrames.filter { $0.chipType != .wordsLeft }.map { $0.string }
            let sentence = chips.sentence

            var wordsString = ""
            if let wordsLeft = wordsLeft {
                wordsString = "\(sentence) plus \(wordsLeft) more."
            } else {
                wordsString = "\(sentence)."
            }

            return "\(listDescription). Words: \(wordsString)"

        } else {
            return "\(listDescription). No words."
        }
    }
}
