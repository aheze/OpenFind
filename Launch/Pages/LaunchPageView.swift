//
//  LaunchPageView.swift
//  Find
//
//  Created by A. Zheng (github.com/aheze) on 4/16/22.
//  Copyright © 2022 A. Zheng. All rights reserved.
//
    

import SwiftUI

struct LaunchPageView: View {
    @ObservedObject var model: LaunchViewModel
    @ObservedObject var pageViewModel: LaunchPageViewModel
    
    var body: some View {
        Text(verbatim: "HI! \(pageViewModel.identifier)")
    }
}
