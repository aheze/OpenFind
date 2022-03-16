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
        searchContainerView.addSubview(progressContainerView)
        progressContainerView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            progressContainerView.bottomAnchor.constraint(equalTo: searchContainerView.bottomAnchor),
            progressContainerView.leftAnchor.constraint(equalTo: searchContainerView.leftAnchor),
            progressContainerView.rightAnchor.constraint(equalTo: searchContainerView.rightAnchor),
            progressContainerView.heightAnchor.constraint(equalToConstant: 4)
        ])
        
        let progressLineView = ProgressLineView(model: progressViewModel)
        let hostingController = UIHostingController(rootView: progressLineView)
        addChildViewController(hostingController, in: progressContainerView)
        hostingController.view?.backgroundColor = .clear
    }
}
