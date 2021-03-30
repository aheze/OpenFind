//
//  CameraVC+Draw.swift
//  Find
//
//  Created by Zheng on 1/25/21.
//  Copyright © 2021 Andrew. All rights reserved.
//

import UIKit

extension CameraViewController {
    func drawHighlights(highlights: [Component], shouldScale: Bool = false) {
        for highlight in highlights {
            scaleInHighlight(component: highlight, shouldScale: false)
        }
    }
}
