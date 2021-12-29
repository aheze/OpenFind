
//
//  Carte.swift
//  Carte
//
//  Created by Suyeol Jeon on 06/06/2017.
//

import Foundation

public enum Carte {
    public static var infoDictionary: [String: Any]? = Bundle.main.infoDictionary {
        didSet {
            _items = nil
        }
    }

    private static var _items: [CarteItem]?
    public static var items: [CarteItem] {
        if let items = _items {
            return items
        }
        let items = Carte.appendingCarte(to: Carte.items(from: Carte.infoDictionary) ?? [])
        _items = items
        return items
    }

    static func items(from infoDictionary: [String: Any]?) -> [CarteItem]? {
        return (infoDictionary?["Carte"] as? [[String: Any]])?
            .compactMap { dict -> CarteItem? in
                guard let name = dict["name"] as? String else { return nil }
                var item = CarteItem(name: name)
                item.licenseText = (dict["text"] as? String)
                    .flatMap { Data(base64Encoded: $0) }
                    .flatMap { String(data: $0, encoding: .utf8) }
                return item
            }
            .sorted { $0.name < $1.name }
    }

    static func appendingCarte(to items: [CarteItem]) -> [CarteItem] {
        guard items.lazy.filter({ $0.name == "Carte" }).first == nil else { return items }
        var item = CarteItem(name: "Carte")
        item.licenseText = [
            "The MIT License (MIT)",
            "",
            "Copyright (c) 2015 Suyeol Jeon (xoul.kr)",
            "Permission is hereby granted, free of charge, to any person obtaining a copy",
            "of this software and associated documentation files (the \"Software\"), to deal",
            "in the Software without restriction, including without limitation the rights",
            "to use, copy, modify, merge, publish, distribute, sublicense, and/or sell",
            "copies of the Software, and to permit persons to whom the Software is",
            "furnished to do so, subject to the following conditions:",
            "",
            "The above copyright notice and this permission notice shall be included in all",
            "copies or substantial portions of the Software.",
            "",
            "THE SOFTWARE IS PROVIDED \"AS IS\", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR",
            "IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,",
            "FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE",
            "AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER",
            "LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,",
            "OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE",
            "SOFTWARE."
        ].joined(separator: "\n")
        return (items + [item]).sorted { $0.name < $1.name }
    }
}
