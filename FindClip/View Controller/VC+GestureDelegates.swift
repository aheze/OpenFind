//
//  VC+GestureDelegates.swift
//  FindAppClip1
//
//  Created by Zheng on 3/12/21.
//

import UIKit

extension ViewController: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        
        if GestureState.began {
            return true
        } else {

            let location = touch.location(in: view)
            
            let preventLocation = touch.location(in: cameraViewController.shutter)
            let searchPreventLocation = touch.location(in: cameraViewController.textFieldContainer)
            let fullScreenPreventLocation = touch.location(in: cameraViewController.fullScreenView)
            let flashPreventLocation = touch.location(in: cameraViewController.flashView)
            
            let getButtonLocation = touch.location(in: cameraViewController.getButton)
            let goBackButtonLocation = touch.location(in: cameraViewController.goBackButton)
            let showControlsPreventLocation: CGPoint? = CurrentState.currentlyFullScreen ? touch.location(in: cameraViewController.showControlsView) : nil
            
            if cameraContainerView.transform.ty == 0 {
                let allowFrame = CGRect(x: 0, y: view.bounds.height - 100, width: view.bounds.width, height: 100)
                
                
                /// make long press not interfere with button
                if gestureRecognizer == longPressGestureRecognizer {
                    if cameraViewController.getButton.bounds.contains(getButtonLocation) {
                        return false
                    }
                }
                
                if
                    allowFrame.contains(location),
                    !cameraViewController.shutter.bounds.contains(preventLocation),
                    !cameraViewController.fullScreenView.bounds.contains(fullScreenPreventLocation),
                    !cameraViewController.flashView.bounds.contains(flashPreventLocation),
                    !cameraViewController.textFieldContainer.bounds.contains(searchPreventLocation),
                    showControlsPreventLocation.map({ !cameraViewController.showControlsView.bounds.contains($0) }) ?? true
                {
                    return true
                } else {
                    return false
                }
            } else {
                
                if gestureRecognizer == longPressGestureRecognizer {
                    if cameraViewController.goBackButton.bounds.contains(goBackButtonLocation) {
                        return false
                    }
                }
                
                let location = touch.location(in: view)
                let allowFrame = CGRect(x: 0, y: 0, width: view.bounds.width, height: downloadReferenceView.frame.origin.y + 50)
                
                if allowFrame.contains(location) {
                    return true
                } else {
                    return false
                }
                

            }
        }
    }
    
    /// enable both the long press and pan gesture
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        if otherGestureRecognizer == longPressGestureRecognizer || otherGestureRecognizer == panGestureRecognizer {
            return true
        } else {
            return false
        }
    }
}

