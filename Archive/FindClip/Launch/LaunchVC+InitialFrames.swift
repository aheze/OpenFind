//
//  LaunchVC+InitialFrames.swift
//  FindAppClip1
//
//  Created by Zheng on 3/17/21.
//

import UIKit

extension LaunchViewController {
    func setupInitialFrames() {
        let middleOfViewX = view.bounds.width / 2
        let middleOfViewY = view.bounds.height / 2
        
        let halfFramesLength = CGFloat(Constants.framesLength / 2)
        let halfImageLength = CGFloat(Constants.frameImageLength / 2)
        
        let middleColumnOriginX = middleOfViewX - halfImageLength
        let middleRowOriginY = middleOfViewY - halfImageLength
        
        /// top
        let topRect = CGRect(x: middleColumnOriginX, y: middleOfViewY - halfFramesLength, width: Constants.frameImageLength, height: Constants.edgeFrameHeight)
        
        /// right
        let rightRect = CGRect(x: middleOfViewX + halfFramesLength - Constants.edgeFrameHeight, y: middleRowOriginY, width: Constants.edgeFrameHeight, height: Constants.frameImageLength)
        
        /// bottom
        let bottomRect = CGRect(x: middleColumnOriginX, y: middleOfViewY + halfFramesLength - Constants.edgeFrameHeight, width: Constants.frameImageLength, height: Constants.edgeFrameHeight)
        
        /// left
        let leftRect = CGRect(x: middleOfViewX - halfFramesLength, y: middleRowOriginY, width: Constants.edgeFrameHeight, height: Constants.frameImageLength)
        
        topView.frame = topRect
        rightView.frame = rightRect
        bottomView.frame = bottomRect
        leftView.frame = leftRect
        
        topView.layer.cornerRadius = Constants.edgeFrameHeight / 2
        rightView.layer.cornerRadius = Constants.edgeFrameHeight / 2
        bottomView.layer.cornerRadius = Constants.edgeFrameHeight / 2
        leftView.layer.cornerRadius = Constants.edgeFrameHeight / 2

        topView.alpha = 1
        rightView.alpha = 1
        bottomView.alpha = 1
        leftView.alpha = 1
        
        topImageView.alpha = 0
        rightImageView.alpha = 0
        bottomImageView.alpha = 0
        leftImageView.alpha = 0
    }
}
