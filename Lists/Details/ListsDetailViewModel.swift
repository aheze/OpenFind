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
    @Published var searchBarOffset = CGFloat(0)
    
    var safeAreaTopInset = CGFloat(0)
    
    init(list: List) {
        self.list = list
    }
    
    var searchBarOffsetChanged: (() -> Void)?
    func getSearchBarOffset() -> CGFloat {
        var searchBarOffset: CGFloat
        
        /// `scrollViewOffset` is 0 when at rest
        let offset = abs(min(0, scrollViewOffset))
        
        /// rubber banding on large title
        if offset > 0 {
            searchBarOffset = offset
        } else {
            searchBarOffset = 0
        }
        
        searchBarOffset += safeAreaTopInset
        return searchBarOffset
    }
    
    func scrollViewOffsetUpdated(_ scrollViewOffset: CGFloat) {
        self.scrollViewOffset = -scrollViewOffset
        searchBarOffset = getSearchBarOffset()
        searchBarOffsetChanged?()
    }
}
