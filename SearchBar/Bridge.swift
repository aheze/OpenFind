//
//  Bridge.swift
//  SearchBar
//
//  Created by Zheng on 10/14/21.
//

import UIKit

struct Bridge {
    static func makeViewController(searchViewModel: SearchViewModel) -> SearchViewController {
        let bundle = Bundle(identifier: "com.aheze.SearchBar")
        let storyboard = UIStoryboard(name: "SearchBar", bundle: bundle)
        let viewController = storyboard.instantiateViewController(identifier: "SearchViewController") { coder in
            SearchViewController(coder: coder, searchViewModel: searchViewModel)
        }
    
        return viewController
    }
}
