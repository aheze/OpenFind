//
//  KeyboardToolbarView.swift
//  Find
//
//  Created by A. Zheng (github.com/aheze) on 1/27/22.
//  Copyright © 2022 A. Zheng. All rights reserved.
//

import SwiftUI

struct KeyboardToolbarView: View {
    @ObservedObject var searchViewModel: SearchViewModel
    @ObservedObject var model: KeyboardToolbarViewModel
    @ObservedObject var collectionViewModel: SearchCollectionViewModel

    var body: some View {
        if #available(iOS 15.0, *) {
            let _ = Self._printChanges()
        }
        
        ScrollView(.horizontal, showsIndicators: false) {
            HStack {
                ForEach(filteredLists()) { list in
                    ListWidgetView(model: model, list: list)
                }
                .animation(.default, value: searchViewModel.fields)
            }
            .padding(.horizontal, 16)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .background(
            VisualEffectView(effect: UIBlurEffect(style: .systemChromeMaterial))
                .edgesIgnoringSafeArea(.all)
        )
        .overlay(
            Rectangle()
                .fill(Color(UIColor.secondaryLabel))
                .frame(height: 0.25),
            alignment: .top
        )
    }

    func filteredLists() -> [List] {
        if
            let focusedIndex = collectionViewModel.focusedCellIndex,
            let field = searchViewModel.fields[safe: focusedIndex]
        {
            let text = field.value.getText()
            if text.isEmpty {
                return model.displayedLists
            }

            let lists = model.displayedLists.filter { $0.displayedName.contains(text) }
            return lists
        }

        return model.displayedLists
    }
}

struct ListWidgetView: View {
    @ObservedObject var model: KeyboardToolbarViewModel
    var list: List
    var body: some View {
        Button {
            model.listSelected?(list)
        } label: {
            HStack {
                Image(systemName: list.icon)
                Text(list.displayedName)
            }
            .foregroundColor(
                Color(textColor())
            )
            .padding(EdgeInsets(top: 8, leading: 12, bottom: 8, trailing: 12))
            .background(
                Color(
                    UIColor(hex: list.color)
                )
            )
            .cornerRadius(10)
            .contentShape(Rectangle())
        }
    }

    func textColor() -> UIColor {
        let color = UIColor(hex: list.color)
        if color.isLight {
            return .black
        } else {
            return .white
        }
    }
}
