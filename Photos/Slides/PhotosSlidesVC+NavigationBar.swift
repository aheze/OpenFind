//
//  PhotosSlidesVC+NavigationBar.swift
//  Find
//
//  Created by A. Zheng (github.com/aheze) on 4/8/22.
//  Copyright © 2022 A. Zheng. All rights reserved.
//

import SwiftUI

class TitleViewModel: ObservableObject {
    @Published var title = ""
    @Published var subtitle = ""
    @Published var accessibilityLabel = ""
}

struct TitleView: View {
    @ObservedObject var titleViewModel: TitleViewModel
    var body: some View {
        VStack(spacing: 2) {
            Text(titleViewModel.title)
                .font(.system(size: 15))

            Text(titleViewModel.subtitle)
                .font(.system(size: 11))
        }
        .accessibilityElement()
        .accessibilityLabel(titleViewModel.accessibilityLabel)
    }
}

extension PhotosSlidesViewController {
    func setupNavigationBar() {
        let contentView = TitleView(titleViewModel: titleViewModel)
        let hostingController = UIHostingController(rootView: contentView)
        hostingController.view.backgroundColor = .clear
        navigationItem.titleView = hostingController.view
        titleView = hostingController.view
        titleView.frame = CGRect(x: 0, y: 0, width: 200, height: 0)
        
        if let currentPhoto = model.slidesState?.currentPhoto {
            updateNavigationBarTitle(for: currentPhoto)
        }
    }

    func updateNavigationBarTitle(for photo: Photo) {
        if let dateCreated = photo.asset.creationDate {
            let dateAsString = dateCreated.convertDateToReadableString()
            let timeAsString = photo.asset.timeCreatedString ?? ""

            titleViewModel.accessibilityLabel = "\(dateAsString) at \(timeAsString)"
            titleViewModel.title = dateAsString
            titleViewModel.subtitle = timeAsString
        }
    }
}
