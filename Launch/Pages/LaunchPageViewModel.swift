//
//  LaunchPageViewModel.swift
//  Find
//
//  Created by A. Zheng (github.com/aheze) on 4/16/22.
//  Copyright © 2022 A. Zheng. All rights reserved.
//
    

import SwiftUI

class LaunchPageViewModel: ObservableObject {
    @Published var identifier: LaunchPage
    
    init(identifier: LaunchPage) {
        self.identifier = identifier
    }
}
