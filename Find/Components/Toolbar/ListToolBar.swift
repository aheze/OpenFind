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
        collectionView.insertItems(at: [newIndexPath])
        
    }
}
