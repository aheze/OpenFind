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

    static func == (lhs: DisplayedList, rhs: DisplayedList) -> Bool {
        lhs.list.id == rhs.list.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(self.list.id)
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
