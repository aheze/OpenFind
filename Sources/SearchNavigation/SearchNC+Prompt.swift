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
        
        detailsSearchPromptViewModel.updateBarHeight = { [weak self] in
            
            guard
                let self = self,
                let slides = self.navigation.topViewController as? Searchable,
                let slidesSearchViewModel = self.detailsSearchViewModel
            else { return }
            
            let promptHeight: CGFloat
            let barHeight: CGFloat
            
            let searchBarOffset = slides.baseSearchBarOffset + max(0, slides.additionalSearchBarOffset ?? 0)
            let promptOffset = searchBarOffset + slidesSearchViewModel.getTotalHeight()
            if self.detailsSearchPromptViewModel?.show ?? false {
                promptHeight = detailsSearchPromptViewModel.height()
                barHeight = promptOffset + promptHeight
            } else {
                promptHeight = 0
                barHeight = promptOffset
            }
            
            self.detailsSearchPromptViewContainerHeightC?.constant = promptHeight
            self.navigationBarBackgroundHeightC?.constant = barHeight
            UIView.animate(withDuration: 0.3) {
                self.navigationBarBackgroundContainer.layoutIfNeeded()
                self.searchContainerViewContainer.layoutIfNeeded()
            }
        }
    }
}
