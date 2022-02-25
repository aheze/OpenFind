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

    func boundsChanged(to size: CGSize, safeAreaInsets: UIEdgeInsets) {
        baseSearchBarOffset = getCompactBarSafeAreaHeight(with: safeAreaInsets)
        updateSearchBarOffset?()

        updateSwipeBackTouchTarget(viewSize: size)
        print("size: \(size) vs \(view.bounds.size)")
    }

    func updateSwipeBackTouchTarget(viewSize: CGSize) {
        let listsDetailsScreenEdgeRect: CGRect
        
        /// right to left, use opposite swipe
        if UIView.userInterfaceLayoutDirection(for: view.semanticContentAttribute) == .rightToLeft {
            listsDetailsScreenEdgeRect = CGRect(x: viewSize.width - TabConstants.screenEdgeSwipeGestureWidth, y: 0, width: TabConstants.screenEdgeSwipeGestureWidth, height: viewSize.height)

        } else {
            listsDetailsScreenEdgeRect = CGRect(x: 0, y: 0, width: TabConstants.screenEdgeSwipeGestureWidth, height: viewSize.height)
        }

        Tab.Frames.excluded[.listsDetailsScreenEdge] = listsDetailsScreenEdgeRect
    }
}
