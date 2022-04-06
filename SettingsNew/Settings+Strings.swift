//
//  SettingsVM+Strings.swift
//  Find
//
//  Created by A. Zheng (github.com/aheze) on 4/5/22.
//  Copyright © 2022 A. Zheng. All rights reserved.
//
    

import SwiftUI

extension Settings.StringIdentifier {
    func getString(realmModel: RealmModel) -> String {
        switch self {
        case .asd:
            switch realmModel.hapticFeedbackLevel {
            case .none:
                return "none"
            case .light:
                return "light"
            case .heavy:
                return "heavy"
            }
            
        }
    }
}
