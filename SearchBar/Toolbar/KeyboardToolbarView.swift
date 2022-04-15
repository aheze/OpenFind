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
    @ObservedObject var realmModel: RealmModel
    @ObservedObject var model: KeyboardToolbarViewModel
    @ObservedObject var collectionViewModel: SearchCollectionViewModel

    var body: some View {
        let displayedLists = getDisplayedLists()
        ScrollView(.horizontal, showsIndicators: false) {
            HStack {
                ForEach(displayedLists) { list in
                    let (selectedList, _) = getSelectedListAndOriginalText()

                    /// make brighter if showing all lists
                    let makeBrighter = getMakeBrighter(list: list, selectedList: selectedList)
                    ListWidgetView(
                        model: model,
                        list: list,
                        selected: selectedList?.id == list.id,
                        makeBrighter: makeBrighter
                    )
                    .transition(.scale)
                }
            }
            .animation(.default, value: searchViewModel.fields)
            .padding(.horizontal, 16)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .background(
            VisualEffectView(.systemChromeMaterial)
                .edgesIgnoringSafeArea(.all)
        )
        .overlay(
            Rectangle()
                .fill(Color(UIColor.secondaryLabel))
                .frame(height: 0.25),
            alignment: .top
        )
    }

    func getMakeBrighter(list: List, selectedList: List?) -> Bool {
        if let selectedList = selectedList, selectedList.id != list.id {
            return false
        } else {
            return true
        }
    }

    func getListIsSelected(list: List) -> Bool {
        let (selectedList, _) = getSelectedListAndOriginalText()
        if selectedList?.id == list.id {
            return true
        } else {
            return false
        }
    }

    func getDisplayedLists() -> [List] {
        let (_, originalText) = getSelectedListAndOriginalText()

        if realmModel.findingFilterLists, !originalText.isEmpty {
            return realmModel.lists.filter { Finding.checkIf(realmModel: realmModel, string: $0.displayedTitle, contains: originalText) }
        } else {
            return realmModel.lists
        }
    }

    func getCurrentFieldValue() -> Field.FieldValue? {
        guard let focusedCellIndex = collectionViewModel.focusedCellIndex else { return nil }
        guard let field = searchViewModel.fields[safe: focusedCellIndex] else { return nil }
        return field.value
    }

    func getSelectedListAndOriginalText() -> (List?, String) {
        guard let value = getCurrentFieldValue() else { return (nil, "") }
        switch value {
        case .word(let word):
            return (nil, word.string)
        case .list(let list, originalText: let originalText):
            return (list, originalText)
        case .addNew:
            return (nil, "")
        }
    }
}

struct ListWidgetView: View {
    @ObservedObject var model: KeyboardToolbarViewModel
    var list: List
    var selected: Bool
    var makeBrighter: Bool

    var body: some View {
        let textColor = getTextColor()

        Button {
            model.listSelected?(list)
        } label: {
            HStack {
                Image(systemName: list.icon)
                Text(list.displayedTitle)
                    .fixedSize(horizontal: true, vertical: false)

                if selected {
                    Image(systemName: "checkmark")
                        .font(.caption)
                        .background(
                            Circle()
                                .fill(textColor.color.opacity(0.25))
                                .aspectRatio(contentMode: .fit)
                                .padding(-6)
                        )
                        .padding(.leading, 4)
                }
            }
            .foregroundColor(
                textColor.color
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
        .brightness(makeBrighter ? 0 : -0.5)
        .opacity(makeBrighter ? 1 : 0.75)
    }

    func getTextColor() -> UIColor {
        let color = UIColor(hex: list.color)
        if color.isLight {
            return .black
        } else {
            return .white
        }
    }
}

struct KeyboardToolbarViewTester: View {
    @StateObject var searchViewModel = SearchViewModel(configuration: .camera)
    @StateObject var realmModel = RealmModel()
    @StateObject var model = KeyboardToolbarViewModel()
    @StateObject var collectionViewModel = SearchCollectionViewModel()
    var body: some View {
        KeyboardToolbarView(
            searchViewModel: searchViewModel,
            realmModel: realmModel,
            model: model,
            collectionViewModel: collectionViewModel
        )
    }
}

struct KeyboardToolbarViewTester_Previews: PreviewProvider {
    static var previews: some View {
        KeyboardToolbarViewTester()
    }
}
