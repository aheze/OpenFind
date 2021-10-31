//
//  TabBarViewController.swift
//  TabBarController
//
//  Created by Zheng on 10/28/21.
//

import UIKit
import SwiftUI

public class TabBarViewController: UIViewController {
    
    /// big area
    @IBOutlet weak var contentView: UIView!
    
    /// for tab bar (SwiftUI)
    @IBOutlet weak var tabBarContainerView: UIView!
    
    @IBOutlet weak var tabBarHeightC: NSLayoutConstraint!
    
    private var tabViewModel: TabViewModel!
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        tabViewModel = TabViewModel()
        
        setupConstraints()
        
        let tabBarHostingController = UIHostingController(rootView: TabBarView(tabViewModel: tabViewModel))
        addChild(tabBarHostingController, in: tabBarContainerView)
    }
    
    func setupConstraints() {
        tabBarHeightC.constant = Constants.tabBarHeight
    }
}
