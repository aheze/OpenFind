//
//  List+Share.swift
//  Find
//
//  Created by A. Zheng (github.com/aheze) on 3/28/22.
//  Copyright © 2022 A. Zheng. All rights reserved.
//

import LinkPresentation
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
    static let wordsSeparator = ","
    static let allowedCharacters = CharacterSet(charactersIn: "!*'();:@&=+$,/?%#[] ").inverted

    func getURLString() -> String? {
        let allowedCharacters = List.allowedCharacters
        guard let titleQuery = title.addingPercentEncoding(withAllowedCharacters: allowedCharacters) else { return nil }
        guard let descriptionQuery = description.addingPercentEncoding(withAllowedCharacters: allowedCharacters) else { return nil }
        guard let iconQuery = icon.addingPercentEncoding(withAllowedCharacters: allowedCharacters) else { return nil }
        guard let colorQuery = "\(color)".addingPercentEncoding(withAllowedCharacters: allowedCharacters) else { return nil }

        let dateFormatter = ISO8601DateFormatter()
        let dateString = dateFormatter.string(from: dateCreated)
        guard let dateCreatedQuery = dateString.addingPercentEncoding(withAllowedCharacters: allowedCharacters) else { return nil }

        let wordsEncoded = words.compactMap { $0.addingPercentEncoding(withAllowedCharacters: allowedCharacters) }
        let wordsQuery = wordsEncoded.joined(separator: List.wordsSeparator)

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

        let baseString = "https://lists.getfind.app/list"
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

class ListsSharingDataSource: NSObject, UIActivityItemSource {
    let lists: [List]

    init(lists: [List]) {
        self.lists = lists
        super.init()
    }

    func activityViewControllerPlaceholderItem(_ activityViewController: UIActivityViewController) -> Any {
        return ""
    }

    func activityViewController(_ activityViewController: UIActivityViewController, itemForActivityType activityType: UIActivity.ActivityType?) -> Any? {
        return nil
    }

    func activityViewControllerLinkMetadata(_ activityViewController: UIActivityViewController) -> LPLinkMetadata? {
        guard let image = UIImage(systemName: "square.and.arrow.up") else { return nil }
        let imageProvider = NSItemProvider(object: image)
        let metadata = LPLinkMetadata()
        metadata.imageProvider = imageProvider
        
        let titles = lists.map { $0.displayedTitle }
        let sentence = titles.sentence
        metadata.title = sentence
        if lists.count == 1 {
            metadata.url = URL(string: "\(lists.count) list - lists.getfind.app")
        } else {
            metadata.url = URL(string: "\(lists.count) lists - lists.getfind.app")
        }
        
        return metadata
    }
}
