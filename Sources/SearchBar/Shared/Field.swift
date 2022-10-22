//
//  Field.swift
//  SearchBar
//
//  Created by Zheng on 10/14/21.
//

import UIKit

struct Field: Identifiable, Equatable {
    static func == (lhs: Field, rhs: Field) -> Bool {
        return lhs.value == rhs.value
    }
    
    let id = UUID()
    
    /// delete button deletes the entire field
    /// clear button is normal, shown when is editing no matter what
    var showingDeleteButton = false
    
    /// width of text label + side views, nothing more
    var fieldHuggingWidth = CGFloat(200)
    
    var configuration: SearchConfiguration
    
    var value: FieldValue {
        didSet {
            fieldHuggingWidth = getFieldHuggingWidth()
        }
    }
    
    var overrides: Overrides
    
    init(configuration: SearchConfiguration = .camera, value: FieldValue, overrides: Overrides = Overrides()) {
        self.configuration = configuration
        self.value = value
        self.overrides = overrides
        fieldHuggingWidth = getFieldHuggingWidth()
    }
    
    /// same as `Value`, but with an extra case: `addNew`
    enum FieldValue: Equatable {
//        static func == (lhs: Field.FieldValue, rhs: Field.FieldValue) -> Bool {
//            switch (lhs, rhs) {
//            case (.word(let lhsWord), .word(let rhsWord)):
//                return lhsWord == rhsWord
//            case (.list(let lhsList, originalText: ), .list(let rhsList)):
//                return lhsList == rhsList
//            default:
//                return false
//            }
//        }
        
        case word(Word)
        
        /// `originalText` is the text in the search bar before selecting a list
        case list(List, originalText: String)
        case addNew(Word) /// `String` for input text during add new -> full cell animation
        
        /// get the text of the value. "Untitled" if it's an untitled list.
        func getText() -> String {
            switch self {
            case .word(let word):
                return word.string
            case .list(let list, _):
                return list.displayedTitle
            case .addNew(let word):
                return word.string
            }
        }
        
        func getColor() -> UInt {
            switch self {
            case .word(let word):
                return word.color
            case .list(let list, _):
                return list.color
            case .addNew(let word):
                return word.color
            }
        }
        
        /// get original text before selecting a list.
        /// If change a list when already had a list, carry over the original text from the existing list.
        /// if just a word, return `word.string`
        func getOriginalText() -> String {
            switch self {
            case .word(let word):
                return word.string
            case .list(_, originalText: let originalText):
                return originalText
            case .addNew:
                return ""
            }
        }
    }
    
    struct Overrides {
        var selectedColor: UIColor?
        var alpha: CGFloat = 1
    }
}

struct FieldOffset {
    var fullWidth = CGFloat(0)
    var percentage = CGFloat(0)
    var shift = CGFloat(0) /// already multiplied by percentage
    var alpha = CGFloat(1) /// percent visible of add new
}

extension Field {
    private func getFieldHuggingWidth() -> CGFloat {
        if case .addNew(let word) = value, word.string.isEmpty {
            return configuration.addWordFieldHuggingWidth
        } else {
            let fieldText = value.getText()
            let finalText = fieldText.isEmpty ? configuration.addTextPlaceholder : fieldText
            let textWidth = finalText.width(withConstrainedHeight: 10, font: configuration.fieldFont)
            let leftPaddingWidth = configuration.fieldBaseViewLeftPadding
            let rightPaddingWidth = configuration.fieldBaseViewRightPadding
            return textWidth + leftPaddingWidth + rightPaddingWidth
        }
    }
}

open class FieldLayoutAttributes: UICollectionViewLayoutAttributes {
    var fullOrigin = CGFloat(0) /// origin when expanded
    var fullWidth = CGFloat(0) /// width when expanded
    var percentage = CGFloat(0) /// percentage shrunk
    var beingDeleted = false
    var configuration = SearchConfiguration()
    
    override open func copy(with zone: NSZone?) -> Any {
        let copy = super.copy(with: zone) as! FieldLayoutAttributes
        copy.fullOrigin = fullOrigin
        copy.fullWidth = fullWidth
        copy.percentage = percentage
        copy.beingDeleted = beingDeleted
        copy.configuration = configuration
        
        return copy
    }
    
    override open func isEqual(_ object: Any?) -> Bool {
        guard let attributes = object as? FieldLayoutAttributes else { return false }
        guard
            attributes.fullOrigin == fullOrigin,
            attributes.fullWidth == fullWidth,
            attributes.percentage == percentage,
            attributes.beingDeleted == beingDeleted,
            attributes.configuration == configuration
        else { return false }
    
        return super.isEqual(object)
    }
}
