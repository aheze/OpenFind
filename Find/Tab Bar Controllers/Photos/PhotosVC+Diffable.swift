//
//  PhotosVC+Diffable.swift
//  Find
//
//  Created by Zheng on 1/4/21.
//  Copyright © 2021 Andrew. All rights reserved.
//

import UIKit
import SDWebImage
import SDWebImagePhotosPlugin

extension PhotosViewController {
    func setUpSDWebImage() {
        //Supports HTTP URL as well as Photos URL globally
        SDImageLoadersManager.shared.loaders = [SDWebImageDownloader.shared, SDImagePhotosLoader.shared]
        // Replace default manager's loader implementation
        SDWebImageManager.defaultImageLoader = SDImageLoadersManager.shared
        
        let options = PHImageRequestOptions()
        options.sd_targetSize = CGSize(width: 500, height: 500)
        
        SDImagePhotosLoader.shared.imageRequestOptions = options
    }
    func makeDataSource() -> DataSource {
        // 1
        let dataSource = DataSource(
            collectionView: collectionView,
            cellProvider: { (collectionView, indexPath, asset) ->
                UICollectionViewCell? in
                // 2
                let cell = collectionView.dequeueReusableCell(
                    withReuseIdentifier: self.cellReuseIdentifier,
                    for: indexPath) as? PhotoCell
                
                if let url = NSURL.sd_URL(with: asset) {
                    
                    let cellLength = cell?.bounds.width ?? 100
                    let imageLength = cellLength * (self.screenScale + 1)
                    
                    cell?.imageView.sd_imageTransition = .fade
                    cell?.imageView.sd_setImage(with: url as URL, placeholderImage: nil, options: SDWebImageOptions.fromLoaderOnly, context: [SDWebImageContextOption.storeCacheType: SDImageCacheType.none.rawValue, .imageThumbnailPixelSize : CGSize(width: imageLength, height: imageLength)])
                }
                return cell
            })
        
        dataSource.supplementaryViewProvider = { collectionView, kind, indexPath in
            guard kind == UICollectionView.elementKindSectionHeader else {
                return nil
            }
            let section = self.dataSource.snapshot()
                .sectionIdentifiers[indexPath.section]
            let view = collectionView.dequeueReusableSupplementaryView(
                ofKind: kind,
                withReuseIdentifier: self.headerReuseIdentifier,
                for: indexPath) as? PhotoHeader
            
            
//            view?.monthLabel.text = section.title
            view?.monthLabel.text = "Month"
            return view
        }
        return dataSource
    }
    func applySnapshot(animatingDifferences: Bool = true) {
        // 2
        var snapshot = Snapshot()
        // 3
        snapshot.appendSections(months)
        months.forEach { month in
            snapshot.appendItems(month.assets, toSection: month)
        }
        // 5
        
        dataSource.apply(snapshot, animatingDifferences: animatingDifferences)
    }
    func configureLayout() {
        collectionView.collectionViewLayout = UICollectionViewCompositionalLayout(sectionProvider: { (sectionIndex, layoutEnvironment) -> NSCollectionLayoutSection? in
            let isPhone = layoutEnvironment.traitCollection.userInterfaceIdiom == UIUserInterfaceIdiom.phone
            
            let itemCount = isPhone ? 4 : 6
            let itemWidth = CGFloat(1) / CGFloat(itemCount)
            
            let groupSize = NSCollectionLayoutSize(
                widthDimension: NSCollectionLayoutDimension.fractionalWidth(1),
                heightDimension: NSCollectionLayoutDimension.fractionalWidth(itemWidth)
            )
            
            let itemSize = NSCollectionLayoutSize(
                widthDimension: NSCollectionLayoutDimension.fractionalWidth(1),
                heightDimension: NSCollectionLayoutDimension.fractionalHeight(1)
            )
            
            let item = NSCollectionLayoutItem(layoutSize: itemSize)
            item.contentInsets = NSDirectionalEdgeInsets(
              top: 3,
              leading: 3,
              bottom: 0,
              trailing: 0
            )
            
            let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitem: item, count: itemCount)
            let section = NSCollectionLayoutSection(group: group)
            section.contentInsets = NSDirectionalEdgeInsets(top: 2, leading: 0, bottom: 3, trailing: 3)
            section.interGroupSpacing = 0
            
            // Supplementary header view setup
            let headerFooterSize = NSCollectionLayoutSize(
              widthDimension: .fractionalWidth(1.0),
              heightDimension: .absolute(40)
            )
            let sectionHeader = NSCollectionLayoutBoundarySupplementaryItem(
              layoutSize: headerFooterSize,
              elementKind: UICollectionView.elementKindSectionHeader,
              alignment: .top
            )
            section.boundarySupplementaryItems = [sectionHeader]
            return section
        })
    }
}
