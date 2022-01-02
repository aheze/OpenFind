//
//  Model.swift
//  Find
//
//  Created by A. Zheng (github.com/aheze) on 1/1/22.
//  Copyright © 2022 A. Zheng. All rights reserved.
//
    

import UIKit

struct Word {
    var string = ""
    var color: UInt = 0x00AEEF
}

struct List {
    var name = ""
    var desc = ""
    var image = ""
    var color: UInt = 0x00AEEF
    var contents = [String]()
    var dateCreated = Date()
}
