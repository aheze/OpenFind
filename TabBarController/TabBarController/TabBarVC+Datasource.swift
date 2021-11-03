//
//  TabBarVC+Datasource.swift
//  TabBarController
//
//  Created by Zheng on 11/2/21.
//

import UIKit

extension TabBarViewController: UICollectionViewDataSource {
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return tabs.count
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as? ContentCell else { return UICollectionViewCell() }
        
        let tab = tabs[indexPath.item]
        switch tab {
            
        case .photos:
            cell.backgroundColor = .green
        case .camera:
            cell.backgroundColor = .blue
        case .lists:
            cell.backgroundColor = .yellow
        }
        
        
        return cell
    }
}
