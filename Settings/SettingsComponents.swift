//
//  SettingsComponents.swift
//  NewSettings
//
//  Created by Zheng on 1/2/21.
//

import SwiftUI

struct Label: View {
    var text: LocalizedStringKey
    var body: some View {
        Text(text)
            .foregroundColor(.white)
    }
}

struct VerbatimLabel: View {
    var text: String
    var body: some View {
        Text(text)
            .foregroundColor(.white)
            .lineLimit(1)
    }
}

/// Header for each section
struct SectionHeaderView: View {
    var text: LocalizedStringKey
    var body: some View {
        Text(text)
            .foregroundColor(Color.white.opacity(0.75))
            .font(.callout)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.top, 6)
    }
}

struct HeaderView: View {
    var text: LocalizedStringKey
    var body: some View {
        Text(text)
            .header(text)
    }
}

struct HeaderViewWithRightText: View {
    var text: LocalizedStringKey
    var body: some View {
        HStack {
            Text(text)
                .foregroundColor(.white)
                .font(.headline)
            
            Spacer()
            
            Text(":)")
                .foregroundColor(.white)
                .font(.headline)
        }
        .header(text)
    }
}

struct HeaderViewVerbatim: View {
    var text: String
    var body: some View {
        Text(verbatim: text)
            .header(LocalizedStringKey(text))
    }
}

extension String {
    static let customRed = "FF3939"
    static let customOrange = "FF8B00"
    static let customYellow = "FFDC00"
    static let customGreen = "34D425"
    
    static let customBlue = "00AEEF"
    static let customDarkBlue = "005EDC"
    static let customPurple = "6555FF"
    static let customMagenta = "DB55FF"
    
    static let customSalmon = "FF7979"
    static let customYellorange = "FFBF2C"
    static let customLime = "E0FF64"
    static let customNeon = "30FF6F"
    
    static let customLightBlue = "5EB7FF"
    static let customMediumBlue = "2E8DFF"
    static let customLightPurple = "B77AFF"
    static let customPink = "FF779F"
}
