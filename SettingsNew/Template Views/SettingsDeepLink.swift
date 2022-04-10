//
//  SettingsDeepLink.swift
//  Find
//
//  Created by A. Zheng (github.com/aheze) on 4/6/22.
//  Copyright © 2022 A. Zheng. All rights reserved.
//

import SwiftUI

struct SettingsDeepLink: View {
    @ObservedObject var model: SettingsViewModel
    @ObservedObject var realmModel: RealmModel

    var title: String
    var rows: [SettingsRow]

    var body: some View {
        SettingsRowButton {
            model.showRows?(rows)
        } content: {
            if case .link(
                title: _,
                leftIcon: _,
                indicatorStyle: let indicatorStyle,
                destination: _,
                action: _
            ) = rows.first?.configuration {
                VStack {
                    HStack(spacing: SettingsConstants.rowIconTitleSpacing) {
                        VStack(spacing: 6) {
                            Text(getDestinationTitle())
                                .fixedSize(horizontal: false, vertical: true)
                                .frame(maxWidth: .infinity, alignment: .leading)

                            let titles = getPathTitles()
                            
                            /// empty title
                            HStack(spacing: 2) {
                                ForEach(Array(zip(titles.indices, titles)), id: \.1.self) { index, title in
                                    Text(title)

                                    if index < titles.count - 1 {
                                        Image(systemName: "arrow.right")
                                    }
                                }
                            }
                            .font(.footnote)
                            .foregroundColor(UIColor.secondaryLabel.color)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        
                        if let indicatorStyle = indicatorStyle {
                            switch indicatorStyle {
                            case .forwards:
                                Image(systemName: "chevron.forward")
                                    .foregroundColor(UIColor.secondaryLabel.color)
                            case .modal:
                                Image(systemName: "arrow.up.forward")
                                    .foregroundColor(UIColor.secondaryLabel.color)
                            }
                        }
                    }
                }
                .padding(SettingsConstants.rowVerticalInsetsFromText)
                .padding(SettingsConstants.rowHorizontalInsets)
            }
        }
    }

    func getPathTitles() -> [String] {
        let titles = rows.compactMap { $0.configuration.getTitle() }
        return titles
    }

    func getDestinationTitle() -> String {
        guard let row = rows.last else { return "" }
        let title = row.configuration.getTitle() ?? ""
        return title
    }
}
