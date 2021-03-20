//
//  CameraVC+Views.swift
//  FindAppClip1
//
//  Created by Zheng on 3/18/21.
//

import UIKit

extension CameraViewController {
    func setupViews() {
        
        scrollView.keyboardDismissMode = .interactive
        textFieldContainer.clipsToBounds = true
        textFieldContainer.layer.cornerRadius = 16
        textField.delegate = self
        textField.attributedPlaceholder = NSAttributedString(string: "Type here to find", attributes: [NSAttributedString.Key.foregroundColor : UIColor.white.withAlphaComponent(0.75)])
        textField.tintColor = UIColor(named: "CursorTint")
        
        cameraContentView.mask = cameraMaskView
        cameraMaskView.backgroundColor = UIColor.blue.withAlphaComponent(0.3)
        
        cameraMaskViewMain.backgroundColor = UIColor.blue
        cameraMaskViewMain.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        cameraMaskViewMain.layer.cornerRadius = 16
        
        goBackButton.alpha = 0
        gradientView.alpha = 0
        
        overlayShadowView.alpha = 0
        
        blurView.effect = nil
        
        
        morphingLabel.morphingEffect = .evaporate
    }
}
