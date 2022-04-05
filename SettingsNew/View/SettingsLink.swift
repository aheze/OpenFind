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
    let title: String
    let leftIcon: SettingsRow.Icon?
    let showRightIndicator: Bool
    let destination: SettingsPage
    
    var body: some View {
        SettingsButton {
            model.show?(destination)
        } content: {
            HStack {
                if let leftIcon = leftIcon {
                    switch leftIcon {
                    case .template(iconName: let iconName, backgroundColor: let backgroundColor):
                        Color.clear
                            .frame(width: SettingsConstants.iconSize.width)
                            .overlay(
                                Image(systemName: iconName)
                                    .foregroundColor(.white)
                                    .font(SettingsConstants.iconFont.font)
                                    .frame(width: SettingsConstants.iconSize.width, height: SettingsConstants.iconSize.height)
                                    .background(backgroundColor.color)
                                    .cornerRadius(SettingsConstants.iconCornerRadius)
                            )
                        
                    case .custom(identifier: let identifier):
                        SettingsCustomView(identifier: identifier)
                    }
                }
                
                Text(title)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(SettingsConstants.rowInsets)
        }
    }
}
