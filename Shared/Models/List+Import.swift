//
//  List+Import.swift
//  Find
//
//  Created by A. Zheng (github.com/aheze) on 3/29/22.
//  Copyright © 2022 A. Zheng. All rights reserved.
//

import UIKit

extension String {
    func splitUrlIntoQueries() -> [Query] {
        let parameters = self.components(separatedBy: "&")
        var queries = [Query]()
        for parameter in parameters {
            let parameterSplit = parameter.components(separatedBy: "=")
            if
                let name = parameterSplit[safe: 0],
                let value = parameterSplit[safe: 1]
            {
                let query = Query(name: name, value: value)
                queries.append(query)
            }
        }

        return queries
    }

    func decodeQueryValue() -> String? {
        if let value = self.removingPercentEncoding {
            return value
        }
        return nil
    }
}

extension List {
    static func createFromURL(string: String) -> List {
        var list = List()
        let queries = string.splitUrlIntoQueries()

        if
            let titleQuery = queries.first(where: { $0.name == List.titleQueryName }),
            let title = titleQuery.value.decodeQueryValue()
        {
            list.title = title
        }

        if
            let descriptionQuery = queries.first(where: { $0.name == List.descriptionQueryName }),
            let description = descriptionQuery.value.decodeQueryValue()
        {
            list.description = description
        }

        if
            let iconQuery = queries.first(where: { $0.name == List.iconQueryName }),
            let icon = iconQuery.value.decodeQueryValue()
        {
            list.icon = icon
        }

        if
            let colorQuery = queries.first(where: { $0.name == List.colorQueryName }),
            let color = colorQuery.value.decodeQueryValue()
        {
            /// must be 0 or greater, otherwise `fatal error: Negative value is not representable`
            if let int = Int(color), int >= 0 {
                list.color = UInt(int)
            }
        }

        if
            let dateCreatedQuery = queries.first(where: { $0.name == List.dateCreatedQueryName }),
            let dateCreated = dateCreatedQuery.value.decodeQueryValue()
        {
            print("dateCreated string: \(dateCreated)")
            let dateFormatter = ISO8601DateFormatter()
            if let date = dateFormatter.date(from: dateCreated) {
                print("date: \(date)")
                list.dateCreated = date
            }
        }

        if let wordsQuery = queries.first(where: { $0.name == List.wordsQueryName }) {
            var words = [String]()
            let wordsEncoded = wordsQuery.value.components(separatedBy: List.wordsSeparator)
            for wordEncoded in wordsEncoded {
                if let word = wordEncoded.decodeQueryValue() {
                    words.append(word)
                }
            }

            list.words = words
        }
        
        print("List made! \(list)")
        return list
    }
}
