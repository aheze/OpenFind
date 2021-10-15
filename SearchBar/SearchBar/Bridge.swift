//
//  Bridge.swift
//  SearchBar
//
//  Created by Zheng on 10/14/21.
//

import UIKit

public struct Bridge {
    public static var viewController: (() -> SearchViewController) = {
        let bundle = Bundle(identifier: "com.aheze.SearchBar")
        let storyboard = UIStoryboard(name: "SearchBar", bundle: bundle)
        let viewController = storyboard.instantiateViewController(withIdentifier: "SearchViewController") as! SearchViewController
            
        return viewController
    }
}
