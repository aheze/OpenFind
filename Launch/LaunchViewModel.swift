//
//  LaunchViewModel.swift
//  Find
//
//  Created by A. Zheng (github.com/aheze) on 4/16/22.
//  Copyright © 2022 A. Zheng. All rights reserved.
//
    
import Combine
import SwiftUI

class LaunchViewModel: ObservableObject {
    /// for storing observers to `currentPage`
    var cancellables = Set<AnyCancellable>()
    
    @Published var showingUI = false
    @Published var currentPage = LaunchPage.empty
    @Published var controlsEnabled = true /// set to false after enter first
    
    /// dismiss launch screen and present main app
    var enter: (() -> Void)?

    var tiles = [LaunchTile]()
    var textRows = LaunchConstants.textRows
    
    var width: Int {
        textRows.first?.text.count ?? 0
    }
    
    var height: Int {
        textRows.count
    }
}
