//
//  SettingsPageView.swift
//  Find
//
//  Created by A. Zheng (github.com/aheze) on 4/4/22.
//  Copyright © 2022 A. Zheng. All rights reserved.
//

import SwiftUI

struct SettingsPageView: View {
    @ObservedObject var model: SettingsViewModel
    var page: SettingsPage
    var sizeChanged: ((CGSize) -> Void)?
    var body: some View {
        VStack {
            if let explanation = page.explanation {
                Text(explanation)
                    .settingsDescriptionStyle()
            }

            switch page.configuration {
            case .sections(sections: let sections):
                VStack(spacing: SettingsConstants.sectionSpacing) {
                    ForEach(sections) { section in

                        /// encompass each section
                        VStack(spacing: 0) {
                            if let header = section.header {
                                Text(header.uppercased())
                                    .settingsHeaderStyle()
                            }

                            SettingsSectionRows(model: model, section: section)

                            if let description = section.description {
                                Group {
                                    switch description {
                                    case .constant(string: let string):
                                        Text(string)

                                    case .dynamic(getString: let getString):
                                        if let string = getString() {
                                            Text(string)
                                        }
                                    }
                                }
                                .settingsDescriptionStyle()
                            }
                        }
                    }
                }
            case .custom(identifier: let identifier):
                SettingsCustomView(model: model, identifier: identifier)
            }
        }
        .padding(SettingsConstants.edgeInsets)
        .readSize {
            self.sizeChanged?($0)
        }
    }
}
