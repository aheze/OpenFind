//
//  IconPickerViewModel.swift
//  Find
//
//  Created by A. Zheng (github.com/aheze) on 1/25/22.
//  Copyright © 2022 A. Zheng. All rights reserved.
//
    

import UIKit

class IconPickerViewModel {
    var icons: [[SFFinderConvertible]] = [
        Communication.allCases,
        Weather.allCases,
        ObjectAndTools.allCases,
        Devices.allCases,
        Gaming.allCases,
        Connectivity.allCases,
        Transportation.allCases,
        Human.allCases,
        Nature.allCases,
        Editing.allCases,
        TextFormatting.allCases,
        Media.allCases,
        Keyboard.allCases,
        Commerce.allCases,
        Time.allCases,
        Health.allCases,
        Shapes.allCases,
        Arrows.allCases,
        Math.allCases
    ]
}
