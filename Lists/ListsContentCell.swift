//
//  ListsContentCell.swift
//  Find
//
//  Created by A. Zheng (github.com/aheze) on 1/8/22.
//  Copyright © 2022 A. Zheng. All rights reserved.
//
    
import UIKit

class ListsContentCell: UICollectionViewCell {
    @IBOutlet var headerView: ButtonView!
    
    @IBOutlet var headerViewHeightC: NSLayoutConstraint!
    @IBOutlet var headerStackView: UIStackView!
    
    @IBOutlet var headerStackViewTopC: NSLayoutConstraint!
    @IBOutlet var headerStackViewRightC: NSLayoutConstraint!
    @IBOutlet var headerStackViewBottomC: NSLayoutConstraint!
    @IBOutlet var headerStackViewLeftC: NSLayoutConstraint!
    
    @IBOutlet var headerLeftView: UIView!
    @IBOutlet var headerLeftViewWidthC: NSLayoutConstraint!
    @IBOutlet var headerImageView: UIImageView!
    @IBOutlet var headerSelectionIconView: SelectionIconView!
    
    @IBOutlet var headerTitleLabel: UILabel!
    @IBOutlet var headerDescriptionLabel: UILabel!

    @IBOutlet var containerView: UIView!
    @IBOutlet var containerButtonView: ButtonView!
    @IBOutlet var chipsContainerView: UIView!
    
    @IBOutlet var chipsContainerViewTopC: NSLayoutConstraint!
    @IBOutlet var chipsContainerViewRightC: NSLayoutConstraint!
    @IBOutlet var chipsContainerViewBottomC: NSLayoutConstraint!
    @IBOutlet var chipsContainerViewLeftC: NSLayoutConstraint!
    
    var tapped: (() -> Void)?
    override func awakeFromNib() {
        super.awakeFromNib()
        let c = ListsCellConstants.self
        
        /// allow button view to be pressed
        headerStackView.isUserInteractionEnabled = false

        headerStackView.backgroundColor = .clear
        headerLeftView.backgroundColor = .clear
        chipsContainerView.backgroundColor = .clear
        
        headerLeftViewWidthC.constant = c.headerLeftWidth
        headerSelectionIconView.configuration = .listsSelection
        
        headerImageView.contentMode = .center
        headerImageView.preferredSymbolConfiguration = .init(font: c.headerDescriptionFont)
        headerTitleLabel.font = c.headerTitleFont
        headerDescriptionLabel.font = c.headerDescriptionFont
        
        headerViewHeightC.constant = c.headerTitleFont.lineHeight
            + c.headerEdgeInsets.top
            + c.headerEdgeInsets.bottom
        
        headerStackViewTopC.constant = c.headerEdgeInsets.top
        headerStackViewRightC.constant = c.headerEdgeInsets.right
        headerStackViewBottomC.constant = c.headerEdgeInsets.bottom
        headerStackViewLeftC.constant = c.headerEdgeInsets.left
        
        chipsContainerViewTopC.constant = c.contentEdgeInsets.top
        chipsContainerViewRightC.constant = c.contentEdgeInsets.right
        chipsContainerViewBottomC.constant = c.contentEdgeInsets.bottom
        chipsContainerViewLeftC.constant = c.contentEdgeInsets.left
        
        headerStackView.setCustomSpacing(c.headerImageRightPadding, after: headerImageView)
        headerStackView.spacing = c.headerTextSpacing
        
        headerView.shouldFade = false
        headerView.tapped = { [weak self] in
            self?.tapped?()
        }
        headerView.touchedDown = { [weak self] down in
            self?.touchedDown(down)
        }
        
        containerButtonView.shouldFade = false
        containerButtonView.tapped = { [weak self] in
            self?.tapped?()
        }
        containerButtonView.touchedDown = { [weak self] down in
            self?.touchedDown(down)
        }
    }
    
    func touchedDown(_ down: Bool) {
        if down {
            UIView.animate(withDuration: 0.2) {
                self.alpha = 0.8
            }
        } else {
            UIView.animate(withDuration: 0.2) {
                self.alpha = 1
            }
        }
    }
}

class ListChipView: UIView {
    var type = ListFrame.ChipType.word
    init(type: ListFrame.ChipType) {
        self.type = type
        super.init(frame: .zero)
        commonInit()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    var tapped: (() -> Void)?
    var color = UIColor.systemBlue
    
    lazy var buttonView: UIButton = {
        let button = ButtonView()
        button.frame = bounds
        button.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        button.layer.cornerRadius = ListsCellConstants.chipCornerRadius
        button.clipsToBounds = true
        addSubview(button)

        button.tapped = { [weak self] in
            self?.tapped?()
        }
        return button
    }()
    
    lazy var backgroundView: UIView = {
        let backgroundView = UIView()
        backgroundView.frame = bounds
        backgroundView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        buttonView.addSubview(backgroundView)
        backgroundView.isUserInteractionEnabled = false
        return backgroundView
    }()

    lazy var label: UILabel = {
        let label = UILabel()
        label.frame = bounds
        label.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        label.font = ListsCellConstants.chipFont
        label.textAlignment = .center
        buttonView.addSubview(label)
        label.isUserInteractionEnabled = false
        return label
    }()
    
    func setColors() {
        if color.isLight, traitCollection.userInterfaceStyle == .light {
            let adjustedTextColor = color.toColor(.black, percentage: 0.6)
            label.textColor = adjustedTextColor
        } else if traitCollection.userInterfaceStyle == .dark {
            let adjustedTextColor = color.toColor(.white, percentage: 0.8)
            label.textColor = adjustedTextColor
        } else {
            label.textColor = color
        }
    }
    
    private func commonInit() {
        backgroundColor = .clear
        _ = buttonView
        _ = backgroundView
        _ = label
        
        switch type {
        case .word:
            let interaction = UIContextMenuInteraction(delegate: self)
            buttonView.addInteraction(interaction)
        case .wordsLeft:
            break
        case .addWords:
            break
        }
    }
}

extension ListChipView: UIContextMenuInteractionDelegate {
    func contextMenuInteraction(_ interaction: UIContextMenuInteraction, configurationForMenuAtLocation location: CGPoint) -> UIContextMenuConfiguration? {
        return UIContextMenuConfiguration(identifier: nil, previewProvider: nil, actionProvider: { suggestedActions in
            self.makeContextMenu()
        })
    }
    
    func makeContextMenu() -> UIMenu {
        // Create a UIAction for sharing
        let share = UIAction(title: "Copy", image: UIImage(systemName: "doc.on.doc")) { action in
            UIPasteboard.general.string = self.label.text ?? ""
        }

        // Create and return a UIMenu with the share action
        return UIMenu(title: "", children: [share])
    }
}
