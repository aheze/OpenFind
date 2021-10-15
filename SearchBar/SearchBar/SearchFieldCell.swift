//
//  SearchFieldCell.swift
//  SearchBar
//
//  Created by Zheng on 10/14/21.
//

import UIKit

open class FieldLayoutAttributes: UICollectionViewLayoutAttributes {
    
    open var transitionProgress: CGFloat = 0.0
    
    override open func copy(with zone: NSZone?) -> Any {
        let copy = super.copy(with: zone) as! FieldLayoutAttributes
        copy.transitionProgress = transitionProgress
        
        return copy
    }
    
    override open func isEqual(_ object: Any?) -> Bool {
        guard let attributes = object as? FieldLayoutAttributes else { return false }
        guard
            attributes.transitionProgress == transitionProgress
        else { return false }
    
        return super.isEqual(object)
    }
    
}

class SearchFieldCell: UICollectionViewCell {
    @IBOutlet weak var textField: UITextField!
    
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        print("Awake!")
    }
    
    override func apply(_ layoutAttributes: UICollectionViewLayoutAttributes) {
        super.apply(layoutAttributes)
        print("Applying attributes")
        if let attributes = layoutAttributes as? FieldLayoutAttributes {
            
            print("caster attributes")
            
        }
    }
}
