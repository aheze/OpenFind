//
//  TabBarController.swift
//  TabBarController
//
//  Created by Zheng on 11/10/21.
//

import SwiftUI
import Combine

public protocol TabBarControllerDelegate: AnyObject {
    func willBeginNavigatingTo(tab: TabState)
    func didFinishNavigatingTo(tab: TabState)
}

public protocol PageViewController: UIViewController {
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
public class TabBarController<
    CameraToolbarView: View, PhotosSelectionToolbarView: View, PhotosDetailToolbarView: View, ListsSelectionToolbarView: View
>: NSObject, UICollectionViewDelegate, UICollectionViewDataSource {
    
    /// data
    public var pages: [PageViewController]
    public var toolbarViewModel: ToolbarViewModel
    public var cameraToolbarView: CameraToolbarView
    public var photosSelectionToolbarView: PhotosSelectionToolbarView
    public var photosDetailToolbarView: PhotosDetailToolbarView
    public var listsSelectionToolbarView: ListsSelectionToolbarView
    
    public var viewController: TabBarViewController
    
    /// model
    var tabViewModel: TabViewModel!
    private var cancellable: AnyCancellable?
    
    /// delegate
    public weak var delegate: TabBarControllerDelegate?
    
    init(
        pages: [PageViewController],
        toolbarViewModel: ToolbarViewModel,
        cameraToolbarView: CameraToolbarView,
        photosSelectionToolbarView: PhotosSelectionToolbarView,
        photosDetailToolbarView: PhotosDetailToolbarView,
        listsSelectionToolbarView: ListsSelectionToolbarView
    ) {
        
        // MARK: - init first
        self.pages = pages
        self.toolbarViewModel = toolbarViewModel
        self.cameraToolbarView = cameraToolbarView
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
            return self?.pages ?? [PageViewController]()
        }
        
        tabViewModel = TabViewModel()
        tabViewModel.updateTabBarHeight = { tabState in
            viewController.updateTabBarHeight(tabState)
        }
        tabViewModel.clickedToNewTab = { [weak self] activeTab in
            TabState.modifyProgress(new: activeTab) /// make sure to modify first, so `willBeginNavigatingTo` will be accurate on swipe
            self?.delegate?.willBeginNavigatingTo(tab: activeTab) /// always call will begin anyway
            self?.delegate?.didFinishNavigatingTo(tab: activeTab)
        }
        cancellable = tabViewModel.$tabState.sink { activeTab in
            viewController.updateTabContent(activeTab)
        }
        
        let tabBarView = TabBarView(
            tabViewModel: tabViewModel,
            toolbarViewModel: toolbarViewModel,
            cameraToolbarView: { cameraToolbarView },
            photosSelectionToolbarView: { photosSelectionToolbarView },
            photosDetailToolbarView: { photosDetailToolbarView },
            listsSelectionToolbarView: { listsSelectionToolbarView }
        )
        
        let tabBarHostingController = UIHostingController(rootView: tabBarView)
        tabBarHostingController.view.backgroundColor = .clear
        viewController.tabBarContainerView.backgroundColor = .clear
        viewController.addChild(tabBarHostingController, in: viewController.tabBarContainerView)
        
        viewController.contentCollectionView.delegate = self
        viewController.contentCollectionView.dataSource = self
    }
    
    /// called **even** when programmatically set the tab via the icon button...
    /// so, need to use `updateTabBarHeightAfterScrolling` to check whether the user was scrolling or not.
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let middle = viewController.contentCollectionView.bounds.width
        let distanceFromMiddle = scrollView.contentOffset.x - middle
        
        let newTab: TabState
        if distanceFromMiddle < 0 { /// going to Photos
            let percentage = abs(distanceFromMiddle / middle)
            if percentage == 0 { /// still completely at camera, no movement
                newTab = .camera
                updateTabBarHeightAfterScrolling(scrollView, to: .camera)
            } else if percentage == 1 { /// finished at photos
                newTab = .photos
                updateTabBarHeightAfterScrolling(scrollView, to: .photos)
            } else { /// use percentage
                newTab = .cameraToPhotos(percentage)
                updateTabBarHeightAfterScrolling(scrollView, to: .camera)
            }
        } else { /// going to Lists
            let percentage = abs(distanceFromMiddle / middle)
            if percentage == 0 {
                newTab = .camera
                updateTabBarHeightAfterScrolling(scrollView, to: .camera)
            } else if percentage == 1 {
                newTab = .lists
                updateTabBarHeightAfterScrolling(scrollView, to: .lists)
            } else {
                newTab = .cameraToLists(percentage)
                updateTabBarHeightAfterScrolling(scrollView, to: .camera)
            }
        }
        
        if let newTab = TabState.notifyBeginChange(current: tabViewModel.tabState, new: newTab) {
            delegate?.willBeginNavigatingTo(tab: newTab)
        }
        tabViewModel.tabState = newTab
    }
    
    /// notify delegate and update tab bar height
    func updateTabBarHeightAfterScrolling(_ scrollView: UIScrollView, to tab: TabState) {
        
        /// only update after **the user** scrolled, since `scrollViewDidScroll` is called even when programmatically setting the content offset
        if (scrollView.isTracking || scrollView.isDragging || scrollView.isDecelerating) {
            tabViewModel.updateTabBarHeight?(tab)
        }
    }
    
    public func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        let pageViewController = pages[indexPath.item]
        viewController.addChild(pageViewController, in: cell.contentView)
    }

    public func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        let pageViewController = pages[indexPath.item]
        viewController.removeChild(pageViewController)
    }
    
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return pages.count
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as? ContentCell else { return UICollectionViewCell() }
        return cell
    }
}
