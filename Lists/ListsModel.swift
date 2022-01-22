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
    var frame = CGRect.zero
    var chipFrames = [ChipFrame]()
    
    struct ChipFrame {
        var frame = CGRect.zero
        var string = ""
        var isWordsLeftButton = false
    }
}
