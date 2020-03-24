//
//  FindModel.swift
//  Find
//
//  Created by Zheng on 3/17/20.
//  Copyright © 2020 Andrew. All rights reserved.
//

import UIKit

class FindModel: NSObject {
    var photo = HistoryModel()
    var numberOfMatches = 0
    var descriptionText = ""
    var descriptionMatchRanges = [ClosedRange<Int>]()
    var components = [Component]()
}

class ArrayOfMatchesInComp: NSObject {
    var stringToRanges = [String: [ClosedRange<Int>]]()
}
