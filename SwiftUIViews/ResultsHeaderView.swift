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
    @Published var description = " More results will appear as Find scans more photos."
}

struct ResultsHeaderView: View {
    @ObservedObject var model: ResultsHeaderViewModel
    var body: some View {
        Group {
            Text(model.text)
                + Text(model.description)
                .foregroundColor(UIColor.secondaryLabel.color)
        }
        .fixedSize(horizontal: false, vertical: true)
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

class HeaderContentModel: ObservableObject {
    var size: CGSize? = CGSize(width: 50, height: 50)
    var sizeChanged: (() -> Void)?
}

struct HeaderContent<Content: View>: View {
    @ObservedObject var headerContentModel: HeaderContentModel
    @ViewBuilder let content: Content
    var body: some View {
        content
            .readSize {
                headerContentModel.size = $0
                headerContentModel.sizeChanged?()
            }
    }
}

class HeaderContentView: UICollectionReusableView {
    var content: AnyView?
}

extension UIViewController {
    func getHeaderContent<Content: View>(
        collectionView: UICollectionView,
        kind: String, indexPath:
        IndexPath,
        content: Content,
        headerContentModel: HeaderContentModel
    ) -> UICollectionReusableView? {
        if
            kind == UICollectionView.elementKindSectionHeader,
            let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "HeaderContentView", for: indexPath) as? HeaderContentView
        {
            if headerView.content == nil {
                let headerContent = AnyView(
                    HeaderContent(headerContentModel: headerContentModel) {
                        content
                    }
                )

                headerView.content = headerContent
                let hostingController = UIHostingController(rootView: headerContent)
                hostingController.view.backgroundColor = .clear
                self.addChildViewController(hostingController, in: headerView)
            }
            return headerView
        }
        return nil
    }
}
