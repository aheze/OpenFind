//
//  SupportDocsView+LoadData.swift
//  SupportDocsSwiftUI
//
//  Created by Zheng on 10/31/20.
//

import SwiftUI
import UIKit

internal extension SupportDocsView {
    
    /**
     Load the JSON.
     */
    func loadData() {
        let request = URLRequest(url: dataSourceURL)
        URLSession.shared.dataTask(with: request) { data, response, error in
            
            guard
                let data = data,
                let supportDocuments = try? JSONDecoder().decode([JSONSupportDocument].self, from: data)
            else {
                /**
                 If something went wrong, still hide the loading spinner. Only the footer will be displayed because the `ForEach(sections)` will be empty.
                 */
                withAnimation(.linear(duration: 0.5)) {
                    self.isDownloadingJSON = false
                }
                return
            }
            
            DispatchQueue.main.async {
                self.documents = supportDocuments
                
                /**
                 This will be what the List gets it data from.
                 */
                var sections = [SupportSection]()
                
                /**
                 If you configured categories, they will be sorted here.
                 */
                if let categories = options.categories {
                    for category in categories {
                        
                        /**
                         For each `category`, see which documents contain the same `tags`.
                         */
                        var containingSupportItems = [SupportItem]()
                        
                        for tag in category.tags { /// Loop through each of your categories.
                            for document in documents { /// Loop through every document in the JSON.
                                
                                /**
                                 If the document's `tags` contains this `tag` in the category, append it to the `containingSupportItems`.
                                 */
                                if document.tags.contains(tag) {
                                    
                                    /**
                                     Prevent duplicate documents in each section -- only append it if its `URL` is unique.
                                     */
                                    if !containingSupportItems.contains(where: { item in item.url == document.url }) {
                                        let supportItem = SupportItem(title: document.title, url: document.url)
                                        containingSupportItems.append(supportItem)
                                    }
                                }
                            }
                        }
                        
                        /**
                         After going through all the documents and seeing which ones belong to this `category` (by comparing their `tags`), convert it into a `SupportSection`.
                         */
                        let section = SupportSection(
                            name: category.displayName,
                            color: category.displayColor,
                            supportItems: containingSupportItems
                        )
                        sections.append(section)
                    }
                } else { /// If you did not configure categories.
                    
                    /**
                     Just append every document to one section.
                     */
                    var containingSupportItems = [SupportItem]()
                    for document in documents {
                        let supportItem = SupportItem(title: document.title, url: document.url)
                        containingSupportItems.append(supportItem)
                    }
                    sections = [
                        SupportSection(
                            name: "", /// This doesn't matter because there's only one section, no need to add a header.
                            color: UIColor.label, /// Also doesn't matter.
                            supportItems: containingSupportItems
                        )
                    ]
                }
                
                /**
                 Populate `self.sections` (what the List gets it data from) with `sections`.
                 */
                self.sections = sections
                
                /**
                 Hide the loading spinner and show the List.
                 */
                withAnimation(.linear(duration: 0.5)) {
                    self.isDownloadingJSON = false
                }
            }
        }.resume()
    }
}
