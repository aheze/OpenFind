//
//  LaunchVC+GoPermissions.swift
//  FindAppClip1
//
//  Created by Zheng on 3/17/21.
//

import UIKit

extension LaunchViewController {
    func goToPermissions() {
        addChildViewController(permissionsViewController, in: permissionsReferenceView)
        permissionsViewController.permissionsView.alpha = 0
        permissionsViewController.permissionsBottomView.alpha = 0
        permissionsViewController.searchBarView.alpha = 0
        
        permissionsViewController.granted = { [weak self] in
            guard let self = self else { return }
            self.permissionsToMain()
        }
        
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 0.5, options: .curveLinear) {
            self.shrinkFrame()
        } completion: { _ in
            let searchRect = self.permissionsViewController.searchBarView.frame
            var permissionsRect = self.permissionsViewController.permissionsView.frame
            permissionsRect.size.height += 32
            
            self.expandFrameConstraints()
            
            UIView.animate(withDuration: 0.8, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 0.5, options: .curveLinear) {
                self.frameContainerView.layoutIfNeeded()
                self.frameContainerView.alpha = 0
                self.resetEdgesIdentity()
                
                self.expandHorizontalEdges()
                self.leftView.alpha = 0
                self.rightView.alpha = 0
                
                self.topView.alpha = 0.3
                self.topView.frame = searchRect
                self.topView.layer.cornerRadius = self.permissionsViewController.searchBarView.layer.cornerRadius
                
                self.bottomView.alpha = 0.3
                self.bottomView.frame = permissionsRect
                self.bottomView.layer.cornerRadius = self.permissionsViewController.permissionsView.layer.cornerRadius
                
                self.blueBackgroundView.alpha = 0
                
            } completion: { _ in
                self.permissionsViewController.permissionsBottomView.alpha = 0
                
                UIView.animate(withDuration: 0.3) {
                    self.topView.alpha = 0
                    self.bottomView.alpha = 0
                    self.permissionsViewController.permissionsView.alpha = 1
                    self.permissionsViewController.searchBarView.alpha = 1
                } completion: { _ in
                    self.permissionsViewController.permissionsBottomView.alpha = 1
                }
            }
        }
    }
}
