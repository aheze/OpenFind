//
//  ListsContentCell.swift
//  Find
//
//  Created by A. Zheng (github.com/aheze) on 1/8/22.
//  Copyright © 2022 A. Zheng. All rights reserved.
//
    
import UIKit

class ListsContentCell: UICollectionViewCell {
    var tapped: (() -> Void)?
    @IBOutlet weak var view: ListsContentView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        view.tapped = { [weak self] in
            self?.tapped?()
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
