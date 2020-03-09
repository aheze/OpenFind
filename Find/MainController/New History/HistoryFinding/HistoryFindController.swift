//
//  HistoryFindController.swift
//  Find
//
//  Created by Zheng on 3/8/20.
//  Copyright © 2020 Andrew. All rights reserved.
//

import UIKit

class HistoryFindController: UIViewController, UISearchBarDelegate {
    
    
    @IBOutlet weak var helpButton: UIButton!
    
    @IBAction func helpButtonPressed(_ sender: Any) {
    }
    
    @IBOutlet weak var modeToggle: UISegmentedControl!
    
    @IBAction func modeToggleChanged(_ sender: Any) {
    }
    
    
    @IBOutlet weak var searchBar: UISearchBar!
    
    
    @IBOutlet weak var bottom24C: NSLayoutConstraint!
    
    
    @IBOutlet weak var doneButton: UIButton!
    
    @IBAction func doneButtonPressed(_ sender: Any) {
    }
    
    @IBOutlet weak var searchBarRightC: NSLayoutConstraint! ///Default is 56
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        helpButton.layer.cornerRadius = 6
        
        
    }
    
    
}
