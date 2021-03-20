//
//  LaunchVC+FramesExpand.swift
//  FindAppClip1
//
//  Created by Zheng on 3/17/21.
//

import UIKit

extension LaunchViewController {
    func shrinkFrame() {
        frameContainerView.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
        edgeContainerView.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
    }
    func expandFrameConstraints() {
        frameWidthC.constant = view.bounds.width
        frameHeightC.constant = view.bounds.height
    }
    func resetEdgesIdentity() {
        edgeContainerView.transform = CGAffineTransform.identity
    }
    func expandHorizontalEdges() {
        leftView.frame.origin.x = -leftView.bounds.width
        rightView.frame.origin.x = view.bounds.width + rightView.bounds.width
    }
    func expandBottomEdge() {
        bottomView.frame.origin.y = view.bounds.height
    }
}
