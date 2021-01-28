//
//  Utilities.swift
//  SupportDocsSwiftUI
//
//  Created by Zheng on 10/31/20.
//

import SwiftUI

// MARK: - Navigation and Search Bar Configuration
/// Partially from https://github.com/Geri-Borbas/iOS.Blog.SwiftUI_Search_Bar_in_Navigation_Bar, MIT License

/**
 ViewModifier that applies SupportOptions' `NavigationBar` and `SearchBar` configurations.
 */
struct BarModifier: ViewModifier {
    
    let options: SupportOptions
    let searchBarConfigurator: SearchBarConfigurator
    
    func body(content: Content) -> some View {
        content
        .overlay( /// Workaround to apply the `ViewControllerResolver`
            ViewControllerResolver { viewController in
                
                /**
                 Only add a search bar if it's not set to `nil`.
                 */
                if let searchBarOptions = options.searchBar {
                    viewController.navigationItem.searchController = self.searchBarConfigurator.searchController
                    
                    let searchBar = searchBarConfigurator.searchController.searchBar
                    
                    let icon = UIImage(systemName: "magnifyingglass")?.withTintColor(searchBarOptions.placeholderColor, renderingMode: .alwaysOriginal)
                    searchBar.setImage(icon, for: UISearchBar.Icon.search, state: .normal)
                    searchBar.tintColor = searchBarOptions.tintColor
                    
                    searchBar.searchTextField.attributedPlaceholder = NSAttributedString(string: searchBarOptions.placeholder, attributes: [.foregroundColor: searchBarOptions.placeholderColor])
                    searchBar.searchTextField.textColor = searchBarOptions.textColor
                    searchBar.searchTextField.backgroundColor = searchBarOptions.backgroundColor
                    
                    searchBar.searchTextField.clearButtonMode = searchBarOptions.clearButtonMode
                }
                
                /**
                 Now set the Navigation Bar's configuration
                 */
                let navBarAppearance = UINavigationBarAppearance()
                navBarAppearance.configureWithOpaqueBackground()
                navBarAppearance.titleTextAttributes = [.foregroundColor: options.navigationBar.titleColor]
                navBarAppearance.largeTitleTextAttributes = [.foregroundColor: options.navigationBar.titleColor]
                
                if let backgroundColor = options.navigationBar.backgroundColor {
                    navBarAppearance.backgroundColor = backgroundColor
                    viewController.navigationController?.navigationBar.scrollEdgeAppearance = navBarAppearance
                }
                
                viewController.navigationController?.navigationBar.standardAppearance = navBarAppearance
                
                viewController.navigationController?.navigationBar.barTintColor = options.navigationBar.backgroundColor
                viewController.navigationController?.navigationBar.tintColor = options.navigationBar.buttonTintColor
                
            }
            .frame(width: 0, height: 0)
        )
    }
}

/**
 For easier usage of the bar modifier.
 */
extension View {
    func configureBar(for options: SupportOptions, searchBarConfigurator: SearchBarConfigurator) -> some View {
        return self.modifier(BarModifier(options: options, searchBarConfigurator: searchBarConfigurator))
    }
}

// MARK: - Other Utilities

/**
 Hide or show a View (support for iOS 13).
 
 Source: [https://stackoverflow.com/a/57685253/14351818](https://stackoverflow.com/a/57685253/14351818).
 */
internal extension View {
   @ViewBuilder
   func ifConditional<Content: View>(_ conditional: Bool, content: (Self) -> Content) -> some View {
        if conditional {
            content(self)
        } else {
            self
        }
    }
}

/**
 Prevent default all-caps behavior if possible (iOS 14 and above).
 */
internal extension View {
    @ViewBuilder
    func displayTextAsConfigured() -> some View {
        if #available(iOS 14, *) {
            self.textCase(nil)
        } else {
            self
        }
    }
}
