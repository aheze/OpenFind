//
//  ListsDetailWordCell.swift
//  Find
//
//  Created by A. Zheng (github.com/aheze) on 1/22/22.
//  Copyright © 2022 A. Zheng. All rights reserved.
//
    

import UIKit

class ListsDetailWordCell: UITableViewCell {
    
    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var stackViewTopC: NSLayoutConstraint!
    @IBOutlet weak var stackViewRightC: NSLayoutConstraint!
    @IBOutlet weak var stackViewLeftC: NSLayoutConstraint!
    @IBOutlet weak var stackViewBottomC: NSLayoutConstraint!
    
    @IBOutlet weak var leftView: ButtonView!
    @IBOutlet weak var leftSelectionIconView: SelectionIconView!
    
    @IBOutlet weak var centerView: UIView!
    @IBOutlet weak var textField: PaddedTextField!
    
    @IBOutlet weak var rightView: DragHandleView!
    @IBOutlet weak var rightDragHandleImageView: UIImageView!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        rightDragHandleImageView.contentMode = .center
        rightDragHandleImageView.preferredSymbolConfiguration = .init(font: .preferredFont(forTextStyle: .title3))
        rightDragHandleImageView.image = UIImage(systemName: "line.3.horizontal")
        
        textField.font = ListsDetailConstants.listRowWordFont
        
        stackViewTopC.constant = ListsDetailConstants.listRowContentEdgeInsets.top
        stackViewRightC.constant = ListsDetailConstants.listRowContentEdgeInsets.right
        stackViewLeftC.constant = ListsDetailConstants.listRowContentEdgeInsets.left
        stackViewBottomC.constant = ListsDetailConstants.listRowContentEdgeInsets.bottom
        
        centerView.clipsToBounds = true
        centerView.layer.cornerRadius = ListsDetailConstants.listRowWordCornerRadius
        centerView.backgroundColor = ListsDetailConstants.listRowWordBackgroundColor
        
        textField.padding = ListsDetailConstants.listRowWordEdgeInsets
    }
}
