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
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
      super.viewWillTransition(to: size, with: coordinator)
      coordinator.animate(alongsideTransition: { context in
        self.collectionView.collectionViewLayout.invalidateLayout()
      }, completion: nil)
    }
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
            cellProvider: { (collectionView, indexPath, findPhoto) ->
                UICollectionViewCell? in
                // 2
                let cell = collectionView.dequeueReusableCell(
                    withReuseIdentifier: self.cellReuseIdentifier,
                    for: indexPath) as? ImageCell
                
                if let url = NSURL.sd_URL(with: findPhoto.asset) {
                    let cellLength = cell?.bounds.width ?? 100
                    let imageLength = cellLength * (self.screenScale + 1)

                    cell?.imageView.sd_imageTransition = .fade
                    cell?.imageView.sd_setImage(with: url as URL, placeholderImage: nil, options: SDWebImageOptions.fromLoaderOnly, context: [SDWebImageContextOption.storeCacheType: SDImageCacheType.none.rawValue, .imageThumbnailPixelSize : CGSize(width: imageLength, height: imageLength)])

                    if let model = findPhoto.model {
                        if model.isDeepSearched {
                            cell?.cacheImageView.image = UIImage(named: "CacheActive-Light")
                        } else {
                            cell?.cacheImageView.image = nil
                        }
                        if model.isHearted {
                            cell?.starImageView.image = UIImage(systemName: "star.fill")?.withRenderingMode(.alwaysTemplate)
                        } else {
                            cell?.starImageView.image = nil
                        }
                        if model.isDeepSearched || model.isHearted {
                            cell?.shadowImageView.image = UIImage(named: "DownShadow")
                        } else {
                            cell?.shadowImageView.image = nil
                        }
                    } else {
                        cell?.cacheImageView.image = nil
                        cell?.starImageView.image = nil
                        cell?.shadowImageView.image = nil
                    }
                    
                    if self.indexPathsSelected.contains(indexPath) {
                        cell?.highlightView.isHidden = false
                        cell?.selectionImageView.isHidden = false
                    } else {
                        cell?.highlightView.isHidden = true
                        cell?.selectionImageView.isHidden = true
                    }
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
            
            
            let formatter = DateFormatter()
            formatter.dateFormat = "MMMM yyyy"
            let dateAsString = formatter.string(from: section.monthDate)
            
            view?.monthLabel.text = dateAsString
            return view
        }
        return dataSource
    }
    func applySnapshot(animatingDifferences: Bool = true) {
        // 2
        var snapshot = Snapshot()
        // 3
        snapshot.appendSections(monthsToDisplay)
        monthsToDisplay.forEach { month in
            snapshot.appendItems(month.photos, toSection: month)
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
            
            let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitem: item, count: itemCount)
            group.interItemSpacing = .fixed(3)
            
            let section = NSCollectionLayoutSection(group: group)
            section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 20, trailing: 0)
            section.interGroupSpacing = 3
            
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
            sectionHeader.pinToVisibleBounds = true
            return section
        })
    }
}
