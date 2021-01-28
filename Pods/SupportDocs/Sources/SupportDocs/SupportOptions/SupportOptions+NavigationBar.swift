//
//  SupportOptions+NavigationBar.swift
//  SupportDocs
//
//  Created by Zheng on 10/24/20.
//

import UIKit
import SwiftUI

public extension SupportOptions {
    
    /**
     Customize the appearance of the Navigation Bar.
     */
    struct NavigationBar {
        
        /**
         Customize the appearance of the Navigation Bar.
         
         - parameter title: The title to show at the top of the screen.
         - parameter titleColor: Color of the title.
         - parameter dismissButtonView: The view to be used as the dismiss button. If you leave this as `nil`, no dismiss button will be shown.
         - parameter buttonTintColor: Color of the Back and Dismiss buttons.
         - parameter backgroundColor: Background color of the Navigation Bar.
         */
        public init(
            title: String = "Support",
            titleColor: UIColor = UIColor.label,
            dismissButtonView: AnyView? = nil,
            buttonTintColor: UIColor? = nil,
            backgroundColor: UIColor? = nil
        ) {
            self.title = title
            self.titleColor = titleColor
            self.dismissButtonView = dismissButtonView
            self.buttonTintColor = buttonTintColor
            self.backgroundColor = backgroundColor
        }
        
        /**
         The title to show at the top of the screen.
         */
        public var title: String = "Support"
        
        /**
         Color of the title.
         */
        public var titleColor: UIColor = UIColor.label
        
        /**
         The view to be shown as the dismiss button
         
         If you leave this as `nil`, no dismiss button will be shown.
         
         # Warning
         If you're using SupportDocs in SwiftUI, you must also pass in the `Binding<Bool>` that you use to show the `sheet`. If you don't provide this, no dismiss button will be shown.
         ```
         struct ContentView: View {
             let dataSource = URL(string: "https://raw.githubusercontent.com/aheze/SupportDocs/DataSource/_data/supportdocs_datasource.json")!
             
             let options: SupportOptions = SupportOptions(
                 navigationBar: .init(
                     dismissButtonView: AnyView(Image(systemName: "xmark"))
                 )
             )
         
            @State var presentingModal = false /// the `Binding<Bool>` that you use to show the `sheet`
             var body: some View {
                 Button("Present") { self.presentingModal = true }
                 .sheet(isPresented: $presentingModal) {
         
                     /// you MUST pass in `$presentingModal`!
                     SupportDocs_SwiftUI(dataSourceURL: dataSource, options: options, isPresentedBinding: $presentingModal)
                 }
             }
         }
         ```
         */
        public var dismissButtonView: AnyView? = nil
        
        /**
         Color of the Back and Dismiss buttons.
         */
        public var buttonTintColor: UIColor? = nil
        
        /**
         Background color of the Navigation Bar.
         */
        public var backgroundColor: UIColor? = nil
        
    }
}

extension SupportOptions.NavigationBar {
    
    /**
     Customize the appearance of the Navigation Bar.
     
     - parameter title: The title to show at the top of the screen.
     - parameter titleColor: Color of the title.
     - parameter dismissButtonTitle: The title to display for the dismiss button.
     - parameter buttonTintColor: Color of the Back and Dismiss buttons.
     - parameter backgroundColor: Background color of the Navigation Bar.
     
     This is an overload of the main initializer, `init(title:titleColor:dismissButtonView:buttonTintColor:backgroundColor:)`, allowing you to initialize a navigation bar's dismiss button with a plain `String` instead of `AnyView`. This makes it easier since most time you just want a `String` for the dismiss button, not some custom `Image` or something else.
     */
    public init(
        title: String = "Support",
        titleColor: UIColor = UIColor.label,
        dismissButtonTitle: String = "",
        buttonTintColor: UIColor? = nil,
        backgroundColor: UIColor? = nil
    ) {
        self.title = title
        self.titleColor = titleColor
        self.dismissButtonView = AnyView(Text(dismissButtonTitle))
        self.buttonTintColor = buttonTintColor
        self.backgroundColor = backgroundColor
    }
}
