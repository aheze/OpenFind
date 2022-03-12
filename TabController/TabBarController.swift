//
//  TabBarController.swift
//  TabBarController
//
//  Created by Zheng on 11/10/21.
//

import Combine
import SwiftUI

protocol TabBarControllerDelegate: AnyObject {
    func willBeginNavigatingTo(tab: TabState)
    func didFinishNavigatingTo(tab: TabState)
}


class TabBarController: NSObject, UICollectionViewDelegate, UICollectionViewDataSource {
    
    /// data
    var pages: [PageViewController]
    
    var viewController: TabBarViewController
    
    /// model
    var tabViewModel: TabViewModel
    var cameraViewModel: CameraViewModel
    var toolbarViewModel: ToolbarViewModel
    
    /// delegate
    weak var delegate: TabBarControllerDelegate?
    
    init(
        pages: [PageViewController],
        cameraViewModel: CameraViewModel,
        toolbarViewModel: ToolbarViewModel
    ) {
        // MARK: - init first

        self.pages = pages
        let tabViewModel = TabViewModel()
        self.tabViewModel = tabViewModel
        self.cameraViewModel = cameraViewModel
        self.toolbarViewModel = toolbarViewModel
        
        let storyboard = UIStoryboard(name: "TabContent", bundle: nil)
        let viewController = storyboard.instantiateViewController(identifier: "TabBarViewController") { coder in
            TabBarViewController(
                coder: coder,
                tabViewModel: tabViewModel
            )
        }
        self.viewController = viewController
        viewController.loadViewIfNeeded() /// needed to initialize outlets
        
        super.init()

        // MARK: - setup
        
        /// make the tab bar the height of the camera
        viewController.updateTabBarHeight(.camera)
        viewController.getPages = { [weak self] in
            self?.pages ?? [PageViewController]()
        }
        
        tabViewModel.updateTabBarHeight = { tabState in
            viewController.updateTabBarHeight(tabState)
        }
        tabViewModel.tabStateChanged = { [weak self] animation in
            guard let self = self else { return }
            let activeTab = self.tabViewModel.tabState
            
            viewController.updateSafeAreaLayoutGuide(
                bottomHeight: self.tabViewModel.tabBarAttributes.backgroundHeight,
                safeAreaInsets: self.viewController.view.safeAreaInsets
            )
            
            switch animation {
            case .fractionalProgress:
                viewController.updateTabContent(activeTab, animated: false)
            case .clickedTabIcon:
                TabState.modifyProgress(new: activeTab) /// make sure to modify first, so `willBeginNavigatingTo` will be accurate on swipe
                self.delegate?.willBeginNavigatingTo(tab: activeTab) /// always call will begin anyway
                self.delegate?.didFinishNavigatingTo(tab: activeTab) /// scroll view delegates not called, so call manually
                
                UIView.animate(withDuration: 0.3) { viewController.view.layoutIfNeeded() }
                viewController.updateTabContent(activeTab, animated: false)
            case .animate:
                UIView.animate(withDuration: 0.3) { viewController.view.layoutIfNeeded() }
                viewController.updateTabContent(activeTab, animated: true)
            }
        }
        
        let tabBarHostingController = UIHostingController(
            rootView: TabBarView(
                tabViewModel: tabViewModel,
                toolbarViewModel: toolbarViewModel,
                cameraViewModel: cameraViewModel
            )
        )
        
        tabBarHostingController.view.backgroundColor = .clear
        viewController.tabBarContainerView.backgroundColor = .clear
        viewController.addChildViewController(tabBarHostingController, in: viewController.tabBarContainerView)
        
        viewController.contentCollectionView.delegate = self
        viewController.contentCollectionView.dataSource = self
        
        Tab.Control.moveToOtherTab = { [weak self] tabType, animated in
            self?.tabViewModel.changeTabState(newTab: tabType, animation: animated ? .animate : .clickedTabIcon)
        }
        
        Tab.Control.showStatusBar = { [weak self] show in
            viewController.statusBarHidden = !show
        }
    }
    
    /// called **even** when programmatically set the tab via the icon button...
    /// so, need to use `updateTabBarHeightAfterScrolling` to check whether the user was scrolling or not.
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        /// only update after **the user** scrolled, since `scrollViewDidScroll` is called even when programmatically setting the content offset
        if scrollView.isTracking || scrollView.isDragging || scrollView.isDecelerating {
            let middle = viewController.contentCollectionView.bounds.width
            let distanceFromMiddle = scrollView.contentOffset.x - middle
            
            let newTab: TabState
            if distanceFromMiddle < 0 { /// going to Photos
                let percentage = abs(distanceFromMiddle / middle)
                if percentage == 0 { /// still completely at camera, no movement
                    newTab = .camera
                    tabViewModel.updateTabBarHeight?(.camera)
                } else if percentage == 1 { /// finished at photos
                    newTab = .photos
                    tabViewModel.updateTabBarHeight?(.photos)
                } else { /// use percentage
                    newTab = .cameraToPhotos(percentage)
                    tabViewModel.updateTabBarHeight?(.camera)
                }
            } else { /// going to Lists
                let percentage = abs(distanceFromMiddle / middle)
                if percentage == 0 {
                    newTab = .camera
                    tabViewModel.updateTabBarHeight?(.camera)
                } else if percentage == 1 {
                    newTab = .lists
                    tabViewModel.updateTabBarHeight?(.lists)
                } else {
                    newTab = .cameraToLists(percentage)
                    tabViewModel.updateTabBarHeight?(.camera)
                }
            }
            
            if let newTab = TabState.notifyBeginChange(current: tabViewModel.tabState, new: newTab) {
                delegate?.willBeginNavigatingTo(tab: newTab)
            }
            tabViewModel.changeTabState(newTab: newTab)
        }
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        notifyIfScrolledToStop()
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        notifyIfScrolledToStop()
    }
    
    /// stopped scrolling, call delegates
    func notifyIfScrolledToStop() {
        switch tabViewModel.tabState {
        case .photos, .camera, .lists:
            self.delegate?.didFinishNavigatingTo(tab: tabViewModel.tabState)
        default: break
        }
    }
    
    /// notify delegate and update tab bar height
    func updateTabBarHeightAfterScrolling(_ scrollView: UIScrollView, to tab: TabState) {
        /// only update after **the user** scrolled, since `scrollViewDidScroll` is called even when programmatically setting the content offset
        if scrollView.isTracking || scrollView.isDragging || scrollView.isDecelerating {
            tabViewModel.updateTabBarHeight?(tab)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        let pageViewController = pages[indexPath.item]
        viewController.addChildViewController(pageViewController, in: cell.contentView)
    }

    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        let pageViewController = pages[indexPath.item]
        viewController.removeChildViewController(pageViewController)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return pages.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as? ContentCell else { return UICollectionViewCell() }
        return cell
    }
}
