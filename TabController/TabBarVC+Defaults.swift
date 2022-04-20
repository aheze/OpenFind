//
//  TabBarVC+Defaults.swift
//  Find
//
//  Created by A. Zheng (github.com/aheze) on 4/9/22.
//  Copyright © 2022 A. Zheng. All rights reserved.
//

import UIKit

extension TabBarViewController {
    func listenToDefaults() {
        self.listen(to: RealmModelData.swipeToNavigate.key, selector: #selector(self.swipeToNavigateChanged))
    }

    @objc func swipeToNavigateChanged() {
        self.contentCollectionView.isScrollEnabled = self.getScrollViewEnabled()
    }

    func getScrollViewEnabled() -> Bool {
        if Debug.collectionViewScrollDisabled {
            return false
        }
        if self.realmModel.swipeToNavigate, !UIAccessibility.isVoiceOverRunning {
            return true
        }
        return false
    }
}
