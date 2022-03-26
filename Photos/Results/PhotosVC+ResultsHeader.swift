//
//  PhotosVC+ResultsHeader.swift
//  Find
//
//  Created by A. Zheng (github.com/aheze) on 3/25/22.
//  Copyright © 2022 A. Zheng. All rights reserved.
//

import SwiftUI

extension PhotosViewController {
    func setupResultsHeader() {
        
        /// called every time show results, show make sure to not add duplicate subviews
        guard resultsHeaderHeightC == nil else { return }
        
        resultsCollectionView.addSubview(resultsHeaderContainer)
        resultsHeaderContainer.translatesAutoresizingMaskIntoConstraints = false
        let resultsHeaderHeightC = resultsHeaderContainer.heightAnchor.constraint(equalToConstant: 100)
        NSLayoutConstraint.activate([
            resultsHeaderContainer.topAnchor.constraint(equalTo: resultsCollectionView.topAnchor),
            resultsHeaderContainer.leftAnchor.constraint(equalTo: resultsCollectionView.leftAnchor, constant: ListsCollectionConstants.sidePadding),
            resultsHeaderContainer.widthAnchor.constraint(equalTo: resultsCollectionView.safeAreaLayoutGuide.widthAnchor, constant: -ListsCollectionConstants.sidePadding * 2),
            resultsHeaderHeightC
        ])
        self.resultsHeaderHeightC = resultsHeaderHeightC

        let headerContent = HeaderContent(headerContentModel: headerContentModel) { resultsHeaderView }
        let hostingController = UIHostingController(rootView: headerContent)
        self.addChildViewController(hostingController, in: resultsHeaderContainer)

        hostingController.view.backgroundColor = .clear
        hostingController.view.pinEdgesToSuperview()

        self.collectionView.setNeedsLayout()
        self.collectionView.layoutIfNeeded()
    }
}
