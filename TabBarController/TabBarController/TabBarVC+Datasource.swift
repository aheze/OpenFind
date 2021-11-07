//
//  TabBarVC+Datasource.swift
//  TabBarController
//
//  Created by Zheng on 11/2/21.
//

import UIKit

extension TabBarViewController: UICollectionViewDataSource {
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return pages.count
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as? ContentCell else { return UICollectionViewCell() }
        return cell
    }
}

