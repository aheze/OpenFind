//
//  ResultsHeaderView.swift
//  Find
//
//  Created by A. Zheng (github.com/aheze) on 3/14/22.
//  Copyright © 2022 A. Zheng. All rights reserved.
//

import SwiftUI

/// conform to this to get extra space for top content
protocol HeaderSettable: UICollectionViewFlowLayout {
    var headerHeight: CGFloat { get set }
}

class ResultsHeaderViewModel: ObservableObject {
    @Published var text = "10 Results."
    @Published var size: CGSize?
}

struct ResultsHeaderView: View {
    @ObservedObject var model: ResultsHeaderViewModel
    var body: some View {
        Text(model.text)
            .foregroundColor(.accent)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding()
            .border(Color.accent)
            .readSize {
                model.size = $0
            }
    }
}

class HeaderContentView: UICollectionReusableView {
    var content: AnyView?
}
