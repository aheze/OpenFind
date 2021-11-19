//
//  TabBarViewController.swift
//  TabBarController
//
//  Created by Zheng on 10/28/21.
//

import UIKit
import SwiftUI
import Combine

public class TabBarViewController: UIViewController {
    /// big, general area
    @IBOutlet weak var contentView: UIView!
    
    /// for the pages
    @IBOutlet weak var contentCollectionView: UICollectionView!
    lazy var contentPagingLayout: ContentPagingFlowLayout = {
        let flowLayout = ContentPagingFlowLayout()
        flowLayout.scrollDirection = .horizontal
        flowLayout.getTabs = { [weak self] in
            let pages = self?.getPages?() ?? [PageViewController]()
            return pages.map { $0.tabType }
        }
        
        contentCollectionView.setCollectionViewLayout(flowLayout, animated: false)
        return flowLayout
    }()
    
    /// get data from `TabBarController`
    var getPages: (() -> [PageViewController])?
    var scrollViewDidScroll: ((UIScrollView) -> Void)?
    
    
    /// for tab bar (SwiftUI)
    @IBOutlet weak var tabBarContainerView: UIView!
    @IBOutlet weak var tabBarHeightC: NSLayoutConstraint!
    
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        _ = contentPagingLayout
        contentCollectionView.decelerationRate = .fast
        //        tabBarHeightC.constant = Constants.tabBarShrunkHeight
    }
    
    func updateTabBarHeight(_ tabState: TabState) {
        func changeTabHeight(constant: CGFloat) {
            DispatchQueue.main.async {
                self.tabBarHeightC.constant = constant
            }
        }
        
        switch tabState {
        case .photos:
            changeTabHeight(constant: ConstantVars.tabBarTotalHeight)
        case .camera:
            changeTabHeight(constant: ConstantVars.tabBarTotalHeightExpanded)
        case .lists:
            changeTabHeight(constant: ConstantVars.tabBarTotalHeight)
        default:
            changeTabHeight(constant: ConstantVars.tabBarTotalHeightExpanded)
        }
    }
    func updateTabContent(_ tabState: TabState) {
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
            contentCollectionView.setContentOffset(targetOffset, animated: false)
        }
    }
}


