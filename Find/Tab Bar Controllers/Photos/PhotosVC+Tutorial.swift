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
        let historyViewedBefore = defaults.bool(forKey: "historyViewedBefore")
        
        if historyViewedBefore == false, quickTourView == nil {
            let quickTourView = TutorialHeader()
            quickTourView.colorView.backgroundColor = UIColor(named: "TabIconPhotosMain")
            self.quickTourView = quickTourView
            
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
                    
                    
                    self?.defaults.set(true, forKey: "historyViewedBefore")
                    self?.animateCloseQuickTour(quickTourView: quickTourView)
                    self?.present(vc, animated: true, completion: nil)
                }
                
                quickTourView.closed = { [weak self] in
                    self?.defaults.set(true, forKey: "historyViewedBefore")
                    self?.animateCloseQuickTour(quickTourView: quickTourView)
                }
            }
            
        }
    }
    func animateCloseQuickTour(quickTourView: TutorialHeader) {
        quickTourView.colorViewHeightConst.constant = 0
        emptyListContainerTopC.constant = 0
        
        UIView.animate(withDuration: 0.5, animations: {
            quickTourView.layoutIfNeeded()
            self.emptyListContainerView.layoutIfNeeded()
            self.collectionView.contentInset.top = 0
            self.collectionView.verticalScrollIndicatorInsets.top = 0
            quickTourView.startTourButton.alpha = 0
            quickTourView.closeButton.alpha = 0
            quickTourView.alpha = 0
        }) { _ in
            quickTourView.removeFromSuperview()
        }
    }
}
