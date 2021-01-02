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
    func showMigrationView(photosToMigrate: [URL]) {
        
        collectionView.alpha = 0
        
        let migrationView = PhotosMigrationView()
        view.addSubview(migrationView)
        migrationView.snp.makeConstraints { (make) in
            make.edges.equalTo(view.safeAreaLayoutGuide)
        }
        
        migrationView.movePressed = { [weak self] in
            guard let self = self else { return }
            
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            if let viewController = storyboard.instantiateViewController(withIdentifier: "PhotosMigrationController") as? PhotosMigrationController {
                viewController.photoURLs = photosToMigrate
                self.present(viewController, animated: true)
            }
        }
    }
    
}
  
