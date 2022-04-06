//
//  SettingsLinks.swift
//  Find
//
//  Created by A. Zheng (github.com/aheze) on 4/6/22.
//  Copyright © 2022 A. Zheng. All rights reserved.
//

import SwiftUI

struct SettingsLinks: View {
    @ObservedObject var model: SettingsViewModel
    @ObservedObject var realmModel: RealmModel

    var body: some View {
        HStack {
            SettingsLinksButton(iconName: "link", title: "Link", color: UIColor(hex: 0x0085FF)) {
                SettingsData.shareLink?()
            }
            SettingsLinksButton(iconName: "qrcode", title: "QR Code", color: UIColor(hex: 0x1DCE0)) {
                SettingsData.shareQRCode?()
            }
        }
        .frame(height: 64)
        .padding(SettingsConstants.rowVerticalInsetsFromText)
        .padding(SettingsConstants.rowHorizontalInsets)
    }
}

struct SettingsLinksButton: View {
    var iconName: String
    var title: String
    var color: UIColor
    var action: () -> Void
    var body: some View {
        Button(action: action) {
            LinearGradient(
                colors: [
                    color.color,
                    color.offset(by: 0.05).color
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .overlay(
                HStack {
                    Image(systemName: iconName)
                    Text(title)
                }
                    .font(UIFont.preferredCustomFont(forTextStyle: .title3, weight: .medium).font)
                .foregroundColor(Color.white)
            )
            .cornerRadius(10)
        }
    }
}
