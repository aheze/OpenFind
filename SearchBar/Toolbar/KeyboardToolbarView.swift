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
        ScrollView(.horizontal, showsIndicators: false) {
            HStack {
                ForEach(filteredLists()) { list in
                    ListWidgetView(model: model, list: list)
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
        .onValueChange(of: collectionViewModel.focusedCellIndex) { oldValue, newValue in
            updateSelectedList()
        }
    }
    
    func updateSelectedList() {
        guard let focusedCellIndex = collectionViewModel.focusedCellIndex else { return }
        guard let field = searchViewModel.fields[safe: focusedCellIndex] else { return }
//        switch field.value {
            
//        case .word(_):
//            <#code#>
//        case .list(_):
//            <#code#>
//        case .addNew(_):
//            <#code#>
//        }
    }

    func filteredLists() -> [List] {
        if
            let focusedIndex = collectionViewModel.focusedCellIndex,
            let field = searchViewModel.fields[safe: focusedIndex]
        {
            let text = field.value.getText().lowercased()
            if text.isEmpty {
                return realmModel.lists
            }

            let lists = realmModel.lists.filter { Finding.checkIf(realmModel: realmModel, string: $0.displayedTitle, contains: text) }
            return lists
        }

        return realmModel.lists
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
                Text(list.displayedTitle)
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
