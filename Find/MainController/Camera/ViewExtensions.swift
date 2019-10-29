//
//  ViewExtensions.swift
//  Find
//
//  Created by Andrew on 10/29/19.
//  Copyright © 2019 Andrew. All rights reserved.
//

import UIKit
import ARKit

extension ViewController {
    
    func refreshScreen() {
        var option = RippleEffect.option()
        var xOrig = deviceSize.width / 2
        option.fillColor = #colorLiteral(red: 0, green: 0.6823529412, blue: 0.937254902, alpha: 1)
        option.radius = CGFloat(500)
        option.borderWidth = CGFloat(0)
        option.scale = CGFloat(3.0)
        RippleEffect.run(view, locationInView: CGPoint(x: xOrig, y: 0), option: option)
        
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2, execute: {
            if self.scanModeToggle == .focused {
                self.stopTagFindingInNode = true
                self.focusTimer.suspend()
                self.runImageTrackingSession(with: [], runOptions: [.resetTracking, .removeExistingAnchors])
                self.focusTimer.resume()
                self.stopTagFindingInNode = false
            } else {
                self.stopProcessingImage = true
                self.classicTimer.suspend()
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.4, execute: {self.stopProcessingImage = false})
                let action = SCNAction.fadeOut(duration: 1)
                for h in self.classicHighlightArray {
                    h.runAction(action, completionHandler: {() in
                        h.removeFromParentNode()
                        print("remove")
                    })
                }
                for h in self.secondClassicHighlightArray {
                    h.runAction(action, completionHandler: {
                        () in h.removeFromParentNode()
                        print("remove123")
                    })
                }
                self.classicTimer.resume()
            }
            })
    }
    
}


