//
//  SettingsVM+Strings.swift
//  Find
//
//  Created by A. Zheng (github.com/aheze) on 4/5/22.
//  Copyright © 2022 A. Zheng. All rights reserved.
//
    

import SwiftUI

extension SettingsViewModel {
    func getString(for identifier: Settings.StringIdentifier) -> String {
        switch identifier {
        case .asd:
            return "asdas"
        }
    }
}
