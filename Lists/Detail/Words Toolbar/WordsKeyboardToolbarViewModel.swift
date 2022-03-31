//
//  WordsKeyboardToolbarViewModel.swift
//  Find
//
//  Created by A. Zheng (github.com/aheze) on 1/27/22.
//  Copyright © 2022 A. Zheng. All rights reserved.
//
    

import SwiftUI

class WordsKeyboardToolbarViewModel: ObservableObject {
    @Published var selectedWordIndex = 0
    @Published var totalWordsCount = 0
    var goToIndex: ((Int) -> Void)?
    var addWordAfterIndex: ((Int) -> Void)?
    
    var keyboardShown = false
}
