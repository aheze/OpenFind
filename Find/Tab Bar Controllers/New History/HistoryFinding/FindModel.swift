//
//  FindModel.swift
//  Find
//
//  Created by Zheng on 3/17/20.
//  Copyright © 2020 Andrew. All rights reserved.
//

import UIKit

class FindModel: NSObject {
    var findPhoto = FindPhoto()
    var numberOfMatches = 0
    var descriptionText = ""
    var descriptionHeight = CGFloat(0)
    var descriptionMatchRanges = [ArrayOfMatchesInComp]()
    var components = [Component]()
}

class ArrayOfMatchesInComp: NSObject {
    var descriptionRange = 0...1
    var text = ""
}
