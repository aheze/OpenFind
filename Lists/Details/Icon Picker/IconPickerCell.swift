//
//  IconPickerCell.swift
//  Find
//
//  Created by A. Zheng (github.com/aheze) on 1/25/22.
//  Copyright © 2022 A. Zheng. All rights reserved.
//
    

import UIKit

class IconPickerHeader: UICollectionReusableView {
    @IBOutlet weak var label: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        label.textColor = .secondaryLabel
        backgroundColor = .clear
    }
}
class IconPickerCell: UICollectionViewCell {
    
    @IBOutlet weak var buttonView: ButtonView!
    @IBOutlet weak var imageView: UIImageView!
    
    var tapped: (() -> Void)?
    override func awakeFromNib() {
        super.awakeFromNib()
        
        buttonView.tapped = { [weak self] in
            self?.tapped?()
        }
        
        imageView.tintColor = .label
        imageView.contentMode = .center
        imageView.preferredSymbolConfiguration = .init(font: IconPickerConstants.iconFont)
    }
}
