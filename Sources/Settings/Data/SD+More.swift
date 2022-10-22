//
//  SD+More.swift
//  Find
//
//  Created by A. Zheng (github.com/aheze) on 5/31/22.
//  Copyright © 2022 A. Zheng. All rights reserved.
//

import UIKit

extension SettingsData {
    static var widgetsWarningVisible: Bool {
        if #available(iOS 14, *) {
            return false
        }
        return true
    }
    static var widgetsIconAvailable: Bool {
        if #available(iOS 15, *) {
            return true
        }
        return false
    }
    
    static var moreSection: SettingsSection = {
        .init(
            rows: [
                .init(
                    configuration: .link(
                        title: "Widgets",
                        leftIcon: .template(
                            iconName: widgetsIconAvailable ? "square.text.square" : "square.fill",
                            backgroundColor: UIColor(hex: 0x00C6BF)
                        ),
                        indicatorStyle: .forwards,
                        destination: widgetsPage,
                        action: nil
                    )
                )
            ]
        )
    }()

    static var widgetsPage: SettingsPage = {
        .init(
            title: "Widgets",
            configuration: .sections(
                sections: [
                    .init(
                        rows: [],
                        customViewIdentifier: .widgets,
                        visible: widgetsWarningVisible
                    ),
                    .init(
                        header: "Photo Widget",
                        rows: [],
                        customViewIdentifier: .widgets
                    )
                ]
            )
        )
    }()
}
