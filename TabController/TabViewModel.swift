//
//  TabViewModel.swift
//  TabBarController
//
//  Created by Zheng on 10/30/21.
//

import SwiftUI

class TabViewModel: ObservableObject {
    @Published var tabState: TabState = .camera {
        didSet {
            tabBarAttributes = tabState.tabBarAttributes()
            photosIconAttributes = tabState.photosIconAttributes()
            cameraIconAttributes = tabState.cameraIconAttributes()
            listsIconAttributes = tabState.listsIconAttributes()
            animatorProgress = tabState.getAnimatorProgress()
            
            Tab.currentTabState = tabState
            Tab.currentBlurProgress = animatorProgress
            Tab.blurProgressChanged?(animatorProgress)
        }
    }

    @Published var tabBarAttributes = TabBarAttributes.darkBackground
    @Published var photosIconAttributes = PhotosIconAttributes.inactiveDarkBackground
    @Published var cameraIconAttributes = CameraIconAttributes.active
    @Published var listsIconAttributes = ListsIconAttributes.inactiveDarkBackground
    @Published var animatorProgress = CGFloat(0) /// for blur
    @Published var tabBarShown = true
    
    var updateTabBarHeight: ((TabState) -> Void)?
    var tabStateChanged: ((TabStateChangeAnimation) -> Void)?
    
    init() {
        NotificationCenter.default.addObserver(forName: UIApplication.keyboardWillShowNotification, object: nil, queue: .main) { [weak self] _ in
            withAnimation {
                self?.tabBarShown = false
            }
        }
        
        NotificationCenter.default.addObserver(forName: UIApplication.keyboardWillHideNotification, object: nil, queue: .main) { [weak self] _ in
            withAnimation {
                self?.tabBarShown = true
            }
        }
    }
    
    /// animated = clicked
    func changeTabState(newTab: TabState, animation: TabStateChangeAnimation = .fractionalProgress) {
        if animation == .clickedTabIcon || animation == .animate {
            withAnimation(.easeOut(duration: 0.3)) {
                tabState = newTab
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                self.updateTabBarHeight?(newTab)
            }
        } else {
            tabState = newTab
        }
        tabStateChanged?(animation)
    }
    
    enum TabStateChangeAnimation {
        /// used when swiping
        case fractionalProgress
        
        /// clicked an icon
        case clickedTabIcon
        
        /// special case, animate transition
        case animate
    }
}
