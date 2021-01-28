//
//  SupportDocsView+Lists.swift
//  SupportDocsSwiftUI
//
//  Created by Zheng on 10/13/20.
//

import SwiftUI

/**
 Each section in the List.
 */
internal struct SupportSection: Identifiable {
    let id = UUID() /// Required for the List.
    
    var name: String
    var color: UIColor
    var supportItems: [SupportItem]
}

/**
 Each item in a section in the List.
 */
internal struct SupportItem: Identifiable {
    let id = UUID() /// Required for the List.
    
    var title: String
    var url: String
}

/**
 The `View` that displays the title of each document, used in the List.
 
 Think of this as the `Cell` class for `cellForItemAt` if this was UIKit.
 */
internal struct SupportItemRow: View {
    
    /**
     Title of the document.
     */
    var title: String
    
    /**
     Color of the title.
     */
    var titleColor: UIColor
    
    /**
     The URL to load when this `View` is tapped.
     */
    var url: URL
    
    /**
     Options for how to display the progress bar (foreground + background color).
     */
    var progressBarOptions: SupportOptions.ProgressBar
    
    var body: some View {
        NavigationLink(
            destination:
                
                /**
                 Push to the web view when tapped.
                 */
                WebViewContainer(url: url, progressBarOptions: progressBarOptions)
                .navigationBarTitle(Text(title), displayMode: .inline)
                .edgesIgnoringSafeArea([.leading, .bottom, .trailing]) /// Allow the web view to go under the home indicator, on devices similar to the iPhone X.
        ) {
            Text(title)
            .foregroundColor(Color(titleColor))
        }
    }
}
