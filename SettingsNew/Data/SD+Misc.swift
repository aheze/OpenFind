//
//  SD+Misc.swift
//  Find
//
//  Created by A. Zheng (github.com/aheze) on 4/6/22.
//  Copyright © 2022 A. Zheng. All rights reserved.
//
    

import UIKit

extension SettingsData {
    static var linksSection: SettingsSection = {
        .init(
            header: "Share Find :)",
            rows: [
                .init(
                    configuration: .custom(identifier: .links)
                )
            ]
        )
    }()
    
    static var footerSection: SettingsSection = {
        .init(
            customViewIdentifier: .footer
        )
    }()
}
