//
//  ListsEmptyContentView.swift
//  Find
//
//  Created by A. Zheng (github.com/aheze) on 4/13/22.
//  Copyright © 2022 A. Zheng. All rights reserved.
//
    
import SwiftUI

struct ListsEmptyContentView: View {
    @ObservedObject var model: ListsViewModel
    @ObservedObject var realmModel: RealmModel
    
    var body: some View {
        PermissionsActionView(
            image: "ListsEmpty",
            title: "No Lists",
            description: "Use lists to group words together.",
            actionLabel: "Create a List",
            dark: false
        ) {
            model.addNewList?()
        }
    }
}
