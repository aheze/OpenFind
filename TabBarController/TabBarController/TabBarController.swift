//
//  TabBarController.swift
//  TabBarController
//
//  Created by Zheng on 11/10/21.
//

import SwiftUI
import Combine

/// wrapper for `TabBarViewController` - compatible with generics
public class TabBarController<ToolbarView: View>: NSObject, UICollectionViewDelegate, UICollectionViewDataSource {
    
    /// data
    public var pages: [PageViewController]
    public var toolbarView: ToolbarView
    public var viewController: TabBarViewController
    
    /// model
    var tabViewModel: TabViewModel!
    private var cancellable: AnyCancellable?
    
    init(pages: [PageViewController], toolbarView: ToolbarView) {
        self.pages = pages
        self.toolbarView = toolbarView
        
        let bundle = Bundle(identifier: "com.aheze.TabBarController")
        let storyboard = UIStoryboard(name: "Main", bundle: bundle)
        let viewController = storyboard.instantiateViewController(withIdentifier: "TabBarViewController") as! TabBarViewController
        self.viewController = viewController
        viewController.loadViewIfNeeded() /// needed to initialize outlets
        
        super.init()

        
        viewController.getPages = { [weak self] in
            return self?.pages ?? [PageViewController]()
        }
        
        tabViewModel = TabViewModel()
        cancellable = tabViewModel.$tabState.sink { activeTab in
            viewController.updateTabBar(activeTab)
        }
        
        let tabBarView = TabBarView(tabViewModel: tabViewModel, cameraToolbarView: { toolbarView })
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
        
        if distanceFromMiddle < 0 { /// going to Photos
            let percentage = abs(distanceFromMiddle / middle)
            if percentage == 0 { /// still completely at camera, no movement
                tabViewModel.tabState = .camera
            } else if percentage == 1 { /// finished at photos
                tabViewModel.tabState = .photos
            } else { /// use percentage
                tabViewModel.tabState = .cameraToPhotos(percentage)
            }
        } else { /// going to Lists
            let percentage = abs(distanceFromMiddle / middle)
            if percentage == 0 {
                tabViewModel.tabState = .camera
            } else if percentage == 1 {
                tabViewModel.tabState = .lists
            } else {
                tabViewModel.tabState = .cameraToLists(percentage)
            }
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
