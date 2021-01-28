//
//  SupportOptions+SearchBar.swift
//  SupportDocsSwiftUI
//
//  Created by Zheng on 11/28/20.
//

import UIKit
import SwiftUI
import Combine

public extension SupportOptions {
    
    /**
     Customize the appearance of the Search Bar.
     */
    struct SearchBar {
        
        /**
         Customize the appearance of the Search Bar.
         
         - parameter placeholder: The placeholder shown in the search bar before the user has entered text.
         - parameter placeholderColor: Color of the placeholder and search icon.
         - parameter textColor: Color of the search text.
         - parameter tintColor: Color of the cursor and "Cancel" button.
         - parameter backgroundColor: Background color of the search text field.
         - parameter clearButtonMode: A mode that controls when the standard Clear button appears in the text field.
         */
        public init(
            placeholder: String = "Search",
            placeholderColor: UIColor = UIColor.secondaryLabel.withAlphaComponent(0.75),
            textColor: UIColor = UIColor.label,
            tintColor: UIColor = UIColor.blue,
            backgroundColor: UIColor =  UIColor.white.withAlphaComponent(0.3),
            clearButtonMode: UITextField.ViewMode = .whileEditing
        ) {
            self.placeholder = placeholder
            self.placeholderColor = placeholderColor
            self.textColor = textColor
            self.tintColor = tintColor
            self.backgroundColor = backgroundColor
            self.clearButtonMode = clearButtonMode
        }
        
        
        /**
         The placeholder shown in the search bar before the user has entered text.
         */
        public var placeholder: String = "Search"
        
        /**
         Color of the placeholder and search icon.
         */
        public var placeholderColor: UIColor = UIColor.secondaryLabel.withAlphaComponent(0.75)
        
        /**
         Color of the search text.
         */
        public var textColor: UIColor = UIColor.label
        
        /**
         Color of the cursor and "Cancel" button.
         */
        public var tintColor: UIColor = UIColor.blue
        
        /**
         Background color of the search text field.
         */
        public var backgroundColor: UIColor = UIColor.white.withAlphaComponent(0.3)
        
        /**
         A mode that controls when the standard Clear button appears in the text field.
         */
        public var clearButtonMode: UITextField.ViewMode = .whileEditing
    }
}

/**
 Search bar at the top of the NavigationView.
 
 Source: [http://blog.eppz.eu/swiftui-search-bar-in-the-navigation-bar/]( http://blog.eppz.eu/swiftui-search-bar-in-the-navigation-bar/).
 
 MIT License
 */
class SearchBarConfigurator: NSObject, ObservableObject {
    
    let objectWillChange = PassthroughSubject<Void, Never>()
    
    /// The text inside the search bar.
    @Published var searchText: String = "" {
        willSet {
            self.objectWillChange.send()
        }
    }
    
    /// Instance of the search controller.
    let searchController: UISearchController = UISearchController(searchResultsController: nil)
    
    override init() {
        super.init()
        
        /// Prevent a gray overlay over the list.
        self.searchController.obscuresBackgroundDuringPresentation = false
        
        /// Set the delegate.
        self.searchController.searchResultsUpdater = self
    }
}

/**
 Listen for changes in the search bar's text.
 */
extension SearchBarConfigurator: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        
        /// Publish search bar text changes.
        if let searchBarText = searchController.searchBar.text {
            self.searchText = searchBarText
        }
    }
}
