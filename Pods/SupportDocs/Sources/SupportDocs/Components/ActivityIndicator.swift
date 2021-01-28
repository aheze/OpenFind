//
//  ActivityIndicator.swift
//  SupportDocsSwiftUI
//
//  Created by Zheng on 10/31/20.
//

import SwiftUI

/**
 Port `UIActivityIndicatorView` over to SwiftUI.
 
 Source: [https://stackoverflow.com/a/56496896/14351818](https://stackoverflow.com/a/56496896/14351818).
 */
internal struct ActivityIndicator: UIViewRepresentable {

    @Binding var isAnimating: Bool
    let style: UIActivityIndicatorView.Style

    func makeUIView(context: UIViewRepresentableContext<ActivityIndicator>) -> UIActivityIndicatorView {
        return UIActivityIndicatorView(style: style)
    }

    func updateUIView(_ uiView: UIActivityIndicatorView, context: UIViewRepresentableContext<ActivityIndicator>) {
        isAnimating ? uiView.startAnimating() : uiView.stopAnimating()
    }
}
