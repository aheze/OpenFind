//
//  ListToolBar.swift
//  Find
//
//  Created by Zheng on 3/9/20.
//  Copyright © 2020 Andrew. All rights reserved.
//

import UIKit

enum ToolbarButtonType {
    case newMatch
    case done
}
enum ListToolbarLocation {
    case inCamera
    case inPhotos
}

protocol ToolbarButtonPressed: class {
    func buttonPressed(button: ToolbarButtonType)
}
protocol SelectedList: class {
    func addList(list: EditableFindList)
}
protocol StartedEditing: class {
    func startedEditing(start: Bool)
}
class ListToolBar: UIView, InjectLists {

    var location = ListToolbarLocation.inPhotos
    
    @IBOutlet weak var backgroundTapView: UIView!
    
    @IBOutlet weak var flowLayout: UICollectionViewFlowLayout!
    var editableListCategories = [EditableFindList]()
    
    weak var pressedButton: ToolbarButtonPressed?
    weak var selectedList: SelectedList?
    weak var startedEditing: StartedEditing?
    
    @IBOutlet var contentView: UIView!
    @IBOutlet weak var visualBaseView: UIVisualEffectView!
    
    @IBOutlet weak var newMatchButton: UIButton!
    @IBOutlet weak var doneButton: UIButton!
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    @IBAction func newMatchPressed(_ sender: Any) {
        pressedButton?.buttonPressed(button: .newMatch)
    }
    
    @IBAction func donePressed(_ sender: Any) {
        pressedButton?.buttonPressed(button: .done)
    }
    
    func resetWithLists(lists: [EditableFindList]) {
        editableListCategories = lists
        collectionView.reloadData()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    init() {
        super.init(frame: .zero)
        setup()
    }
    private func setup() {
        clipsToBounds = true
        
        Bundle.main.loadNibNamed("ListToolBar", owner: self, options: nil)
        addSubview(contentView)
        contentView.frame = self.bounds
        contentView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        collectionView.register(UINib.init(nibName: "NewListToolbarCell", bundle: nil), forCellWithReuseIdentifier: "tooltopCellNew")
        
        flowLayout.estimatedItemSize = UICollectionViewFlowLayout.automaticSize
        
        newMatchButton.layer.cornerRadius = 4
        doneButton.layer.cornerRadius = 4
        
        contentView.backgroundColor = .clear
        
        var effect = UIBlurEffect()
        effect = UIBlurEffect(style: .systemThickMaterialDark)
        visualBaseView.effect = effect
        
        setLightMode()
        
        backgroundTapView.isAccessibilityElement = true
        backgroundTapView.accessibilityLabel = "Toolbar"
        backgroundTapView.accessibilityTraits = .none
        
        newMatchButton.accessibilityHint = "Inserts a bullet point at the cursor. Wherever there is a bullet point, Find will divide the search text into individual words, and look for each of them."
        
        if location == .inCamera {
            doneButton.accessibilityHint = "Dismiss the keyboard and shrink the search bar"
        } else {
            doneButton.accessibilityHint = "Dismiss the keyboard"
        }
        
    }
    
    func addList(list: EditableFindList) {
        calculateWhereToInsert(component: list)
    }
    
    func setLightMode() {

        newMatchButton.backgroundColor = UIColor.secondarySystemFill
        doneButton.backgroundColor = UIColor.secondarySystemFill
        
        newMatchButton.setTitleColor(UIColor.label, for: .normal)
        doneButton.setTitleColor(UIColor.label, for: .normal)
        
        let effect = UIBlurEffect(style: .systemThickMaterial)
        visualBaseView.effect = effect
        
    }
    
    func forceDarkMode() {

        newMatchButton.backgroundColor = UIColor(named: "DarkSystemFill")
        doneButton.backgroundColor = UIColor(named: "DarkSystemFill")
        
        newMatchButton.setTitleColor(UIColor.white, for: .normal)
        doneButton.setTitleColor(UIColor.white, for: .normal)
        
        let effect = UIBlurEffect(style: .systemThickMaterialDark)
        visualBaseView.effect = effect
        
    }
    
}

extension ListToolBar: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return editableListCategories.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "tooltopCellNew", for: indexPath) as! NewListToolbarCell
        let list = editableListCategories[indexPath.item]
        cell.labelText.text = list.name
        cell.backgroundColor = UIColor(hexString: list.iconColorName)
        cell.layer.cornerRadius = 6
        
        let symbolConfiguration = UIImage.SymbolConfiguration(pointSize: 8, weight: .semibold)
        let newImage = UIImage(systemName: list.iconImageName, withConfiguration: symbolConfiguration)?.withTintColor(UIColor.white, renderingMode: .alwaysOriginal)
        
        cell.imageView.image = newImage
        
        cell.contentView.isAccessibilityElement = true
        cell.contentView.accessibilityLabel = "List"
        cell.contentView.accessibilityHint = "Double-tap to use the list. Moves it to the Selected Lists container."
        
        let colorDescription = list.iconColorName.getDescription()
        
        let listName = AccessibilityText(text: list.name, isRaised: false)
        let iconTitle = AccessibilityText(text: "\nIcon", isRaised: true)
        let iconString = AccessibilityText(text: list.iconImageName, isRaised: false)
        let colorTitle = AccessibilityText(text: "\nColor", isRaised: true)
        let colorString = AccessibilityText(text: "\(colorDescription.0)", isRaised: false)
        let pitchTitle = AccessibilityText(text: "\nPitch", isRaised: true)
        let pitchString = AccessibilityText(text: "\(colorDescription.1)", isRaised: false, customPitch: colorDescription.1)
        
        let accessibilityLabel = UIAccessibility.makeAttributedText(
            [
                listName,
                iconTitle, iconString,
                colorTitle, colorString,
                pitchTitle, pitchString,
            ]
        )
        
        cell.contentView.accessibilityAttributedValue = accessibilityLabel
        
        return cell
        
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let newList = editableListCategories[indexPath.item]
        selectedList?.addList(list: newList)
        
        editableListCategories.remove(at: indexPath.item)
        collectionView.deleteItems(at: [indexPath])
    }
}

extension ListToolBar {
    func calculateWhereToInsert(component: EditableFindList) {
        let componentOrderID = component.orderIdentifier
        var indexPathToAppendTo = 0
        for (index, singleComponent) in editableListCategories.enumerated() {
            ///We are going to check if the singleComponent's order identifier is smaller than componentOrderID.
            ///If it is smaller, we know we must insert the cell ONE to the right of this indexPath.
            if singleComponent.orderIdentifier < componentOrderID {
                indexPathToAppendTo = index + 1
            }
        }
        
        ///Now that we know where to append the green cell, let's do it!
        editableListCategories.insert(component, at: indexPathToAppendTo)
        let newIndexPath = IndexPath(item: indexPathToAppendTo, section: 0)
        collectionView.performBatchUpdates({
            self.collectionView.insertItems(at: [newIndexPath])
        }) { _ in
            
            if self.location == .inCamera {
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
                    UIAccessibility.post(notification: .announcement, argument: "Moved back to toolbar")
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
                        if let cell = self.collectionView.cellForItem(at: newIndexPath) {
                            UIAccessibility.post(notification: .layoutChanged, argument: cell.contentView)
                        }
                    }
                }
            } else {
                //                DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
                if let cell = self.collectionView.cellForItem(at: newIndexPath) {
                    UIAccessibility.post(notification: .layoutChanged, argument: cell.contentView)
                }
                //                }
            }
        }
    }
}
