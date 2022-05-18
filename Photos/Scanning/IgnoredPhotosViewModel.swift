//
//  IgnoredPhotosViewModel.swift
//  Find
//
//  Created by A. Zheng (github.com/aheze) on 5/17/22.
//  Copyright © 2022 A. Zheng. All rights reserved.
//
    

import SwiftUI

class IgnoredPhotosViewModel: ObservableObject {
    var ignoredPhotosChanged: (() -> Void)? 
    @Published var ignoredPhotosIsSelecting = false
    @Published var ignoredPhotosSelectedPhotos = [Photo]()
    @Published var ignoredPhotosEditable = false /// select button enabled
}
