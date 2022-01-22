//
//  ListsDetailViewModel.swift
//  Find
//
//  Created by A. Zheng (github.com/aheze) on 1/21/22.
//  Copyright © 2022 A. Zheng. All rights reserved.
//
    
import SwiftUI

class ListsDetailViewModel: ObservableObject {
    var topContentInset = CGFloat(0)
    
    @Published var list: List
    
    /// the scroll view's offset
    @Published var scrollViewOffset = CGFloat(0)
    var scrolled: (() -> Void)?
    
    init(list: List) {
        self.list = list
    }

    func scrollViewOffsetUpdated(_ scrollViewOffset: CGFloat) {
        self.scrollViewOffset = scrollViewOffset
        scrolled?()
    }
}
