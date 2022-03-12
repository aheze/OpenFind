//
//  ContentCollectionView.swift
//  Find
//
//  Created by A. Zheng (github.com/aheze) on 12/28/21.
//  Copyright © 2021 A. Zheng. All rights reserved.
//
    
import UIKit

class TabControllerView: UIView {
    var model: TabViewModel?
    var tappedExcludedView: (() -> Void)?
    
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        guard let model = model else {
            print("No model")
            return super.hitTest(point, with: event)
        }
        for excludedFrame in model.excludedFrames.values {
            if excludedFrame.contains(point) {
                tappedExcludedView?()
                break
            }
        }
        
        return super.hitTest(point, with: event)
    }
}
