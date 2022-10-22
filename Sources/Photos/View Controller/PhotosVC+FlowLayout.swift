//
//  PhotosVC+FlowLayout.swift
//  Find
//
//  Created by A. Zheng (github.com/aheze) on 3/19/22.
//  Copyright © 2022 A. Zheng. All rights reserved.
//

import UIKit

extension PhotosViewController {
    func makeFlowLayout() -> PhotosCollectionFlowLayout {
        let flowLayout = PhotosCollectionFlowLayout()
        flowLayout.getContent = { [weak self] in
            guard let self = self else { return .photos([]) }

            let sections: [Section] = self.model.displayedSections.map { photosSection in
                let items = photosSection.photos.map { Section.Item.photo($0) }
                let section = Section(
                    category: .photosSectionCategorization(photosSection.categorization),
                    items: items
                )
                return section
            }

            return .sections(sections)
        }
        flowLayout.getMinCellWidth = { [weak self] in
            guard let self = self else { return 0 }
            return self.realmModel.photosMinimumCellLength
        }
        return flowLayout
    }
}
