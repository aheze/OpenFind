//
//  SearchNC+Prompt.swift
//  Find
//
//  Created by A. Zheng (github.com/aheze) on 3/14/22.
//  Copyright © 2022 A. Zheng. All rights reserved.
//
    

import SwiftUI

extension SearchNavigationController {
    func setupPrompt() {
        guard let detailsSearchPromptViewModel = detailsSearchPromptViewModel else { return }
        
        searchContainerViewContainer.addSubview(detailsSearchPromptViewContainer)
        detailsSearchPromptViewContainer.translatesAutoresizingMaskIntoConstraints = false
        
        let detailsSearchPromptViewContainerTopC = detailsSearchPromptViewContainer.topAnchor.constraint(equalTo: searchContainerViewContainer.topAnchor)
        let detailsSearchPromptViewContainerHeightC = detailsSearchPromptViewContainer.heightAnchor.constraint(equalToConstant: 50)
        self.detailsSearchPromptViewContainerTopC = detailsSearchPromptViewContainerTopC
        self.detailsSearchPromptViewContainerHeightC = detailsSearchPromptViewContainerHeightC
        NSLayoutConstraint.activate([
            detailsSearchPromptViewContainerTopC,
            detailsSearchPromptViewContainer.leftAnchor.constraint(equalTo: searchContainerViewContainer.leftAnchor),
            detailsSearchPromptViewContainer.rightAnchor.constraint(equalTo: searchContainerViewContainer.rightAnchor),
            detailsSearchPromptViewContainerHeightC
        ])
        
        let promptView = SearchPromptView(model: detailsSearchPromptViewModel)
        let hostingController = UIHostingController(rootView: promptView)
        hostingController.view.backgroundColor = .clear
        addChildViewController(hostingController, in: detailsSearchPromptViewContainer)
    }
}
