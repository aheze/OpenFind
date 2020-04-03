//
//  DebugPrint.swift
//  Find
//
//  Created by Zheng on 4/3/20.
//  Copyright © 2020 Andrew. All rights reserved.
//

import Foundation


func print(_ items: Any...) {
    #if DEBUG
        Swift.print(items[0])
    #endif
}
