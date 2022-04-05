//
//  SettingsPageView.swift
//  Find
//
//  Created by A. Zheng (github.com/aheze) on 4/4/22.
//  Copyright © 2022 A. Zheng. All rights reserved.
//

import SwiftUI

struct SettingsPageView: View {
    var page: SettingsPage
    var sizeChanged: ((CGSize) -> Void)?
    var body: some View {
//            .fixedSize(horizontal: false, vertical: true)

        VStack {
            if let explanation = page.explanation {
                Text(explanation)
                    .foregroundColor(UIColor.secondaryLabel.color)
                    .padding(.horizontal, SettingsConstants.sidePadding) /// extra padding
            }

            switch page.configuration {
            case .sections(sections: let sections):
                VStack(spacing: SettingsConstants.sectionSpacing) {
                    ForEach(sections) { section in
                        VStack(spacing: 0) {
                            ForEach(section.rows) { row in

                                switch row.configuration {
                                case .link(
                                    title: let title,
                                    leftIcon: let leftIcon,
                                    showRightIndicator: let showRightIndicator,
                                    destination: let destination
                                ):
                                    SettingsLink(title: title, leftIcon: leftIcon, showRightIndicator: showRightIndicator, destination: destination)
                                case .toggle(
                                    title: let title,
                                    storage: let storage
                                ):
                                    EmptyView()
                                case .button(
                                    title: let title,
                                    action: let action
                                ):
                                    EmptyView()
                                case .slider(
                                    title: let title,
                                    numberOfSteps: let numberOfSteps,
                                    minValue: let minValue,
                                    maxValue: let maxValue,
                                    minSymbol: let minSymbol,
                                    maxSymbol: let maxSymbol,
                                    numberOfDecimalPlaces: let numberOfDecimalPlaces,
                                    storageKey: let storageKey
                                ):
                                    EmptyView()
                                case .picker(
                                    choices: let choices,
                                    storage: let storage
                                ):
                                    EmptyView()
                                case .custom(
                                    identifier: let identifier
                                ):
                                    SettingsCustomView(identifier: identifier)
                                }
                            }
                        }
                    }
                }
                .padding()
                .background(UIColor.systemBackground.color)
                .cornerRadius(SettingsConstants.sectionCornerRadius)
            case .custom(identifier: let identifier):
                SettingsCustomView(identifier: identifier)
            }
        }
        .padding(.horizontal, SettingsConstants.sidePadding)
        .readSize {
            self.sizeChanged?($0)
        }
    }
}
