//
//  TabBarViewController.swift
//  TabBarController
//
//  Created by Zheng on 10/28/21.
//

import Combine
import SwiftUI
import UIKit

class TabBarViewController: UIViewController {
    var pages: [PageViewController]
    var model: TabViewModel
    var realmModel: RealmModel
    
    /// big, general area
    @IBOutlet var contentView: UIView!
    
    /// for the pages
    @IBOutlet var contentCollectionView: UICollectionView!
    lazy var contentPagingLayout = makeFlowLayout()
    
    /// get data from `TabBarController`
    var scrollViewDidScroll: ((UIScrollView) -> Void)?
    
    /// for tab bar (SwiftUI)
    @IBOutlet var tabBarContainerView: UIView!
    @IBOutlet var tabBarHeightC: NSLayoutConstraint!

    init?(
        coder: NSCoder,
        pages: [PageViewController],
        model: TabViewModel,
        realmModel: RealmModel
    ) {
        self.pages = pages
        self.model = model
        self.realmModel = realmModel
        super.init(coder: coder)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("You must create this view controller with metadata.")
    }

    override var prefersStatusBarHidden: Bool {
        return !model.barsShown
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return model.statusBarStyle
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        _ = contentPagingLayout
        contentCollectionView.decelerationRate = .fast
        contentCollectionView.showsHorizontalScrollIndicator = false
        contentCollectionView.contentInsetAdjustmentBehavior = .never
        
        contentCollectionView.delegate = self
        contentCollectionView.dataSource = self
        
        if let view = view as? TabControllerView {
            view.model = model
            view.tappedExcludedView = { [weak self] in
                guard let self = self else { return }
                self.contentCollectionView.isScrollEnabled = false
                DispatchQueue.main.async {
                    self.contentCollectionView.isScrollEnabled = self.getScrollViewEnabled()
                }
            }
        }
        
        updateTraitCollection(to: traitCollection)
        
        /// listen to the model and handle tab changes
        listen()
        
        /// set tab bar colors
        switch realmModel.defaultTab {
        case .photos:
            model.changeTabState(newTab: .photos, animation: .fractionalProgress)
            model.statusBarStyle = .default
        case .camera:
            model.changeTabState(newTab: .camera, animation: .fractionalProgress)
            model.statusBarStyle = .lightContent
        case .lists:
            model.changeTabState(newTab: .lists, animation: .fractionalProgress)
            model.statusBarStyle = .default
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateSafeAreaLayoutGuide(
            bottomHeight: model.tabBarAttributes.backgroundHeight,
            safeAreaInsets: Global.safeAreaInsets
        )
    }

    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        coordinator.animate { context in
            let insets = self.view.safeAreaInsets
            
            for page in self.pages {
                page.boundsChanged(to: size, safeAreaInsets: insets)
            }
            
            self.updateSafeAreaLayoutGuide(
                bottomHeight: self.model.tabBarAttributes.backgroundHeight,
                safeAreaInsets: insets
            )
        }
    }
    
    override func willTransition(to newCollection: UITraitCollection, with coordinator: UIViewControllerTransitionCoordinator) {
        super.willTransition(to: newCollection, with: coordinator)
        updateTraitCollection(to: newCollection)
    }
    
    func updateTraitCollection(to collection: UITraitCollection) {
        switch collection.orientation {
        case .phoneLandscape:
            TabState.isLandscape = true
        case .phonePortrait:
            TabState.isLandscape = false
        case .pad:
            TabState.isLandscape = true
        }
        
        model.changeTabState(newTab: model.tabState, animation: .animate)
        updateTabBarHeight(model.tabState)
    }

    func updateSafeAreaLayoutGuide(bottomHeight: CGFloat, safeAreaInsets: UIEdgeInsets) {
        let additionalInset = bottomHeight - safeAreaInsets.bottom
        
        for page in pages {
            page.additionalSafeAreaInsets.bottom = additionalInset
        }
    }
    
    func updateTabBarHeight(_ tabState: TabState) {
        tabBarHeightC.constant = model.tabBarAttributes.backgroundHeight
    }
    
    func updateTabContent(_ tabState: TabState, animated: Bool) {
        let index: Int
        switch tabState {
        case .photos:
            index = 0
        case .camera:
            index = 1
        case .lists:
            index = 2
        default:
            return /// if not a standard tab, that means the user is scrolling. Standard tab set is via SwiftUI
        }
        
        let otherIndices = pages.indices.filter { $0 != index }
        
        for otherIndex in otherIndices {
            let otherView = pages[otherIndex].view
            
            otherView?.accessibilityElementsHidden = true
            otherView?.accessibilityViewIsModal = false
        }
        let activeView = pages[safe: index]?.view
        activeView?.accessibilityViewIsModal = true
        activeView?.accessibilityElementsHidden = false
        
        if let attributes = contentPagingLayout.layoutAttributes[safe: index] {
            /// use `getTargetOffset` as to set flow layout's focused index correctly (for rotation)
            let targetOffset = contentPagingLayout.getTargetOffset(for: CGPoint(x: attributes.fullOrigin, y: 0), velocity: 0)
            contentCollectionView.setContentOffset(targetOffset, animated: animated)
        }
    }
    
    func scrollAtLaunch(to index: Int) {
        DispatchQueue.main.async {
            self.contentCollectionView.layoutIfNeeded()
            self.contentCollectionView.scrollToItem(at: index.indexPath, at: .centeredHorizontally, animated: false)
        }
    }
}

// extension UIView {
//    func enableVoiceOver(_ enable: Bool) {
//        self.isAccessibilityElement = false
//    }
// }
