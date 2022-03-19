//
//  PhotosVC+FlowLayout.swift
//  Find
//
//  Created by A. Zheng (github.com/aheze) on 3/19/22.
//  Copyright © 2022 A. Zheng. All rights reserved.
//

import UIKit

extension PhotosViewController {
    func createFlowLayout() -> PhotosCollectionFlowLayout {
        let flowLayout = PhotosCollectionFlowLayout()
        flowLayout.getSections = { [weak self] in
            guard let self = self else { return [] }

            let sections: [Section] = self.model.sections.map { photosSection in
                let items = photosSection.photos.map { Section.Item.photo($0) }
                let section = Section(
                    category: .photosSectionCategorization(photosSection.categorization),
                    items: items
                )
                return section
            }

            return sections
        }
        return flowLayout
    }
}
