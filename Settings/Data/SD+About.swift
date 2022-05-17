//
//  SD+About.swift
//  Find
//
//  Created by A. Zheng (github.com/aheze) on 4/5/22.
//  Copyright © 2022 A. Zheng. All rights reserved.
//

import UIKit

extension SettingsData {
    static var aboutSection: SettingsSection = {
        .init(
            rows: [
                .init(
                    configuration: .link(
                        title: "Credits",
                        leftIcon: .template(
                            iconName: "person.fill",
                            backgroundColor: UIColor(hex: 0x00529D)
                        ),
                        indicatorStyle: .forwards,
                        destination: creditsPage,
                        action: nil
                    )
                ),
                .init(
                    configuration: .link(
                        title: "Licenses",
                        leftIcon: .template(
                            iconName: "book.fill",
                            backgroundColor: UIColor(hex: 0x567E00)
                        ),
                        indicatorStyle: .forwards,
                        destination: licensesPage,
                        action: nil
                    )
                )
            ]
        )
    }()
    
    
    static var creditsPage: SettingsPage = {
        .init(
            title: "Credits",
            explanation: nil,
            configuration: .custom(identifier: .credits),
            bottomViewIdentifier: nil,
            addTopPadding: true
        )
    }()
    
    static var licensesPage: SettingsPage = {
        .init(
            title: "Licenses",
            explanation: "Find is built using several open-source libraries — thank you to the developers!",
            configuration: .custom(identifier: .licenses),
            bottomViewIdentifier: nil,
            addTopPadding: true
        )
    }()
}
