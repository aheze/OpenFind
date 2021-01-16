//
//  PhotoFindVC+Setup.swift
//  Find
//
//  Created by Zheng on 1/15/21.
//  Copyright © 2021 Andrew. All rights reserved.
//

import UIKit

extension PhotoFindViewController {
    func setup() {
        warningView.alpha = 0
        
        
        findBar.findBarDelegate = self
        tableView.delegate = self
        tableView.dataSource = self
    }
}
