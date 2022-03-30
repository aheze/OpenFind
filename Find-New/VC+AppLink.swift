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
        
        if string.starts(with: "find://") {
            guard let search = string.components(separatedBy: "find://")[safe: 1] else { return }
            
            let queries = search.splitUrlIntoQueries()
            
            /// query is a list
            if queries.contains(where: { $0.name == "type" && $0.value == "list" }) {
                let list = List.createFromURL(string: search)
                startImportingList(list: list)
            }
        } else if string.starts(with: "https://lists.getfind.app/list?") {
            guard let search = string.components(separatedBy: "https://lists.getfind.app/list?")[safe: 1] else { return }
            let list = List.createFromURL(string: search)
            startImportingList(list: list)
        }
    }
    
    /// if view loaded, import list. If not, cache list
    func startImportingList(list: List) {
        if loaded {
            tabViewModel.changeTabState(newTab: .lists, animation: .animate)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                self.lists.viewController.importList(list: list)
            }
        } else {
            listToLoad = list
        }
    }
    
    /// load list after view loaded
    func importListIfNeeded() {
        if let listToLoad = listToLoad {
            importList(list: listToLoad)
        }
    }
    
    func importList(list: List) {
        tabViewModel.changeTabState(newTab: .lists, animation: .animate)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
            self.lists.viewController.importList(list: list)
        }
    }
}
