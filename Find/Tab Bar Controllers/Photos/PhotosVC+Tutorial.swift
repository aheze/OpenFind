//
//  PhotosVC+Tutorial.swift
//  Find
//
//  Created by Zheng on 1/26/21.
//  Copyright © 2021 Andrew. All rights reserved.
//

import UIKit

extension PhotosViewController {
    func checkTutorial() {
        let listsViewedBefore = defaults.bool(forKey: "historyViewedBefore")
        
        if listsViewedBefore == false {
            let quickTourView = TutorialHeader()
            quickTourView.colorView.backgroundColor = UIColor(named: "TabIconPhotosMain")
            
            if let navController = navigationController {
                navController.view.insertSubview(quickTourView, belowSubview: navigationController!.navigationBar)
                
                quickTourView.snp.makeConstraints { (make) in
                    make.height.equalTo(50)
                    make.left.equalToSuperview()
                    make.right.equalToSuperview()
                    make.bottom.equalTo(navController.navigationBar.snp.bottom).offset(50)
                }
                
                collectionView.contentInset.top = 50
                collectionView.verticalScrollIndicatorInsets.top = 50
                
                quickTourView.pressed = { [weak self] in
                    
                    let storyboard = UIStoryboard(name: "Main", bundle: nil)
                    let vc = storyboard.instantiateViewController(withIdentifier: "HistoryTutorialViewController") as! HistoryTutorialViewController
                    
                    self?.animateCloseQuickTour(quickTourView: quickTourView)
                    self?.present(vc, animated: true, completion: nil)
                }
                
                quickTourView.closed = { [weak self] in
                    self?.animateCloseQuickTour(quickTourView: quickTourView)
                }
            }
            
        }
    }
    func animateCloseQuickTour(quickTourView: TutorialHeader) {
        defaults.set(true, forKey: "historyViewedBefore")
        
        quickTourView.colorViewHeightConst.constant = 0
        
        UIView.animate(withDuration: 0.5, animations: {
            quickTourView.layoutIfNeeded()
            self.collectionView.contentInset.top = 0
            self.collectionView.verticalScrollIndicatorInsets.top = 0
            quickTourView.startTourButton.alpha = 0
            quickTourView.closeButton.alpha = 0
        }) { _ in
            quickTourView.removeFromSuperview()
        }
    }
}
