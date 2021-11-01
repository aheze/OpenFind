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
    
    /// big area
    @IBOutlet weak var contentView: UIView!
    
    /// for tab bar (SwiftUI)
    @IBOutlet weak var tabBarContainerView: UIView!
    
    @IBOutlet weak var tabBarHeightC: NSLayoutConstraint!
    
    private var tabViewModel: TabViewModel!
    private var cancellable: AnyCancellable?
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        tabViewModel = TabViewModel()
        cancellable = tabViewModel.$activeTab.sink { [weak self] activeTab in
            self?.updateTabBar(activeTab)
        }
        
        setupConstraints()
        
        let tabBarHostingController = UIHostingController(rootView: TabBarView(tabViewModel: tabViewModel))
        addChild(tabBarHostingController, in: tabBarContainerView)
        tabBarHostingController.view.backgroundColor = .clear
        tabBarContainerView.backgroundColor = .clear
        

//        tabBarContainerView.clipsToBounds = true
    }
    
    func setupConstraints() {
        tabBarHeightC.constant = Constants.tabBarShrunkHeight
    }
    
    private func updateTabBar(_ activeTab: TabType) {
        print("Update to \(activeTab)")
        
        DispatchQueue.main.async {
            
            if activeTab == .camera {
                self.tabBarHeightC.constant = 200
            } else {
                self.tabBarHeightC.constant = Constants.tabBarShrunkHeight
            }
        }
    }
    
    @IBAction func buttonPressed(_ sender: Any) {
        print("Button Pressed!")
    }
}

