//
//  VC+AppLink.swift
//  Find
//
//  Created by A. Zheng (github.com/aheze) on 3/29/22.
//  Copyright © 2022 A. Zheng. All rights reserved.
//
    
import UIKit

extension InitialViewController {
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
        if properties.viewControllerLoaded {
            guard let viewController = viewController else { return }
            viewController.tabViewModel.statusBarStyle = .default
            importList(list: list)
        } else {
            properties.listToLoad = list
        }
    }
    
    /// load list after view loaded
    func importListIfNeeded() {
        if let listToLoad = properties.listToLoad {
            importList(list: listToLoad)
        }
    }
    
    func importList(list: List) {
        viewController?.tabViewModel.changeTabState(newTab: .lists, animation: .animate)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
            self.viewController?.lists.viewController.importList(list: list)
        }
    }
}
