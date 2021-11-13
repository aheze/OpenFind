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
        
        let bundle = Bundle(identifier: "com.aheze.TabBarController")
        let storyboard = UIStoryboard(name: "Main", bundle: bundle)
        let viewController = storyboard.instantiateViewController(withIdentifier: "TabBarViewController") as! TabBarViewController
        self.viewController = viewController
        viewController.loadViewIfNeeded() /// needed to initialize outlets
        
        super.init()

        // MARK: - setup
        viewController.getPages = { [weak self] in
            return self?.pages ?? [PageViewController]()
        }
        
        tabViewModel = TabViewModel()
        cancellable = tabViewModel.$tabState.sink { activeTab in
            viewController.updateTabBar(activeTab)
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
    
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let middle = viewController.contentCollectionView.bounds.width
        let distanceFromMiddle = scrollView.contentOffset.x - middle
        
        let newTab: TabState
        if distanceFromMiddle < 0 { /// going to Photos
            let percentage = abs(distanceFromMiddle / middle)
            if percentage == 0 { /// still completely at camera, no movement
                newTab = .camera
                delegate?.didFinishNavigatingTo(tab: .camera)
            } else if percentage == 1 { /// finished at photos
                newTab = .photos
                delegate?.didFinishNavigatingTo(tab: .photos)
            } else { /// use percentage
                newTab = .cameraToPhotos(percentage)
            }
        } else { /// going to Lists
            let percentage = abs(distanceFromMiddle / middle)
            if percentage == 0 {
                newTab = .camera
                delegate?.didFinishNavigatingTo(tab: .camera)
            } else if percentage == 1 {
                newTab = .lists
                delegate?.didFinishNavigatingTo(tab: .lists)
            } else {
                newTab = .cameraToLists(percentage)
            }
        }
        
        tabViewModel.tabState = newTab
    }
    
    public func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        switch indexPath.item {
        case 0:
            delegate?.willBeginNavigatingTo(tab: .photos)
        case 1:
            delegate?.willBeginNavigatingTo(tab: .camera)
        case 2:
            delegate?.willBeginNavigatingTo(tab: .lists)
        default:
            break
        }
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
