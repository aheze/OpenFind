//
//  ListsDetailWordCell.swift
//  Find
//
//  Created by A. Zheng (github.com/aheze) on 1/22/22.
//  Copyright © 2022 A. Zheng. All rights reserved.
//
    
import UIKit

class ListsDetailWordCell: UITableViewCell {
    @IBOutlet var stackView: UIStackView!
    @IBOutlet var stackViewTopC: NSLayoutConstraint!
    @IBOutlet var stackViewRightC: NSLayoutConstraint!
    @IBOutlet var stackViewLeftC: NSLayoutConstraint!
    @IBOutlet var stackViewBottomC: NSLayoutConstraint!
    
    @IBOutlet var leftView: ButtonView!
    @IBOutlet var leftSelectionIconView: SelectionIconView!
    
    @IBOutlet var centerView: UIView!
    @IBOutlet var textField: PaddedTextField!
    
    @IBOutlet var rightView: DragHandleView!
    @IBOutlet var rightDragHandleImageView: UIImageView!
    
    var leftViewTapped: (() -> Void)?

    override func layoutSubviews() {
        super.layoutSubviews()
        for subview in subviews {
            if let reorderControl = subview.subviews.first(where: { $0 is UIImageView } ) {
                reorderControl.isHidden = true
            }
        }
        contentView.frame = bounds
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        
        leftView.backgroundColor = .clear
        leftSelectionIconView.configuration = .large
        leftView.tapped = { [weak self] in
            self?.leftViewTapped?()
        }
        
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
