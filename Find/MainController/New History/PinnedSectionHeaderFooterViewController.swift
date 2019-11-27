//
//  HCollectionViewController.swift
//  Find
//
//  Created by Andrew on 11/25/19.
//  Copyright © 2019 Andrew. All rights reserved.
//
import UIKit

class PinnedSectionHeaderFooterViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    
    
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    //static let sectionHeaderElementKind = "section-header-element-kind"
    
    //static let sectionFooterElementKind = "section-footer-element-kind"

    //var dataSource: UICollectionViewDiffableDataSource<Int, Int>! = nil
    //var collectionView: UICollectionView! = nil

    override func viewDidLoad() {
        super.viewDidLoad()
        //navigationItem.title = "Pinned Section Headers"
        //configureHierarchy()
        //configureDataSource()
        collectionView.delegate = self
        collectionView.dataSource = self
        //collectionView.contentInsetAdjustmentBehavior
        let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout
        layout?.sectionHeadersPinToVisibleBounds = true
    }
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        switch kind {
        case UICollectionView.elementKindSectionHeader:

            let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "sectionHeaderId", for: indexPath) as! TitleSupplementaryView
            headerView.todayLabel.text = "Text!: \(indexPath.section)"
            return headerView

        case UICollectionView.elementKindSectionFooter:
            let footerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "sectionFooterId", for: indexPath) as! FooterView
            footerView.clipsToBounds = false
            return footerView

        default:
            assert(false, "Unexpected element kind")
        }
        
    }
//    func collectionView(_ collectionView: UICollectionView, willDisplaySupplementaryView view: UICollectionReusableView, forElementKind elementKind: String, at indexPath: IndexPath) {
//
//    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 5
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 6
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "hPhotoId", for: indexPath) as! HPhotoCell
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let itemsPerRow = CGFloat(4)
        let sectionInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        let paddingSpace = sectionInsets.left * (itemsPerRow + 1)
        var availibleWidth = collectionView.frame.width - paddingSpace
        availibleWidth -= (itemsPerRow - 1) * 2 ///   Three spacers (there are 4 photos per row for iPhone), each 2 points.
        let widthPerItem = availibleWidth / itemsPerRow
        let size = CGSize(width: widthPerItem, height: widthPerItem)
        return size
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        //return sectionInsets
        return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 2 ///horizontal line spacing, also 2 points, just like the availibleWidth
        
    }
    
}

extension PinnedSectionHeaderFooterViewController {
//    func createLayout() -> UICollectionViewLayout {
//        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
//                                             heightDimension: .fractionalHeight(1.0))
//        let item = NSCollectionLayoutItem(layoutSize: itemSize)
//
//        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
//                                              heightDimension: .absolute(44))
//        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
//
//        let section = NSCollectionLayoutSection(group: group)
//        section.interGroupSpacing = 5
//        section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 10, bottom: 0, trailing: 10)
//
//        let sectionHeader = NSCollectionLayoutBoundarySupplementaryItem(
//            layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
//                                              heightDimension: .estimated(44)),
//            elementKind: PinnedSectionHeaderFooterViewController.sectionHeaderElementKind,
//            alignment: .top)
//        let sectionFooter = NSCollectionLayoutBoundarySupplementaryItem(
//            layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
//                                              heightDimension: .estimated(44)),
//            elementKind: PinnedSectionHeaderFooterViewController.sectionFooterElementKind,
//            alignment: .bottom)
//        sectionHeader.pinToVisibleBounds = true
//        sectionHeader.zIndex = 2
//        section.boundarySupplementaryItems = [sectionHeader, sectionFooter]
//
//        let layout = UICollectionViewCompositionalLayout(section: section)
//        return layout
//    }
}

extension PinnedSectionHeaderFooterViewController {
//    func configureHierarchy() {
//        collectionView.collectionViewLayout = createLayout()
//        //collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: createLayout())
//        //collectionView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
//        collectionView.backgroundColor = .systemBackground
//        //collectionView.register(HPhotoCell.self, forCellWithReuseIdentifier: "hPhotoId")
//        collectionView.register(TitleSupplementaryView.self,
//                    forSupplementaryViewOfKind: PinnedSectionHeaderFooterViewController.sectionHeaderElementKind,
//                    withReuseIdentifier: "sectionHeaderId")
//        collectionView.register(TitleSupplementaryView.self,
//                    forSupplementaryViewOfKind: PinnedSectionHeaderFooterViewController.sectionFooterElementKind,
//                    withReuseIdentifier: "sectionHeaderId")
//        view.addSubview(collectionView)
//        collectionView.delegate = self
//    }
//    func configureDataSource() {
//        dataSource = UICollectionViewDiffableDataSource<Int, Int>(collectionView: collectionView) {
//            (collectionView: UICollectionView, indexPath: IndexPath, identifier: Int) -> UICollectionViewCell? in
//
//            // Get a cell of the desired kind.
//            guard let cell = collectionView.dequeueReusableCell(
//                withReuseIdentifier: "hPhotoId",
//                for: indexPath) as? HPhotoCell else { fatalError("Cannot create new cell") }
//
//            cell.imageView.image = #imageLiteral(resourceName: "bmenu 2")
//            // Populate the cell with our item description.
//            //cell.label.text = "\(indexPath.section),\(indexPath.item)"
//
//            // Return the cell.
//            return cell
//        }
////        dataSource.supplementaryViewProvider = {
////            (collectionView: UICollectionView, kind: String, indexPath: IndexPath) -> UICollectionReusableView? in
////
////            // Get a supplementary view of the desired kind.
////            guard let headerFooter = collectionView.dequeueReusableSupplementaryView(
////                ofKind: kind,
////                withReuseIdentifier: "sectionHeaderId",
////                for: indexPath) as? TitleSupplementaryView else { fatalError("Cannot create new header") }
////
////            // Populate the view with our section's description.
////            let viewKind = kind == PinnedSectionHeaderFooterViewController.sectionHeaderElementKind ?
////                "Header" : "Footer"
////            headerFooter.label.text = "\(viewKind) for section \(indexPath.section)"
////            headerFooter.backgroundColor = .lightGray
////            headerFooter.layer.borderColor = UIColor.black.cgColor
////            headerFooter.layer.borderWidth = 1.0
////
////            // Return the view.
////            return headerFooter
////        }
//
//        // initial data
//        let itemsPerSection = 5
//        let sections = Array(0..<5)
//        var snapshot = NSDiffableDataSourceSnapshot<Int, Int>()
//        var itemOffset = 0
//        sections.forEach {
//            snapshot.appendSections([$0])
//            snapshot.appendItems(Array(itemOffset..<itemOffset + itemsPerSection))
//            itemOffset += itemsPerSection
//        }
//        dataSource.apply(snapshot, animatingDifferences: false)
//    }
}

extension PinnedSectionHeaderFooterViewController {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
    }
}
