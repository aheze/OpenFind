//
//  VC+AppLink.swift
//  Find
//
//  Created by A. Zheng (github.com/aheze) on 3/29/22.
//  Copyright © 2022 A. Zheng. All rights reserved.
//
    
import UIKit

extension ViewController {
    func handleIncomingURL(_ incomingURL: URL) {
        let string = incomingURL.absoluteString
        print("incomingURL: \(string)")
        
        if string.starts(with: "find://") {
            guard let search = string.components(separatedBy: "find://")[safe: 1] else { return }
            print("SCHEME: \(search)")
            
            let queries = search.splitUrlIntoQueries()
            
            /// query is a list
            if queries.contains(where: { $0.name == "type" && $0.value == "list" }) {
                let list = List.createFromURL(string: search)
            }
        } else if string.starts(with: "https://lists.getfind.app/list?") {
            guard let search = string.components(separatedBy: "https://lists.getfind.app/list?")[safe: 1] else { return }
            print("UNIVERSAL LINK: \(search)")
            let list = List.createFromURL(string: search)
        }
    }
}
