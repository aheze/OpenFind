//
//  List+Share.swift
//  Find
//
//  Created by A. Zheng (github.com/aheze) on 3/28/22.
//  Copyright © 2022 A. Zheng. All rights reserved.
//

import UIKit

struct Query {
    var name: String
    var value: String
}

extension List {
    static let titleQueryName = "title"
    static let descriptionQueryName = "description"
    static let iconQueryName = "icon"
    static let colorQueryName = "color"
    static let dateCreatedQueryName = "dateCreated"
    static let wordsQueryName = "words"
    
    func getURLString() -> String? {
        let allowedCharacters = CharacterSet(charactersIn: "!*'();:@&=+$,/?%#[] ").inverted
        
        guard let titleQuery = title.addingPercentEncoding(withAllowedCharacters: allowedCharacters) else { return nil }
        guard let descriptionQuery = description.addingPercentEncoding(withAllowedCharacters: allowedCharacters) else { return nil }
        guard let iconQuery = icon.addingPercentEncoding(withAllowedCharacters: allowedCharacters) else { return nil }
        guard let colorQuery = "\(color)".addingPercentEncoding(withAllowedCharacters: allowedCharacters) else { return nil }
        
        let dateFormatter = ISO8601DateFormatter()
        let dateString = dateFormatter.string(from: dateCreated)
        guard let dateCreatedQuery = dateString.addingPercentEncoding(withAllowedCharacters: allowedCharacters) else { return nil }
        
        let wordsEncoded = words.compactMap { $0.addingPercentEncoding(withAllowedCharacters: allowedCharacters) }
        let wordsQuery = wordsEncoded.joined(separator: ",")
        
        let queries: [Query] = [
            .init(name: List.titleQueryName, value: titleQuery),
            .init(name: List.descriptionQueryName, value: descriptionQuery),
            .init(name: List.iconQueryName, value: iconQuery),
            .init(name: List.colorQueryName, value: colorQuery),
            .init(name: List.dateCreatedQueryName, value: dateCreatedQuery),
            .init(name: List.wordsQueryName, value: wordsQuery)
        ]
        var queriesString = ""
        for (index, query) in queries.enumerated() {
            let name: String
            if index == 0 {
                name = "?\(query.name)="
            } else {
                name = "&\(query.name)="
            }
            let value = query.value
            let queryString = name + value
            queriesString.append(queryString)
        }
        
//        let baseString = "https://lists.getfind.app/list"
        let baseString = "file:///Users/aheze/Desktop/Code/Web/FindLists/list.html"
        let urlString = baseString + queriesString
        return urlString
    }
    
    func getURL() -> URL? {
        if
            let string = getURLString(),
            let url = URL(string: string)
        {
            return url
        }
        
        return nil
    }
}
