//
//  LaunchVC+GoMain.swift
//  FindAppClip1
//
//  Created by Zheng on 3/18/21.
//

import UIKit

extension LaunchViewController {
    func goToMain() {
        
        permissionsReferenceView.removeFromSuperview()
        
        addChildViewController(mainViewController, in: mainReferenceView)
        mainViewController.cameraViewController.textFieldContainer.alpha = 0
        mainViewController.cameraViewController.configureCamera()
        
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 0.5, options: .curveLinear) {
            self.shrinkFrame()
        } completion: { _ in
            let searchRect = self.mainViewController.cameraViewController.textFieldContainer.frame
            
            self.expandFrameConstraints()
            
            UIView.animate(withDuration: 0.8, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 0.5, options: .curveLinear) {
                self.frameContainerView.layoutIfNeeded()
                self.frameContainerView.alpha = 0
                self.resetEdgesIdentity()
                
                
                self.expandHorizontalEdges()
                self.expandBottomEdge()
                
                self.leftView.alpha = 0
                self.rightView.alpha = 0
                self.bottomView.alpha = 0
                
                self.topView.backgroundColor = UIColor(named: "SearchBackground")
                self.topView.alpha = 0.3
                self.topView.frame = searchRect
                self.topView.layer.cornerRadius = self.mainViewController.cameraViewController.textFieldContainer.layer.cornerRadius
                
                self.blueBackgroundView.alpha = 0
                
            } completion: { _ in
                UIView.animate(withDuration: 0.3) {
                    self.topView.alpha = 0
                    self.mainViewController.cameraViewController.textFieldContainer.alpha = 1
                }
            }
        }
       
    }
}
