//
//  ResultsHeaderView.swift
//  Find
//
//  Created by A. Zheng (github.com/aheze) on 3/15/22.
//  Copyright © 2022 A. Zheng. All rights reserved.
//

import SwiftUI

class ResultsHeaderViewModel: ObservableObject {
    @Published var text = "10 Results."
    @Published var description = " More results will appear as Find scans more photos."
}

struct ResultsHeaderView: View {
    @ObservedObject var model: PhotosViewModel
    @ObservedObject var resultsHeaderViewModel: ResultsHeaderViewModel

    var body: some View {
        VStack(alignment: .leading) {
            Group {
                Text(resultsHeaderViewModel.text)
                    + Text(resultsHeaderViewModel.description)
                    .foregroundColor(UIColor.secondaryLabel.color)
            }
            .fixedSize(horizontal: false, vertical: true)

            PhotosScanningHeader(model: model)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}
