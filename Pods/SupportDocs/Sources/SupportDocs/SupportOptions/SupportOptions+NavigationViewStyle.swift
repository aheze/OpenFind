//
//  SupportOptions+NavigationViewStyle.swift
//  SupportDocs
//
//  Created by Zheng on 11/7/20.
//

import SwiftUI

public extension SupportOptions {
    
    /**
     Enum wrapper for `NavigationViewStyle`.
     */
    enum CustomNavigationViewStyle {
        
        /**
         Translates into [DefaultNavigationViewStyle](https://developer.apple.com/documentation/swiftui/defaultnavigationviewstyle).
         */
        case defaultNavigationViewStyle
        
        /**
         Translates into [DoubleColumnNavigationViewStyle](https://developer.apple.com/documentation/swiftui/doublecolumnnavigationviewstyle).
         */
        case doubleColumnNavigationViewStyle
        
        /**
         Translates into [StackNavigationViewStyle](https://developer.apple.com/documentation/swiftui/stacknavigationviewstyle).
         */
        case stackNavigationViewStyle
        
    }
}

/**
 Custom extension to apply a `NavigationViewStyle`.
 
 SupportDocs uses a custom enum (`SupportOptions.CustomNavigationViewStyle`) that wraps SwiftUI's `NavigationViewStyle`. This is because `NavigationViewStyle` conforms to a generic, which makes it hard to store as a property inside `SupportOptions`.
 
 Also, if iOS 14 and using `SidebarListStyle` or  `DefaultListStyle` as the `ListStyle`, provide a workaround (there is a bug where there is a white background in portrait mode).
 */
internal extension NavigationView {
    @ViewBuilder
    func navigationViewStyle(for customNavigationViewStyle: SupportOptions.CustomNavigationViewStyle, customListStyle: SupportOptions.CustomListStyle) -> some View {
        
        if
            #available(iOS 14, *),
            customNavigationViewStyle != .stackNavigationViewStyle,
            (customListStyle == .defaultListStyle || customListStyle == .sidebarListStyle)
        {
            
            self.modifier(SidebarNavigationStyle()) /// If iOS 14 and using a `SidebarListStyle` for the list style (or `DefaultListStyle`, which is the same thing), apply the workaround.
        } else {
            
            /**
            If not, then no workaround is needed.
             */
            switch customNavigationViewStyle {
            case .defaultNavigationViewStyle:
                navigationViewStyle(DefaultNavigationViewStyle())
            case .doubleColumnNavigationViewStyle:
                navigationViewStyle(DoubleColumnNavigationViewStyle())
            case .stackNavigationViewStyle:
                navigationViewStyle(StackNavigationViewStyle())
            }
        }
    }
}

/**
 For working around a SwiftUI bug where a `listStyle` of `SidebarListStyle` does not work with `DoubleColumnNavigationViewStyle` in portrait.
 
 Source: [https://stackoverflow.com/a/64771576/14351818](https://stackoverflow.com/a/64771576/14351818).
 */
struct SidebarNavigationStyle: ViewModifier {
    @Environment(\.horizontalSizeClass) var horizontalSizeClass

    @ViewBuilder
    func body(content: Content) -> some View {
        if horizontalSizeClass == .compact {
            content.navigationViewStyle(StackNavigationViewStyle())
        } else {
            content.navigationViewStyle(DoubleColumnNavigationViewStyle())
        }
    }
}
