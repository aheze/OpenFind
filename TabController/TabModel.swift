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

    func boundsChanged(to size: CGSize, safeAreaInset: UIEdgeInsets)
}

/// to move to another tab from anywhere
enum Tab {
    enum Control {
        static var moveToOtherTab: ((TabState, Bool) -> Void)?
    }

    enum Frames {
        static var excluded = [Identifier: CGRect]()
    }
    
    static var blurProgressChanged: ((CGFloat) -> Void)?
}

struct Identifier: Hashable {
    var key: String

    static var cameraSearchBar = Identifier(key: "cameraSearchBar")
    static var listsSearchBar = Identifier(key: "listsSearchBar") /// for both the gallery and individual detail search bar, since they share same navigation controller
}

enum TabState: Equatable {
    case photos
    case camera
    case lists
    case cameraToPhotos(CGFloat) /// associatedValue is the percentage
    case cameraToLists(CGFloat)
}
