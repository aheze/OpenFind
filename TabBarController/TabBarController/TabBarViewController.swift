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
    
    /// data
    var tabs: [TabState] = [.photos, .camera, .lists]
    
    
    /// big area
    @IBOutlet weak var contentView: UIView!
    
    /// for the pages
    @IBOutlet weak var contentCollectionView: UICollectionView!
    lazy var contentPagingLayout: ContentPagingFlowLayout = {
        let flowLayout = ContentPagingFlowLayout()
        flowLayout.scrollDirection = .horizontal
        
        contentCollectionView.setCollectionViewLayout(flowLayout, animated: false)
        
        flowLayout.getTabs = { [weak self] in
            return self?.tabs ?? [TabState]()
        }
        return flowLayout
    }()
    
    /// for tab bar (SwiftUI)
    @IBOutlet weak var tabBarContainerView: UIView!
    @IBOutlet weak var tabBarHeightC: NSLayoutConstraint!
    
    var tabViewModel: TabViewModel!
    private var cancellable: AnyCancellable?
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        tabViewModel = TabViewModel()
        cancellable = tabViewModel.$tabState.sink { [weak self] activeTab in
            self?.updateTabBar(activeTab)
        }
        
        setupConstraints()
        
        let tabBarHostingController = UIHostingController(rootView: TabBarView(tabViewModel: tabViewModel))
        addChild(tabBarHostingController, in: tabBarContainerView)
        tabBarHostingController.view.backgroundColor = .clear
        tabBarContainerView.backgroundColor = .clear
    
        
        setupCollectionView()
    }
    
    func setupConstraints() {
        tabBarHeightC.constant = Constants.tabBarShrunkHeight
    }
    
    private func updateTabBar(_ tabState: TabState) {
//        print("Update to \(tabState)")
        
        DispatchQueue.main.async {
            if tabState == .camera {
                self.tabBarHeightC.constant = 200
            } else {
                self.tabBarHeightC.constant = Constants.tabBarShrunkHeight
            }
        }
        
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
            contentCollectionView.setContentOffset(attributes.frame.origin, animated: false)
        }
        
    }
    
    @IBAction func buttonPressed(_ sender: Any) {
        print("Button Pressed!")
    }
    
    
    func setupCollectionView() {
        _ = contentPagingLayout
        
        contentCollectionView.dataSource = self
        contentCollectionView.delegate = self
        contentCollectionView.decelerationRate = .fast
    }
}

