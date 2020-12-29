//
//  Component.swift
//  Find
//
//  Created by Andrew on 10/12/19.
//  Copyright © 2019 Andrew. All rights reserved.
//

import UIKit
import Vision

class Component: NSObject {
    var x: CGFloat = 0
    var y: CGFloat = 0
    var height: CGFloat = 0
    var width: CGFloat = 0
    
    var isSpecialType = "Not Special"
    var text = ""
    var parentList = EditableFindList()
//    var isList = false
    var colors = ["00aeef"]
    var changed: Bool = false
    var baseView: UIView?
}
