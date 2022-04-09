//
//  TabBarVC+Listen.swift
//  Find
//
//  Created by A. Zheng (github.com/aheze) on 3/12/22.
//  Copyright © 2022 A. Zheng. All rights reserved.
//
    
import UIKit

extension TabBarViewController {
    /// listen to changes in the model
    func listen() {
        
        
        model.updateTabBarHeight = { [weak self] tabState in
            guard let self = self else { return }
            self.updateTabBarHeight(tabState)
        }
        
        model.tabStateChanged = { [weak self] oldTabState, newTabState, animation in
            guard let self = self else { return }
            let activeTab = self.model.tabState
            
            self.updateSafeAreaLayoutGuide(
                bottomHeight: self.model.tabBarAttributes.backgroundHeight,
                safeAreaInsets: self.view.safeAreaInsets
            )
            
            switch animation {
            case .fractionalProgress:
                self.updateTabContent(activeTab, animated: false)
            case .clickedTabIcon:
                TabState.modifyProgress(new: activeTab) /// make sure to modify first, so `willBeginNavigatingTo` will be accurate on swipe
                self.model.willBeginNavigating?(oldTabState, newTabState) /// always call will begin anyway
                self.model.didFinishNavigating?(oldTabState, newTabState) /// scroll view delegates not called, so call manually
                
                UIView.animate(withDuration: 0.3) { self.view.layoutIfNeeded() }
                self.updateTabContent(activeTab, animated: false)
            case .animate:
                UIView.animate(withDuration: 0.3) { self.view.layoutIfNeeded() }
                self.updateTabContent(activeTab, animated: true)
            }
        }
        
        model.barsShownChanged = { [weak self] in
            UIView.animate(withDuration: 0.3) {
                self?.setNeedsStatusBarAppearanceUpdate()
            }
        }
        model.statusBarStyleChanged = { [weak self] in
            UIView.animate(withDuration: 0.3) {
                self?.setNeedsStatusBarAppearanceUpdate()
            }
        }
    }
}
