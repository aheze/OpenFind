//
//  SupportOptions.swift
//  SupportDocs
//
//  Created by Zheng on 10/24/20.
//

import SwiftUI

/**
 Options for configuring SupportDocs.
 
 # Parameters
 - `categories`: Allows you to group documents with the same `tag` into the same section of the list. Each category may contain more than one `tag`.
 - `navigationBar`: Customize the Navigation Bar's `title`, `titleColor`, `dismissButtonTitle`, `buttonTintColor`, and `backgroundColor`.
 - `searchBar`: Customize the `placeholder`, `placeholderColor`, `textColor`, `tintColor`, and `backgroundColor` of the Search Bar.
 - `progressBar`: Customize the `foregroundColor` and `backgroundColor` of the progress bar.
 - `listStyle`: The style of the `List`. Defaults to `.insetGroupedListStyle`.
 - `navigationViewStyle`: The style of the `NavigationView`. Defaults to `.defaultNavigationViewStyle`.
 - `other`: Set the loading spinner size, welcome view, footer to be displayed at the bottom of the `List`, and error 404 page.
 */
public struct SupportOptions {
    
    /**
     Allows you to group documents with the same `tag` into the same section of the list. Each category may contain more than one `tag`.
     
     Leave as `nil` to display all documents regardless of their `tag`s.
     */
    public var categories: [Category]? = nil
    
    /**
     Customize the Navigation Bar's `title`, `titleColor`, `dismissButtonTitle`, `buttonTintColor`, and `backgroundColor`.
     
     `dismissButtonView` is set to nil here to avoid an "ambiguous init" compiler error. By default, `dismissButtonView` is already nil, so this doesn't affect anything.
     */
    public var navigationBar: NavigationBar = NavigationBar(dismissButtonView: nil)
    
    /**
     Customize the appearance of the Search Bar.
     
     Set to `nil` to not show a search bar.
     */
    public var searchBar: SearchBar? = SearchBar()
    
    /**
     Customize the `foregroundColor` and `backgroundColor` of the progress bar.
     */
    public var progressBar: ProgressBar = ProgressBar()
    
    /**
     The style of the `List`. Defaults to `.insetGroupedListStyle`.
     */
    public var listStyle: CustomListStyle = CustomListStyle.insetGroupedListStyle
    
    /**
     The style of the `NavigationView`. Defaults to `.defaultNavigationViewStyle`.
     */
    public var navigationViewStyle: CustomNavigationViewStyle = CustomNavigationViewStyle.defaultNavigationViewStyle
    
    /**
     Set the loading spinner size, welcome view, and an optional footer to be displayed at the bottom of the `List`.
     */
    public var other: Other = Other()
    
    /**
     Options for configuring SupportDocs.
     
     - parameter categories: Allows you to group documents with the same `tag` into the same section of the list. Each category may contain more than one `tag`.
     - parameter navigationBar: Customize the Navigation Bar's `title`, `titleColor`, `dismissButtonTitle`, `buttonTintColor`, and `backgroundColor`.
     - parameter searchBar: Customize the `placeholder`, `placeholderColor`, `textColor`, `tintColor`, `backgroundColor`, and `clearButtonMode` of the Search Bar.
     - parameter progressBar: Customize the `foregroundColor` and `backgroundColor` of the progress bar.
     - parameter listStyle: The style of the `List`. Defaults to `.insetGroupedListStyle`.
     - parameter navigationViewStyle: The style of the `NavigationView`. Defaults to `.defaultNavigationViewStyle`.
     - parameter other: Set the loading spinner size, welcome view, and an optional footer to be displayed at the bottom of the `List`.
     */
    public init(
        categories: [Category]? = nil,
        navigationBar: NavigationBar = NavigationBar(dismissButtonView: nil),
        searchBar: SearchBar? = SearchBar(),
        progressBar: ProgressBar = ProgressBar(),
        listStyle: CustomListStyle = CustomListStyle.insetGroupedListStyle,
        navigationViewStyle: CustomNavigationViewStyle = CustomNavigationViewStyle.defaultNavigationViewStyle,
        other: Other = Other()
    ) {
        self.categories = categories
        self.navigationBar = navigationBar
        self.searchBar = searchBar
        self.progressBar = progressBar
        self.listStyle = listStyle
        self.navigationViewStyle = navigationViewStyle
        self.other = other
    }
}
