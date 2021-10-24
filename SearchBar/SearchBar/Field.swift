//
//  Field.swift
//  SearchBar
//
//  Created by Zheng on 10/14/21.
//

import UIKit

struct Field {
    
    init(value: Value) {
        self.value = value
        fieldHuggingWidth = self.getFieldHuggingWidth()
    }
    
    var value = Value.string("") {
        didSet {
            fieldHuggingWidth = self.getFieldHuggingWidth()
        }
    }
    
    /// delete button deletes the entire field
    /// clear button is normal, shown when is editing no matter what
    var showingDeleteButton = false
    
    
    /// width of text label + side views, nothing more
    var fieldHuggingWidth = CGFloat(200)
    
    
    enum Value {
        case string(String)
        case list(List)
        case addNew(AddNewState)
        
        func getText() -> String {
            switch self {
            case .string(let string):
                return string
            case .list(let list):
                return list.name
            case .addNew(_):
                return ""
            }
        }
    }
    
    private func getFieldHuggingWidth() -> CGFloat {
        if case Field.Value.addNew = self.value {
            print("is add new")
            return Constants.addWordFieldHuggingWidth
        } else {
            let fieldText = self.value.getText()
            let finalText = fieldText.isEmpty ? Constants.addTextPlaceholder : fieldText

            let textWidth = finalText.width(withConstrainedHeight: 10, font: Constants.fieldFont)
            let leftPaddingWidth = Constants.fieldBaseViewLeftPadding
            let rightPaddingWidth = Constants.fieldBaseViewRightPadding
            let textPadding = 2 * Constants.fieldTextSidePadding
            return textWidth + leftPaddingWidth + rightPaddingWidth + textPadding
        }
        
    }
}

enum AddNewState {
    case hugging
    case animatingToFull
}

struct List {
    var name = ""
    var desc = ""
    var contents = [String]()
    var iconImageName = ""
    var iconColorName = ""
    var dateCreated = Date()
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
    
    override open func copy(with zone: NSZone?) -> Any {
        let copy = super.copy(with: zone) as! FieldLayoutAttributes
        copy.fullOrigin = fullOrigin
        copy.fullWidth = fullWidth
        copy.percentage = percentage
        
        return copy
    }
    
    override open func isEqual(_ object: Any?) -> Bool {
        guard let attributes = object as? FieldLayoutAttributes else { return false }
        guard
            attributes.fullOrigin == fullOrigin,
            attributes.fullWidth == fullWidth,
            attributes.percentage == percentage
        else { return false }
    
        return super.isEqual(object)
    }
    
}
