//
//  SearchNC+Progress.swift
//  Find
//
//  Created by A. Zheng (github.com/aheze) on 3/16/22.
//  Copyright © 2022 A. Zheng. All rights reserved.
//
    
import SwiftUI

extension SearchNavigationController {
    func setupProgress() {
        guard let progressViewModel = progressViewModel else { return }
        
        /// constrain to `searchContainerViewContainer`, since that's where the prompt is added too
        searchContainerViewContainer.addSubview(progressContainerView)
        progressContainerView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            
            /// ensure the progress bar is at the bottom
            progressContainerView.bottomAnchor.constraint(equalTo: detailsSearchPromptViewContainer.bottomAnchor),
            progressContainerView.leftAnchor.constraint(equalTo: searchContainerViewContainer.leftAnchor),
            progressContainerView.rightAnchor.constraint(equalTo: searchContainerViewContainer.rightAnchor),
            progressContainerView.heightAnchor.constraint(equalToConstant: 4)
        ])
        
        let progressLineView = ProgressLineView(model: progressViewModel)
        let hostingController = UIHostingController(rootView: progressLineView)
        addChildViewController(hostingController, in: progressContainerView)
        hostingController.view?.backgroundColor = .clear
    }
}
