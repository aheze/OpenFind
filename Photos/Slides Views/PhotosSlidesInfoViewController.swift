//
//  PhotosSlidesInfoViewController.swift
//  Find
//
//  Created by A. Zheng (github.com/aheze) on 3/21/22.
//  Copyright © 2022 A. Zheng. All rights reserved.
//

import SwiftUI

class PhotoSlidesInfoViewModel: ObservableObject {
    @Published var showHandle = false /// for scroll
    
    var reportSize = false
    var sizeChanged: ((CGSize) -> Void)?
    var noteChanged: (() -> Void)?
}

class PhotosSlidesInfoViewController: UIViewController {
    var model: PhotosViewModel
    var realmModel: RealmModel
    var infoModel: PhotoSlidesInfoViewModel
    var textModel: EditableTextViewModel

    init(
        model: PhotosViewModel,
        realmModel: RealmModel,
        infoModel: PhotoSlidesInfoViewModel,
        textModel: EditableTextViewModel
    ) {
        self.model = model
        self.realmModel = realmModel
        self.infoModel = infoModel
        self.textModel = textModel
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
        view.backgroundColor = .systemBackground

        let contentView = PhotosSlidesInfoView(model: model, realmModel: realmModel, infoModel: infoModel, textModel: textModel)
        let hostingController = UIHostingController(rootView: contentView)
        hostingController.view.frame = view.bounds
        hostingController.view.backgroundColor = .clear
        hostingController.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]

        addChild(hostingController)
        view.addSubview(hostingController.view)
        hostingController.didMove(toParent: self)
    }
}
