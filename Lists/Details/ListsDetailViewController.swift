//
//  ListsDetailViewController.swift
//  Find
//
//  Created by A. Zheng (github.com/aheze) on 1/21/22.
//  Copyright © 2022 A. Zheng. All rights reserved.
//


import SwiftUI

class ListsDetailViewController: UIViewController, Searchable {
    
    var model: ListsDetailViewModel
    var searchConfiguration: SearchConfiguration
    
    var baseSearchBarOffset = CGFloat(0)
    var additionalSearchBarOffset = CGFloat(0)
    var updateSearchBarOffset: (() -> Void)?
    
    init(list: List, searchConfiguration: SearchConfiguration) {
        let model = ListsDetailViewModel(list: list)
        self.model = model
        self.searchConfiguration = searchConfiguration
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        
        /**
         Instantiate the base `view`.
         */
        view = UIView()
        view.backgroundColor = .systemBackground
        
        baseSearchBarOffset = getCompactBarSafeAreaHeight()
        model.topContentInset = searchConfiguration.getTotalHeight()
        
        model.scrolled = { [weak self] in
            guard let self = self else { return }
            self.additionalSearchBarOffset = self.model.scrollViewOffset
            self.updateSearchBarOffset?()
        }
        
        let containerView = ListsDetailView(model: model)
        let hostingController = UIHostingController(rootView: containerView)
        hostingController.view.frame = view.bounds
        hostingController.view.backgroundColor = .clear
        hostingController.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]

        addChild(hostingController)
        view.addSubview(hostingController.view)
        hostingController.didMove(toParent: self)
        
        self.title = "List"
        navigationItem.largeTitleDisplayMode = .never
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        print("safe: \(view.safeAreaInsets.top)")
        model.scrollViewOffsetUpdated(model.scrollViewOffset)
    }
}
