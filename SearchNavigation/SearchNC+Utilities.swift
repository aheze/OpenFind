//
//  SearchNC+Utilities.swift
//  Find
//
//  Created by A. Zheng (github.com/aheze) on 1/10/22.
//  Copyright © 2022 A. Zheng. All rights reserved.
//
    

import UIKit

extension UIScrollView {
    
    /// positive content offset, won't be lower than the navigation bar's height
    func getRelativeContentOffset() -> CGFloat {
        let contentOffset: CGFloat
        
        let offset = abs(min(0, self.contentOffset.y))
        let topSafeArea = self.adjustedContentInset.top
        
        print("offset; \(self.contentOffset.y)")
        print("safe; \(topSafeArea)")
        
        /// rubber banding on large title
        if offset > topSafeArea {
            contentOffset = offset
        } else {
            contentOffset = topSafeArea
        }
        
        return contentOffset
    }
}
