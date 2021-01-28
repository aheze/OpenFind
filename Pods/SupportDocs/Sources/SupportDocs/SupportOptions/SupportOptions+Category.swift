//
//  SupportOptions+Category.swift
//  SupportDocs
//
//  Created by Zheng on 10/25/20.
//

import UIKit

public extension SupportOptions {
    
    /**
     A group of `Documents` to be displayed as a section inside the `List`.
     
     Before you create a `Category`, you must be using the `tag` property inside the MarkDown file on GitHub. Assign an array of `Strings` like this:
     ```
     title: "How to add a friend"
     tags: friending, generalHelp
     ```
     The GitHub action will automatically parse your `tag`s. Then, in your app, simply make a new `Category` instance and pass it into `options.categories`.
     ```
     let options: SupportOptions = SupportOptions(
         categories: [
             .init(tag: "friending", displayName: "Friends", displayColor: UIColor.label)
         ]
     )
     ```
     You are allowed to have more than one `tag` for each Markdown file, and each `category` can include more than one tag.
     */
    struct Category {
        
        /**
         A group of `Documents` to be displayed as a section inside the `List`
         
         - parameter tags: Determines which `tag`s this category should include.
         - parameter displayName: What to display in the header of the section, in the `List`.
         - parameter displayColor: The color of the row in the `List`.
         */
        public init(
            tags: [String],
            displayName: String,
            displayColor: UIColor = UIColor.label
        ) {
            self.tags = tags
            self.displayName = displayName
            self.displayColor = displayColor
        }
        
        /**
         Determines which `tag`s this category should include.
         
         You may include multiple `tag`s, like so:
         ```
         let options: SupportOptions = SupportOptions(
             categories: [
                 .init(tags: ["friending", "help", "betaHelp"], displayName: "Miscellaneous", displayColor: UIColor.label)
             ]
         )
         ```
         Each `category` gets its own section in the `List`.
         */
        public var tags: [String]
        
        /**
         What to display in the header of the section, in the `List`.
         */
        public var displayName: String
        
        /**
         The color of the row in the `List`.
         */
        public var displayColor: UIColor = UIColor.label
        
    }
}

public extension SupportOptions.Category {
    
    /**
     A group of `Documents` to be displayed as a section inside the `List`
     
     - parameter tag: Determines which `tag` this category's documents should have.
     - parameter displayName: What to display in the header of the section, in the `List`.
     - parameter displayColor: The color of the row in the `List`.
     
     This is an overload of the main initializer, `init(tags:displayName:displayColor:)`, allowing you to initialize a category with only 1 tag.
     */
    init(
        tag: String,
        displayName: String,
        displayColor: UIColor = UIColor.label
    ) {
        self.tags = [tag]
        self.displayName = displayName
        self.displayColor = displayColor
    }
}
