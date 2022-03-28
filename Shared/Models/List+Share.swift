//
//  List+Share.swift
//  Find
//
//  Created by A. Zheng (github.com/aheze) on 3/28/22.
//  Copyright © 2022 A. Zheng. All rights reserved.
//

import UIKit

extension List {
    func getURL() {
//        let name = "\(name)"/
        var components = URLComponents()
        components.scheme = "https"
        components.host = "lists.github.com"
        components.path = "/data/"
//        components.queryItems = [
//            URLQueryItem(name: "title", value: name),
//            URLQueryItem(name: "sort", value: sorting.rawValue)
//        ]

        
    }
}
