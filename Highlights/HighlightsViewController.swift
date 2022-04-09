//
//  HighlightsViewController.swift
//  Find
//
//  Created by A. Zheng (github.com/aheze) on 12/30/21.
//  Copyright © 2021 A. Zheng. All rights reserved.
//
    
import SwiftUI

/**
 The View Controller that hosts `PopoverContainerView`. This is automatically managed.
 */
class HighlightsViewController: UIViewController {
    /// The popover model to pass down to `PopoverContainerView`.
    var highlightsViewModel: HighlightsViewModel
    /**
     Create a new `PopoverContainerViewController`. This is automatically managed.
     */
    init(highlightsViewModel: HighlightsViewModel) {
        self.highlightsViewModel = highlightsViewModel
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
        view.addDebugBorders(.green)
        let highlightsView = HighlightsView(
            highlightsViewModel: highlightsViewModel
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
