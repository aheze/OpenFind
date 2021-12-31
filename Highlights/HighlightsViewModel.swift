//
//  HighlightsViewModel.swift
//  Find
//
//  Created by A. Zheng (github.com/aheze) on 12/30/21.
//  Copyright © 2021 A. Zheng. All rights reserved.
//
    

import SwiftUI

struct Highlight: Identifiable {
    let id = UUID()
    var string = ""
    var frame = CGRect.zero
    var colors = [UIColor]()
}

class HighlightsViewModel: ObservableObject {
    var highlights = [Highlight]()
}
