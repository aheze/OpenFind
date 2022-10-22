//
//  ResultsHeaderView.swift
//  Find
//
//  Created by A. Zheng (github.com/aheze) on 3/15/22.
//  Copyright © 2022 A. Zheng. All rights reserved.
//

import SwiftUI

class ResultsHeaderViewModel: ObservableObject {
    @Published var text = "Finding..."
    @Published var description: String? = defaultDescription

    static let defaultDescription = "More results will appear as Find scans more photos."
}

struct ResultsHeaderView: View {
    @ObservedObject var model: PhotosViewModel
    @ObservedObject var resultsHeaderViewModel: ResultsHeaderViewModel
    @ObservedObject var progressViewModel: ProgressViewModel

    var body: some View {
        Button {
            model.scanningIconTapped?()
        } label: {
            VStack(alignment: .leading, spacing: 12) {
                Group {
                    Text(resultsHeaderViewModel.text)
                        .foregroundColor(Colors.accent.color)
                        + Text(" ")
                        + Text(resultsHeaderViewModel.description ?? "")
                        .foregroundColor(Colors.accent.color.opacity(0.5))
                }
                .fixedSize(horizontal: false, vertical: true)
                .frame(maxWidth: .infinity, alignment: .leading)
                .multilineTextAlignment(.leading)

                PhotosScanningHeader(model: model)
                    .padding(16)
                    .background(Color.accent.opacity(0.1))
                    .cornerRadius(14)
            }
            .padding(16)
            .background(
                ProgressLineView(model: progressViewModel)
                    .opacity(0.1)
                    .padding(-20)
                    .blur(radius: 4)
            )
            .blueBackground()
        }
        .buttonStyle(EasingScaleButtonStyle())
        .padding(.bottom, ListsCollectionConstants.cellSpacing)
    }
}


