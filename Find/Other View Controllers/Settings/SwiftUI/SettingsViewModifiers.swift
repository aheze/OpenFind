//
//  SettingsViewModifiers.swift
//  Find
//
//  Created by Zheng on 9/27/21.
//  Copyright © 2021 Andrew. All rights reserved.
//

import SwiftUI

extension View {
    func edgePadding(_ verticalPadding: CGFloat = 10) -> some View {
        self.modifier(EdgePadding(verticalPadding: verticalPadding))
    }
    
    func header(_ localizedText: LocalizedStringKey) -> some View {
        self.modifier(HeaderModifiers(localizedText: localizedText))
    }
    
    func bottomRowPadding() -> some View {
        self.modifier(BottomRowPadding())
    }
}
struct EdgePadding: ViewModifier {
    var verticalPadding: CGFloat
    func body(content: Content) -> some View {
        content
            .padding(EdgeInsets(top: verticalPadding, leading: 16, bottom: verticalPadding, trailing: 16))
    }
}

struct HeaderModifiers: ViewModifier {
    var localizedText: LocalizedStringKey
    
    func body(content: Content) -> some View {
        content
            .foregroundColor(.white)
            .font(Font(UIFont.systemFont(ofSize: 19, weight: .medium)))
            .frame(maxWidth: .infinity, alignment: .leading)
            .edgePadding()
            .background(Color.black.opacity(0.75))
            .accessibility(addTraits: .isHeader)
            .accessibility(label: Text(localizedText))
    }
}

struct BottomRowPadding: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding(.bottom, 4)
    }
}
