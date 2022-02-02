//
//  ListsDetailsVC+Lifecycle.swift
//  Find
//
//  Created by A. Zheng (github.com/aheze) on 1/22/22.
//  Copyright © 2022 A. Zheng. All rights reserved.
//

import SwiftUI

extension ListsDetailViewController {
    func willBecomeActive() {}

    func didBecomeActive() {
        if model.isEditing {
            withAnimation {
                toolbarViewModel.toolbar = AnyView(toolbarView)
            }
        }
    }

    func willBecomeInactive() {
        withAnimation {
            toolbarViewModel.toolbar = nil
        }
    }

    func didBecomeInactive() {}
}

