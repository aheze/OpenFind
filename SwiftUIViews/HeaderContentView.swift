//
//  ResultsHeaderView.swift
//  Find
//
//  Created by A. Zheng (github.com/aheze) on 3/14/22.
//  Copyright © 2022 A. Zheng. All rights reserved.
//

import SwiftUI

class HeaderContentModel: ObservableObject {
    var size: CGSize? = CGSize(width: 0, height: 0)
    var added = false /// true if added as subview
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

extension UIViewController {
    func setupHeaderView<Content: View>(view: Content, headerContentModel: HeaderContentModel, sidePadding: CGFloat, in collectionView: UICollectionView) -> NSLayoutConstraint? {
        /// called every time show results, show make sure to not add duplicate subviews
        guard !headerContentModel.added else { return nil }

        let container = UIView()
        collectionView.addSubview(container)
        container.translatesAutoresizingMaskIntoConstraints = false
        let heightC = container.heightAnchor.constraint(equalToConstant: 100)
        NSLayoutConstraint.activate([
            container.topAnchor.constraint(equalTo: collectionView.topAnchor),
            container.leftAnchor.constraint(equalTo: collectionView.leftAnchor, constant: sidePadding),
            container.widthAnchor.constraint(equalTo: collectionView.safeAreaLayoutGuide.widthAnchor, constant: -sidePadding * 2),
            heightC
        ])

        let headerContent = HeaderContent(headerContentModel: headerContentModel) { view }
        let hostingController = UIHostingController(rootView: headerContent)
        self.addChildViewController(hostingController, in: container)

        hostingController.view.backgroundColor = .clear
        hostingController.view.pinEdgesToSuperview()

        collectionView.setNeedsLayout()
        collectionView.layoutIfNeeded()

        headerContentModel.added = true
        return heightC
    }
}
