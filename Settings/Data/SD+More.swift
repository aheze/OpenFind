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
    
    static var moreSection: SettingsSection = {
        .init(
            rows: [
                .init(
                    configuration: .link(
                        title: "Widgets",
                        leftIcon: .template(
                            iconName: "square.grid.2x2",
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
                        rows: [
                            .init(
                                configuration: .button(title: "Scanning Options", tintColor: nil, rightIconName: nil) {
                                    showScanningOptions?()
                                }
                            )
                        ]
                    ),
                    .init(
                        header: "Gallery Grid Size",
                        rows: [
                            .init(configuration: .custom(title: "Gallery Grid Size", identifier: .photosGridSize))
                        ],
                        description: .constant(string: "Configure the size of the grid in the Photos tab.")
                    )
                ]
            )
        )
    }()
}
