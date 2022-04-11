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
        if let resultsHeaderHeightC = setupHeaderView(
            view: resultsHeaderView,
            headerContentModel: headerContentModel,
            sidePadding: ListsCollectionConstants.sidePadding,
            in: resultsCollectionView
        ) {
            self.resultsHeaderHeightC = resultsHeaderHeightC
        }
    }
}
