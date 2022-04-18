//
//  LaunchVC+Enter.swift
//  Find
//
//  Created by A. Zheng (github.com/aheze) on 4/17/22.
//  Copyright © 2022 A. Zheng. All rights reserved.
//
    
import RealityKit
import SwiftUI

extension LaunchViewController {
    func enter() {
        camera.look(at: .zero, from: LaunchConstants.cameraPositionBeforeEnter, relativeTo: baseEntity)
        let transform = camera.transform /// get the final transform
        let lookDownRotation = transform.rotation
        camera.look(at: .zero, from: LaunchConstants.cameraPositionFinal, relativeTo: baseEntity)

        camera.move(
            to: transform,
            relativeTo: nil,
            duration: LaunchConstants.enterBeforeDuration,
            timingFunction: .easeInOut
        )
        
        DispatchQueue.main.asyncAfter(deadline: .now() + LaunchConstants.enterBeforeDuration + 0.1) {
            self.camera.look(at: .zero, from: LaunchConstants.cameraPositionAfterEnter, relativeTo: self.baseEntity)
            var transform = self.camera.transform /// get the final transform
            transform.rotation = lookDownRotation
            self.camera.look(at: .zero, from: LaunchConstants.cameraPositionBeforeEnter, relativeTo: self.baseEntity)
            
            self.camera.move(
                to: transform,
                relativeTo: nil,
                duration: LaunchConstants.enterAfterDuration,
                timingFunction: .easeIn
            )
            
            /// make launch view transparent when the camera is right next to the tiles
            DispatchQueue.main.asyncAfter(deadline: .now() + LaunchConstants.enterAfterDuration * 0.77) {
                self.entering()
                UIView.animate(withDuration: 0.15) {
                    self.view.backgroundColor = .clear
                }
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + LaunchConstants.enterAfterDuration + 0.1) {
                /// remove view
                self.done()
            }
        }
        
        withAnimation(
            .spring(
                response: 0.8,
                dampingFraction: 0.6,
                blendDuration: 1
            )
        ) {
            model.showingUI = false
        }
        
        UIView.animate(withDuration: 0.3) {
            self.contentContainer.alpha = 0
        }
    }
}
