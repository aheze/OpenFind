//
//  ListsVC+Selection.swift
//  Find
//
//  Created by A. Zheng (github.com/aheze) on 1/29/22.
//  Copyright © 2022 A. Zheng. All rights reserved.
//
    

import SwiftUI

extension ListsViewController {
    func toggleSelect() {
        self.listsViewModel.isSelecting.toggle()
        
        if self.listsViewModel.isSelecting {
            selectBarButton.title = "Done"
            toolbarViewModel.toolbar = AnyView(self.toolbarView)
        } else {
            selectBarButton.title = "Select"
            toolbarViewModel.toolbar = nil
            listsViewModel.selectedLists = []
        }
    }
}
