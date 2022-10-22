//
//  HighlightsViewController.swift
//  Find
//
//  Created by A. Zheng (github.com/aheze) on 12/30/21.
//  Copyright © 2021 A. Zheng. All rights reserved.
//
    
import SwiftUI

class HighlightsViewController: UIViewController {
    var highlightsViewModel: HighlightsViewModel
    var realmModel: RealmModel
    
    init(
        highlightsViewModel: HighlightsViewModel,
        realmModel: RealmModel
    ) {
        self.highlightsViewModel = highlightsViewModel
        self.realmModel = realmModel
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
        
        let highlightsView = HighlightsView(
            highlightsViewModel: highlightsViewModel,
            realmModel: realmModel
        )
        let hostingController = UIHostingController(rootView: highlightsView)
        hostingController.view.frame = view.bounds
        hostingController.view.backgroundColor = .clear
        hostingController.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        addChild(hostingController)
        view.addSubview(hostingController.view)
        hostingController.didMove(toParent: self)
    }
}
