//
//  SearchCollectionView.swift
//  SearchBar
//
//  Created by Zheng on 10/16/21.
//

import UIKit


class SearchCollectionView: UICollectionView {
//    var showingAddWordField = false
    override func scrollRectToVisible(_ rect: CGRect, animated: Bool) {
//        super.scrollRectToVisible(rect, animated: animated)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        print("TOUCHHHHH")
        super.touchesBegan(touches, with: event)
        
        print("TOUCHHHHHH!")
    }
}
