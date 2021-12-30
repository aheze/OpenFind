//
//  Field.swift
//  SearchBar
//
//  Created by Zheng on 10/14/21.
//

import UIKit

struct Field: Identifiable {
    
    let id = UUID()
    
    /// delete button deletes the entire field
    /// clear button is normal, shown when is editing no matter what
    var showingDeleteButton = false
    
    /// width of text label + side views, nothing more
    var fieldHuggingWidth = CGFloat(200)
    
    var value: Value {
        didSet {
            fieldHuggingWidth = getFieldHuggingWidth()
        }
    }
    
    var attributes: Attributes
    
    init(value: Value, attributes: Attributes) {
        self.value = value
        self.attributes = attributes
        fieldHuggingWidth = getFieldHuggingWidth()
    }
    
    enum Value {
        case string(String)
        case list(List)
        case addNew(String) /// `String` for input text during add new -> full cell animation
        
        func getText() -> String {
            switch self {
            case .string(let string):
                return string
            case .list(let list):
                return list.name
            case .addNew(let string):
                return string
            }
        }
    }
    
    struct Attributes {
        var defaultColor: UIColor
        var selectedColor: UIColor?
        var alpha: CGFloat = 1
    }
    
    private func getFieldHuggingWidth() -> CGFloat {
        if case .addNew(let string) = value, string.isEmpty {
            return SearchConstants.addWordFieldHuggingWidth
        } else {
            let fieldText = value.getText()
            let finalText = fieldText.isEmpty ? SearchConstants.addTextPlaceholder : fieldText
            let textWidth = finalText.width(withConstrainedHeight: 10, font: SearchConstants.fieldFont)
            let leftPaddingWidth = SearchConstants.fieldBaseViewLeftPadding
            let rightPaddingWidth = SearchConstants.fieldBaseViewRightPadding
            let textPadding = 2 * SearchConstants.fieldTextSidePadding
            return textWidth + leftPaddingWidth + rightPaddingWidth + textPadding
        }
    }
}

struct FieldOffset {
    var fullWidth = CGFloat(0)
    var percentage = CGFloat(0)
    var shift = CGFloat(0) /// already multiplied by percentage
    var alpha = CGFloat(1) /// percent visible of add new
}

open class FieldLayoutAttributes: UICollectionViewLayoutAttributes {
    var fullOrigin = CGFloat(0) /// origin when expanded
    var fullWidth = CGFloat(0) /// width when expanded
    var percentage = CGFloat(0) /// percentage shrunk
    var beingDeleted = false
    
    override open func copy(with zone: NSZone?) -> Any {
        let copy = super.copy(with: zone) as! FieldLayoutAttributes
        copy.fullOrigin = fullOrigin
        copy.fullWidth = fullWidth
        copy.percentage = percentage
        copy.beingDeleted = beingDeleted
        
        return copy
    }
    
    override open func isEqual(_ object: Any?) -> Bool {
        guard let attributes = object as? FieldLayoutAttributes else { return false }
        guard
            attributes.fullOrigin == fullOrigin,
            attributes.fullWidth == fullWidth,
            attributes.percentage == percentage,
            attributes.beingDeleted == beingDeleted
        else { return false }
    
        return super.isEqual(object)
    }
}
