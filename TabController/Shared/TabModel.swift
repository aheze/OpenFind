//
//  TabModel.swift
//  Find
//
//  Created by A. Zheng (github.com/aheze) on 1/8/22.
//  Copyright © 2022 A. Zheng. All rights reserved.
//

import SwiftUI

protocol PageViewController: UIViewController {
    /// make sure all view controllers have a name
    var tabType: TabState { get set }

    /// kind of like `viewWillAppear`
    func willBecomeActive()

    /// arrived at this tab
    func didBecomeActive()

    /// starting to scroll away
    func willBecomeInactive()

    /// arrived at another tab
    func didBecomeInactive()

    func boundsChanged(to size: CGSize, safeAreaInsets: UIEdgeInsets)
}

/// Global access to tab properties
//enum Tab {
//    enum Control {
//
//        /// 1. the tab, 2. animate or not
//        static var moveToOtherTab: ((TabState, Bool) -> Void)?
//        static var showStatusBar: ((Bool) -> Void)?
//    }
//
//    enum Frames {
//        static var excluded = [Identifier: CGRect]()
//    }
//
//    static var currentTabState = TabState.camera
//    static var currentBlurProgress = CGFloat(0)
//    static var blurProgressChanged: ((CGFloat) -> Void)?
//}

struct Identifier: Hashable {
    var key: String

    static var cameraSearchBar = Identifier(key: "cameraSearchBar")
    static var photosSearchBar = Identifier(key: "photosSearchBar")
    static var photosSlidesItemCollectionView = Identifier(key: "photosSlidesItemCollectionView")
    static var listsSearchBar = Identifier(key: "listsSearchBar") /// for both the gallery and individual detail search bar, since they share same navigation controller
    static var listsDetailsScreenEdge = Identifier(key: "listsDetailsScreenEdge") /// for the navigation controller
}

enum TabState: Equatable {
    case photos
    case camera
    case lists
    case cameraToPhotos(CGFloat) /// associatedValue is the percentage
    case cameraToLists(CGFloat)
}
