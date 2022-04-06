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
    @ObservedObject var realmModel: RealmModel
    
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
                            VStack {
                                if let header = section.header {
                                    Text(header.uppercased())
                                        .settingsHeaderStyle()
                                }

                                if let customViewIdentifier = section.customViewIdentifier {
                                    SettingsCustomView(model: model, realmModel: realmModel, identifier: customViewIdentifier)
                                }
                            }

                            SettingsSectionRows(model: model, realmModel: realmModel, section: section)

                            if let description = section.description {
                                Group {
                                    switch description {
                                    case .constant(string: let string):
                                        Text(string)

                                    case .dynamic(identifier: let identifier):
                                        Text(identifier.getString(realmModel: realmModel))
                                    }
                                }
                                .settingsDescriptionStyle()
                            }
                        }
                    }
                }
            case .custom(identifier: let identifier):
                SettingsCustomView(
                    model: model,
                    realmModel: realmModel,
                    identifier: identifier
                )
                
            case .picker(title: let title, choices: let choices, storage: let storage):
                SettingsPickerPage(
                    model: model,
                    realmModel: realmModel,
                    title: title,
                    choices: choices,
                    storage: storage
                )
            }
        }
        .padding(SettingsConstants.edgeInsets)
        .padding(.top, page.addTopPadding ? SettingsConstants.additionalTopInset : 0)
        .readSize {
            self.sizeChanged?($0)
        }
    }
}
