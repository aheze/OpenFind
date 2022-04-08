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
    
    /// big, general area
    @IBOutlet var contentView: UIView!
    
    /// for the pages
    @IBOutlet var contentCollectionView: UICollectionView!
    lazy var contentPagingLayout: ContentPagingFlowLayout = {
        let flowLayout = ContentPagingFlowLayout()
        flowLayout.scrollDirection = .horizontal
        flowLayout.getTabs = { [weak self] in
            guard let self = self else { return [] }
            return self.pages.map { $0.tabType }
        }
        
        contentCollectionView.setCollectionViewLayout(flowLayout, animated: false)
        return flowLayout
    }()
    
    /// get data from `TabBarController`
    var scrollViewDidScroll: ((UIScrollView) -> Void)?
    
    /// for tab bar (SwiftUI)
    @IBOutlet var tabBarContainerView: UIView!
    @IBOutlet var tabBarHeightC: NSLayoutConstraint!

    init?(
        coder: NSCoder,
        pages: [PageViewController],
        model: TabViewModel
    ) {
        self.pages = pages
        self.model = model
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
        contentCollectionView.isScrollEnabled = !Debug.collectionViewScrollDisabled
        
        contentCollectionView.delegate = self
        contentCollectionView.dataSource = self
        
        if let view = view as? TabControllerView {
            view.model = model
            view.tappedExcludedView = { [weak self] in
                self?.contentCollectionView.isScrollEnabled = false
                DispatchQueue.main.async {
                    self?.contentCollectionView.isScrollEnabled = true
                }
            }
        }
        
        updateTraitCollection(to: traitCollection)
        
        /// listen to the model and handle tab changes
        listen()
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
        if collection.horizontalSizeClass == .regular {
            TabState.isLandscape = true
        } else {
            TabState.isLandscape = false
        }
        model.changeTabState(newTab: model.tabState, animation: .animate)
        updateTabBarHeight(model.tabState)
    }

    func updateSafeAreaLayoutGuide(bottomHeight: CGFloat, safeAreaInsets: UIEdgeInsets) {
        for page in pages {
            page.additionalSafeAreaInsets.bottom = bottomHeight - safeAreaInsets.bottom
        }
    }
    
    func updateTabBarHeight(_ tabState: TabState) {
        tabBarHeightC.constant = model.tabBarAttributes.backgroundHeight
    }
    
    /// animated is TODO, since setting `tabState` triggers the `.sink`, which auto calls this function.
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
        
        if let attributes = contentPagingLayout.layoutAttributes[safe: index] {
            /// use `getTargetOffset` as to set flow layout's focused index correctly (for rotation)
            let targetOffset = contentPagingLayout.getTargetOffset(for: CGPoint(x: attributes.fullOrigin, y: 0), velocity: 0)
            contentCollectionView.setContentOffset(targetOffset, animated: animated)
        }
    }
}
