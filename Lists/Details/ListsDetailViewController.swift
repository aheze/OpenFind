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
    
    init(list: List, searchConfiguration: SearchConfiguration) {
        let model = ListsDetailViewModel(list: list)
        self.model = model
        self.searchConfiguration = searchConfiguration
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var updateSearchBarOffset: (() -> Void)?
    var searchBarOffset = CGFloat(0)
    override func loadView() {
        
        /**
         Instantiate the base `view`.
         */
        view = UIView()
        view.backgroundColor = .systemBackground
        
        let topInset = UIApplication.shared.keyWindow?.safeAreaInsets.top ?? 0
        let barHeight = navigationController?.navigationBar.getCompactHeight() ?? 0
        searchBarOffset = topInset + barHeight
        
        model.safeAreaTopInset = topInset + barHeight
        model.topContentInset = searchConfiguration.getTotalHeight()
        
        model.searchBarOffsetChanged = { [weak self] in
            guard let self = self else { return }
            self.searchBarOffset = self.model.searchBarOffset
            
            print("of: \(self.model.searchBarOffset)")
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
