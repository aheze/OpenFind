//
//  PhotosSlidesViewController.swift
//  Find
//
//  Created by A. Zheng (github.com/aheze) on 2/16/22.
//  Copyright © 2022 A. Zheng. All rights reserved.
//

import UIKit

class PhotoSlidesSection: Hashable {
    let id = 0
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: PhotoSlidesSection, rhs: PhotoSlidesSection) -> Bool {
        lhs.id == rhs.id
    }
}
class PhotosSlidesViewController: UIViewController, Searchable {
    var baseSearchBarOffset = CGFloat(0)
    var additionalSearchBarOffset: CGFloat? = nil
    var updateSearchBarOffset: (() -> Void)?
    
    var model: PhotosViewModel
    
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var collectionView: UICollectionView!
    lazy var flowLayout = PhotosSlidesCollectionLayout(model: model)
    lazy var dataSource = makeDataSource()
    typealias DataSource = UICollectionViewDiffableDataSource<PhotoSlidesSection, Photo>
    typealias Snapshot = NSDiffableDataSourceSnapshot<PhotoSlidesSection, Photo>
    
    lazy var scrollZoomController = ScrollZoomViewController.make()

    init?(coder: NSCoder, model: PhotosViewModel) {
        self.model = model
        super.init(coder: coder)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("You must create this view controller with metadata.")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setup()
        update(animate: false)
        
        _ = scrollZoomController
        addChildViewController(scrollZoomController, in: view)
        
        if let slidesState = model.slidesState {
            model.imageManager.requestImage(
                for: slidesState.startingPhoto.asset,
                targetSize: .zero,
                contentMode: .aspectFill,
                options: nil
            ) { image, _ in
                self.scrollZoomController.imageView.image = image
            }
        }
    }
    
    func boundsChanged(to size: CGSize, safeAreaInsets: UIEdgeInsets) {
        baseSearchBarOffset = getCompactBarSafeAreaHeight(with: safeAreaInsets)
        updateSearchBarOffset?()
    }
}
