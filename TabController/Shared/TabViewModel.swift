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
            cameraLandscapeIconAttributes = tabState.cameraLandscapeIconAttributes()
            listsIconAttributes = tabState.listsIconAttributes()
            animatorProgress = tabState.getAnimatorProgress()
            
            animatorProgressChanged?(animatorProgress)
        }
    }

    var excludedFrames = [Identifier: CGRect]()
    
    @Published var tabBarAttributes = TabBarAttributes.darkBackground
    @Published var photosIconAttributes = PhotosIconAttributes.inactiveDarkBackground
    @Published var cameraIconAttributes = CameraIconAttributes.active
    @Published var cameraLandscapeIconAttributes = CameraIconAttributes.active
    @Published var listsIconAttributes = ListsIconAttributes.inactiveDarkBackground
    @Published var animatorProgress = CGFloat(0) /// for blur
    
    /// make 0 when the keyboard shows
    @Published var tabBarOpacity = 1
    
    /// hide/show the status bar and tab bar
    @Published var barsShown = true
    var barsShownChanged: (() -> Void)? /// refresh
    
    @Published var statusBarStyle = UIStatusBarStyle.lightContent
    var statusBarStyleChanged: (() -> Void)? /// refresh
    
    /// for `TabBarVC`
    var updateTabBarHeight: ((TabState) -> Void)?
    
    /// 1. current tab
    /// 2. new tab
    /// 3. the animation
    var tabStateChanged: ((TabState, TabState, TabStateChangeAnimation) -> Void)?
    
    /// for the camera view controller
    var animatorProgressChanged: ((CGFloat) -> Void)?
    
    /// for ViewController
    /// 1. old, 2. new
    var willBeginNavigating: ((TabState, TabState) -> Void)?
    var didFinishNavigating: ((TabState, TabState) -> Void)?
    
    init() {
        NotificationCenter.default.addObserver(forName: UIApplication.keyboardWillShowNotification, object: nil, queue: .main) { [weak self] _ in
            withAnimation {
                self?.showBars(false, with: .tabBarOnly)
            }
        }
        
        NotificationCenter.default.addObserver(forName: UIApplication.keyboardWillHideNotification, object: nil, queue: .main) { [weak self] _ in
            withAnimation {
                self?.showBars(true, with: .tabBarOnly)
            }
        }
    }
    
    /// animated = clicked
    func changeTabState(newTab: TabState, animation: TabStateChangeAnimation = .fractionalProgress) {
        let currentTab = tabState
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
        tabStateChanged?(currentTab, newTab, animation)
    }
    
    /// show/hide the status bar and tab bar
    func showBars(_ show: Bool, with scope: TabBarVisibilityScope) {
        withAnimation {
            switch scope {
            case .tabBarOnly: /// due to keyboard
                if show {
                    tabBarOpacity = 1
                } else {
                    tabBarOpacity = 0
                }
            case .tabAndStatusBar:
                barsShown = show
            }
        }
        barsShownChanged?()
    }
    
    enum TabStateChangeAnimation {
        /// used when swiping
        case fractionalProgress
        
        /// clicked an icon
        case clickedTabIcon
        
        /// special case, animate transition
        case animate
    }
    
    enum TabBarVisibilityScope {
        case tabBarOnly
        case tabAndStatusBar
    }
}
