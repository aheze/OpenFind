//
//  ToolbarTopCollectionView.swift
//  Find
//
//  Created by Andrew on 1/19/20.
//  Copyright © 2020 Andrew. All rights reserved.
//

import UIKit

extension ViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return testCategoryLabels.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = listsCollectionView.dequeueReusableCell(withReuseIdentifier: "tooltopCell", for: indexPath) as! ToolbarTopCell
        let title = testCategoryLabels[indexPath.row]
        cell.button.setTitle(title, for: .normal)
        cell.backgroundColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        cell.layer.cornerRadius = 6
          
        return cell
    }
    func collectionView(_ collectionView: UICollectionView,
                      layout collectionViewLayout: UICollectionViewLayout,
                      sizeForItemAt indexPath: IndexPath) -> CGSize {
        let cell = listsCollectionView.dequeueReusableCell(withReuseIdentifier: "tooltopCell", for: indexPath) as! ToolbarTopCell
        let itemSize = cell.button.frame.size.width
    return CGSize(width: 120, height: CGFloat(24))
    }
    
    
}

class ToolbarTopCell: UICollectionViewCell {
    
    @IBOutlet weak var button: UIButton!
    
    
}
