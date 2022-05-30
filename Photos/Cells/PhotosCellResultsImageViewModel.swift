//
//  PhotosCellResultsImageViewModel.swift
//  Find
//
//  Created by A. Zheng (github.com/aheze) on 5/28/22.
//  Copyright © 2022 A. Zheng. All rights reserved.
//
    

import Foundation

class PhotosCellResultsImageViewModel: ObservableObject {
    @Published var findPhoto: FindPhoto?
    @Published var resultsText = ""
    @Published var text = ""
    @Published var resultsFoundInText = false
    @Published var note: String?
    @Published var resultsFoundInNote = false
}
