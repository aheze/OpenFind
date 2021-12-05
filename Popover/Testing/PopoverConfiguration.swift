//
//  PopoverConfiguration.swift
//  Find
//
//  Created by Zheng on 12/4/21.
//  Copyright © 2021 Andrew. All rights reserved.
//

import SwiftUI


class FieldSettingsModel: PopoverState {
//    @Published var configuration = FieldSettings()
    @Published var header = "WORD"
    @Published var defaultColor: UIColor = UIColor(hex: 0x00aeef)
    @Published var selectedColor: UIColor = UIColor(hex: 0x00aeef)
    @Published var alpha: CGFloat = 1
    
    /// lists
    @Published var words = [String]()
    @Published var showingWords = false
    @Published var editListPressed: (() -> Void)?
}

//struct FieldSettings {
//
//    var header = "WORD"
//    var defaultColor: UIColor = UIColor(hex: 0x00aeef)
//    var selectedColor: UIColor = UIColor(hex: 0x00aeef)
//    var alpha: CGFloat = 1
//
//    /// lists
//    var words = [String]()
//    var showingWords = false
//    var editListPressed: (() -> Void)?
//
//}
struct Tip {
    
    var text = "No Results"
    var pressed: (() -> Void)?
    
}

