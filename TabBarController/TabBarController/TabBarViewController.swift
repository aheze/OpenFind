//
//  TabBarViewController.swift
//  TabBarController
//
//  Created by Zheng on 10/28/21.
//

import UIKit

public class TabBarViewController: UIViewController {
    
    /// big area
    @IBOutlet weak var contentView: UIView!
    
    /// for tab bar
    @IBOutlet weak var tabBarView: TabBarView!
    
    @IBOutlet weak var tabBarHeightC: NSLayoutConstraint!
    
    
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        setupConstraints()
    }
    
    func setupConstraints() {
        tabBarHeightC.constant = Constants.tabBarHeight
    }
}
