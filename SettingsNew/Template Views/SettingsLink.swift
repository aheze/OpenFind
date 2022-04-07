//
//  SettingsLink.swift
//  Find
//
//  Created by A. Zheng (github.com/aheze) on 4/4/22.
//  Copyright © 2022 A. Zheng. All rights reserved.
//
    
import SwiftUI

struct SettingsLink: View {
    @ObservedObject var model: SettingsViewModel
    @ObservedObject var realmModel: RealmModel
    
    var title: String
    var leftIcon: SettingsRow.Icon?
    var indicatorStyle: SettingsRow.IndicatorStyle?
    var destination: SettingsPage?
    var action: (() -> Void)?
    
    var body: some View {
        SettingsRowButton {
            action?()
            if let destination = destination {
                model.show?(destination)
            }
        } content: {
            HStack(spacing: SettingsConstants.rowIconTitleSpacing) {
                if let leftIcon = leftIcon {
                    SettingsIconView(model: model, realmModel: realmModel, icon: leftIcon)
                }
                
                Text(title)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(SettingsConstants.rowVerticalInsetsFromText)
                
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
            .padding(SettingsConstants.rowHorizontalInsets)
        }
    }
}

extension View {
    func settingsRowIconStyle(backgroundColor: UIColor) -> some View {
        self.foregroundColor(.white)
            .font(SettingsConstants.iconFont.font)
            .frame(width: SettingsConstants.iconSize.width, height: SettingsConstants.iconSize.height)
            .background(backgroundColor.color)
            .cornerRadius(SettingsConstants.iconCornerRadius)
    }
}
