//
//  ContentCollectionView.swift
//  Find
//
//  Created by A. Zheng (github.com/aheze) on 12/28/21.
//  Copyright © 2021 A. Zheng. All rights reserved.
//
    
import UIKit

class TabControllerView: UIView {
    var tappedExcludedView: (() -> Void)?
    
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        for excludedFrame in Tab.Frames.excluded.values {
            if excludedFrame.contains(point) {
                tappedExcludedView?()
                break
            }
        }
        
        return super.hitTest(point, with: event)
    }
}
