//
//  SettingsPageView.swift
//  Find
//
//  Created by A. Zheng (github.com/aheze) on 4/4/22.
//  Copyright © 2022 A. Zheng. All rights reserved.
//

import SwiftUI

struct SettingsPageView: View {
    var model: SettingsViewModel
    var page: SettingsPage
    var sizeChanged: ((CGSize) -> Void)?
    var body: some View {
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

                        /// encompass each section
                        VStack {
                            SettingsSectionRows(model: model, section: section)

                            if let description = section.description {
                                switch description {
                                case .constant(string: let string):
                                    Text(string)
                                        .foregroundColor(UIColor.secondaryLabel.color)
                                        .padding(.horizontal, SettingsConstants.sidePadding) /// extra padding
                                case .dynamic(getString: let getString):
                                    if let string = getString() {
                                        Text(string)
                                            .foregroundColor(UIColor.secondaryLabel.color)
                                            .padding(.horizontal, SettingsConstants.sidePadding) /// extra padding
                                    }
                                }
                            }
                        }
                    }
                }
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
