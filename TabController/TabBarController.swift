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

enum TabControl {
    static var moveToOtherTab: ((TabState, Bool) -> Void)?
}

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
}

/// wrapper for `TabBarViewController` - compatible with generics
class TabBarController<
    PhotosSelectionToolbarView: View, PhotosDetailToolbarView: View, ListsSelectionToolbarView: View
>: NSObject, UICollectionViewDelegate, UICollectionViewDataSource {
    /// data
    var pages: [PageViewController]
    
    /// toolbars
    var photosSelectionToolbarView: PhotosSelectionToolbarView
    var photosDetailToolbarView: PhotosDetailToolbarView
    var listsSelectionToolbarView: ListsSelectionToolbarView
    
    var viewController: TabBarViewController
    
    /// model
    var tabViewModel = TabViewModel()
    var cameraViewModel: CameraViewModel
    var toolbarViewModel: ToolbarViewModel
    
    /// delegate
    weak var delegate: TabBarControllerDelegate?
    
    init(
        pages: [PageViewController],
        cameraViewModel: CameraViewModel,
        toolbarViewModel: ToolbarViewModel,
        photosSelectionToolbarView: PhotosSelectionToolbarView,
        photosDetailToolbarView: PhotosDetailToolbarView,
        listsSelectionToolbarView: ListsSelectionToolbarView
    ) {
        // MARK: - init first

        self.pages = pages
        self.cameraViewModel = cameraViewModel
        self.toolbarViewModel = toolbarViewModel
        
        self.photosSelectionToolbarView = photosSelectionToolbarView
        self.photosDetailToolbarView = photosDetailToolbarView
        self.listsSelectionToolbarView = listsSelectionToolbarView
        
        let storyboard = UIStoryboard(name: "TabContent", bundle: nil)
        let viewController = storyboard.instantiateViewController(withIdentifier: "TabBarViewController") as! TabBarViewController
        self.viewController = viewController
        viewController.loadViewIfNeeded() /// needed to initialize outlets
        
        super.init()

        // MARK: - setup
        
        /// make the tab bar the height of the camera
        viewController.updateTabBarHeight(.camera)
        viewController.getPages = { [weak self] in
            self?.pages ?? [PageViewController]()
        }
        
        tabViewModel = TabViewModel()
        tabViewModel.updateTabBarHeight = { tabState in
            viewController.updateTabBarHeight(tabState)
        }
        tabViewModel.tabStateChanged = { [weak self] animation in
            guard let self = self else { return }
            let activeTab = self.tabViewModel.tabState
            
            viewController.updateSafeAreaLayoutGuide(bottomHeight: self.tabViewModel.tabBarAttributes.backgroundHeight)
            
            switch animation {
            case .fractionalProgress:
                viewController.updateTabContent(activeTab, animated: false)
            case .clickedTabIcon:
                TabState.modifyProgress(new: activeTab) /// make sure to modify first, so `willBeginNavigatingTo` will be accurate on swipe
                self.delegate?.willBeginNavigatingTo(tab: activeTab) /// always call will begin anyway
                self.delegate?.didFinishNavigatingTo(tab: activeTab)
                
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
                cameraViewModel: cameraViewModel,
                photosSelectionToolbarView: { photosSelectionToolbarView },
                photosDetailToolbarView: { photosDetailToolbarView },
                listsSelectionToolbarView: { listsSelectionToolbarView }
            )
        )
        
        tabBarHostingController.view.backgroundColor = .clear
        viewController.tabBarContainerView.backgroundColor = .clear
        viewController.addChild(tabBarHostingController, in: viewController.tabBarContainerView)
        
        viewController.contentCollectionView.delegate = self
        viewController.contentCollectionView.dataSource = self
        
        TabControl.moveToOtherTab = { [weak self] tabType, animated in
            self?.tabViewModel.changeTabState(newTab: tabType, animation: animated ? .animate : .clickedTabIcon)
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
    
    /// notify delegate and update tab bar height
    func updateTabBarHeightAfterScrolling(_ scrollView: UIScrollView, to tab: TabState) {
        /// only update after **the user** scrolled, since `scrollViewDidScroll` is called even when programmatically setting the content offset
        if scrollView.isTracking || scrollView.isDragging || scrollView.isDecelerating {
            tabViewModel.updateTabBarHeight?(tab)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        let pageViewController = pages[indexPath.item]
        viewController.addChild(pageViewController, in: cell.contentView)
    }

    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        let pageViewController = pages[indexPath.item]
        viewController.removeChild(pageViewController)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return pages.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as? ContentCell else { return UICollectionViewCell() }
        return cell
    }
}
