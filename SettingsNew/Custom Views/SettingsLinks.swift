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
    @State var showingQRCode = false

    var body: some View {
        HStack {
            SettingsLinksButton(iconName: "link", title: "Link", color: UIColor(hex: 0x0085FF)) {
                SettingsData.shareLink?()
            }
            SettingsLinksButton(iconName: "qrcode", title: "QR Code", color: UIColor(hex: 0x1DCE0)) {
                showingQRCode = true
            }
        }
        .frame(height: 64)
        .padding(SettingsConstants.rowVerticalInsetsFromText)
        .padding(SettingsConstants.rowHorizontalInsets)
        .sheet(isPresented: $showingQRCode) {
            SettingsQRCodeView(isPresented: $showingQRCode)
        }
    }
}

struct SettingsQRCodeView: View {
    @Binding var isPresented: Bool
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("Scan to download Find")
                    .foregroundColor(UIColor.secondaryLabel.color)
                    .font(UIFont.preferredFont(forTextStyle: .title1).font)
                
                Image("AppQRCode")
                    .resizable()
                    .aspectRatio(contentMode: .fit)

                Button {
                    if let url = URL(string: "https://getfind.app/") {
                        UIApplication.shared.open(url)
                    }
                } label: {
                    Text("getfind.app")
                        .foregroundColor(UIColor.secondaryLabel.color)
                        .font(UIFont.preferredFont(forTextStyle: .title1).font)
                }
                
                Spacer()
            }
            .foregroundColor(UIColor.label.color)
            .padding(.horizontal, 32)
            .padding(.top, 64)
            .navigationBarItems(trailing:
                Button {
                    isPresented = false
                } label: {
                    Image("Dismiss")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 28, height: 28)
                }
                .frame(maxWidth: .infinity, alignment: .trailing)
            )
            .navigationBarTitle("QR Code", displayMode: .inline)
        }
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
