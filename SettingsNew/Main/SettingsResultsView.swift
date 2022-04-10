//
//  SettingsResultsView.swift
//  Find
//
//  Created by A. Zheng (github.com/aheze) on 4/4/22.
//  Copyright © 2022 A. Zheng. All rights reserved.
//

import SwiftUI

struct SettingsResultsSectionHeaderView: View {
    @ObservedObject var model: SettingsViewModel
    @ObservedObject var realmModel: RealmModel
    var section: SettingsSection
    
    var body: some View {
        HStack(spacing: 2) {
            if let icon = section.icon {
                SettingsIconView(model: model, realmModel: realmModel, icon: icon)
                    .scaleEffect(0.6)
            }
            
            if let header = section.header {
                Text(header.uppercased())
                    .settingsSmallTextStyle(addHorizontalPadding: false)
            }
        }
        .padding(.horizontal, SettingsConstants.rowHorizontalInsets.leading) /// extra padding
    }
}
struct SettingsResultsView: View {
    @ObservedObject var model: SettingsViewModel
    @ObservedObject var realmModel: RealmModel
    var sizeChanged: ((CGSize) -> Void)?

    var body: some View {
        VStack(spacing: SettingsConstants.sectionSpacing) {
            ForEach(model.resultsSections) { section in

                /// encompass each section
                VStack(spacing: 0) {
                    VStack {
                        SettingsResultsSectionHeaderView(model: model, realmModel: realmModel, section: section)

                        if let customViewIdentifier = section.customViewIdentifier {
                            SettingsCustomView(model: model, realmModel: realmModel, identifier: customViewIdentifier)
                        }
                    }

                    if !section.rows.isEmpty {
                        SettingsSectionRows(model: model, realmModel: realmModel, section: section)
                    }

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
        .disabled(!model.touchesEnabled) /// stop buttons from sticking down even after scroll
        .padding(SettingsConstants.edgeInsets)
        .readSize {
            self.sizeChanged?($0)
        }
    }
}
