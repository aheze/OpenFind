//
//  PhotosVC+Migration.swift
//  Find
//
//  Created by Zheng on 1/1/21.
//  Copyright © 2021 Andrew. All rights reserved.
//

import UIKit
import SnapKit

extension PhotosViewController {
    func showMigrationView() {
        
        collectionView.alpha = 0
        
        let migrationView = PhotosMigrationView()
        view.addSubview(migrationView)
        migrationView.snp.makeConstraints { (make) in
            make.edges.equalTo(view.safeAreaLayoutGuide)
        }
    }
    
}
