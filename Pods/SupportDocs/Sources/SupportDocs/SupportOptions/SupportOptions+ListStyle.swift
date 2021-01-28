//
//  SupportOptions+ListStyle.swift
//  SupportDocs
//
//  Created by Zheng on 11/1/20.
//

import SwiftUI

public extension SupportOptions {
    
    /**
     Enum wrapper for `ListStyle`.
     */
    enum CustomListStyle {
        
        /**
         Translates into [DefaultListStyle](https://developer.apple.com/documentation/swiftui/defaultliststyle).
         */
        case defaultListStyle
        
        /**
         Translates into [PlainListStyle](https://developer.apple.com/documentation/swiftui/plainliststyle).
         */
        case plainListStyle
        
        /**
         Translates into [GroupedListStyle](https://developer.apple.com/documentation/swiftui/groupedliststyle).
         */
        case groupedListStyle
        
        /**
          **iOS 14.0 and above only.** Otherwise, defaults to `defaultListStyle`.
         
          Translates into [InsetGroupedListStyle](https://developer.apple.com/documentation/swiftui/insetgroupedliststyle).
         */
        case insetGroupedListStyle
        
        /**
          **iOS 14.0 and above only.** Otherwise, defaults to `defaultListStyle`.
         
          Translates into [InsetListStyle](https://developer.apple.com/documentation/swiftui/insetliststyle).
         */
        case insetListStyle
        
        /**
          **iOS 14.0 and above only.** Otherwise, defaults to `defaultListStyle`.
         
          Translates into [SidebarListStyle](https://developer.apple.com/documentation/swiftui/sidebarliststyle).
         */
        case sidebarListStyle
        
    }
}

/**
 Custom extension to apply a `ListStyle`.
 
 SupportDocs uses a custom enum (`SupportOptions.CustomListStyle`) that wraps SwiftUI's `ListStyle`. This is because `ListStyle` conforms to a generic, which makes it hard to store as a property inside `SupportOptions`.
 */
internal extension List {
    @ViewBuilder
    func listStyle(for customListStyle: SupportOptions.CustomListStyle) -> some View {
        switch customListStyle {
        case .defaultListStyle:
            listStyle(DefaultListStyle())
        case .plainListStyle:
            listStyle(PlainListStyle())
        case .groupedListStyle:
            listStyle(GroupedListStyle())
        case .insetGroupedListStyle:
            if #available(iOS 14.0, *) {
                listStyle(InsetGroupedListStyle())
            } else {
                listStyle(DefaultListStyle())
            }
        case .insetListStyle:
            if #available(iOS 14.0, *) {
                listStyle(InsetListStyle())
            } else {
                listStyle(DefaultListStyle())
            }
        case .sidebarListStyle:
            if #available(iOS 14.0, *) {
                listStyle(SidebarListStyle())
            } else {
                listStyle(DefaultListStyle())
            }
        }
    }
}
