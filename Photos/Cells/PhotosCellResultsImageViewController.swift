//
//  PhotosCellResultsImageViewController.swift
//  Find
//
//  Created by A. Zheng (github.com/aheze) on 5/28/22.
//  Copyright © 2022 A. Zheng. All rights reserved.
//
    
import Photos
import SwiftUI

class PhotosCellResults: UICollectionViewCell {
    /// when fetching an image, this will be populated
    var fetchingID: PHImageRequestID?
    
    var representedAssetIdentifier: String?
    var viewController: PhotosCellResultsImageViewController?
}

class PhotosCellResultsImageViewController: UIViewController {
    let model: PhotosCellImageViewModel
    let resultsModel: PhotosCellResultsImageViewModel
    let textModel: EditableTextViewModel
    let highlightsViewModel: HighlightsViewModel
    let realmModel: RealmModel
    
    init(
        model: PhotosCellImageViewModel? = nil,
        resultsModel: PhotosCellResultsImageViewModel? = nil,
        textModel: EditableTextViewModel? = nil,
        highlightsViewModel: HighlightsViewModel? = nil,
        realmModel: RealmModel
    ) {
        self.model = model ?? .init()
        self.resultsModel = resultsModel ?? .init()
        self.textModel = textModel ?? .init(configuration: .cellResults)
        self.highlightsViewModel = highlightsViewModel ?? .init()
        self.realmModel = realmModel
        
        self.highlightsViewModel.shouldScaleHighlights = false /// highlights are already scaled
        super.init(nibName: nil, bundle: nil)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        /**
         Instantiate the base `view`.
         */
        view = UIView()
        view.backgroundColor = .clear
        
        let contentView = PhotosCellResultsImageView(
            model: model,
            resultsModel: resultsModel,
            textModel: textModel,
            highlightsViewModel: highlightsViewModel,
            realmModel: realmModel
        )
        
        let hostingController = UIHostingController(rootView: contentView)
        hostingController.view.frame = view.bounds
        hostingController.view.backgroundColor = .clear
        hostingController.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        addChild(hostingController)
        view.addSubview(hostingController.view)
        hostingController.didMove(toParent: self)
    }
}
