//
//  LaunchVC+GrantedPermissions.swift
//  FindAppClip1
//
//  Created by Zheng on 3/18/21.
//

import UIKit

extension LaunchViewController {
    
    func permissionsToMain() {
        DispatchQueue.main.async {
            self.permissionsViewController.searchBarView.isUserInteractionEnabled = false
            self.permissionsViewController.permissionsBottomView.alpha = 0
            
                self.mainViewController.cameraViewController.configureCamera()
        }
        
    }
    
    func finishPermissionsToMain() {
        let generator = UINotificationFeedbackGenerator()
        generator.prepare()
        generator.notificationOccurred(.success)
        UIView.animate(withDuration: 0.8, delay: 0.8, usingSpringWithDamping: 1, initialSpringVelocity: 0.5, options: .curveLinear) {
            self.permissionsViewController.graphicsReferenceView?.alpha = 0
            self.permissionsViewController.searchBarView?.alpha = 0
            self.permissionsViewController.permissionsView?.transform = CGAffineTransform(
                translationX: 0,
                y: (self.permissionsViewController.permissionsView?.bounds.height ?? 0) + 32
            )
            
            self.mainViewController.cameraViewController.textFieldContainer.alpha = 1
        } completion: { _ in
            self.permissionsReferenceView?.removeFromSuperview()
            self.edgeContainerView.removeFromSuperview()
            self.frameContainerView.removeFromSuperview()
        }
    }
    
}
