//
//  ListsModel.swift
//  Find
//
//  Created by A. Zheng (github.com/aheze) on 1/21/22.
//  Copyright © 2022 A. Zheng. All rights reserved.
//

import UIKit

struct DisplayedList {
    var list = List()
    var frame = ListFrame()
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
