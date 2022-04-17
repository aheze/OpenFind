//
//  LaunchVC+Setup.swift
//  Find
//
//  Created by A. Zheng (github.com/aheze) on 4/16/22.
//  Copyright © 2022 A. Zheng. All rights reserved.
//
    
import SwiftUI

extension LaunchViewController {
    func setup() {
        sceneContainer.backgroundColor = .clear
        contentContainer.backgroundColor = .clear
        view.backgroundColor = Colors.accentDarkBackground
        
        setupUI()
        setupScene()
    }
}
