//
//  ListToolBar.swift
//  Find
//
//  Created by Zheng on 3/9/20.
//  Copyright © 2020 Andrew. All rights reserved.
//

import UIKit

enum ToolbarButtonType {
    case removeAll
    case newMatch
    case done
}
enum ToolbarTextChangeType {
    case beganEditing
    case shouldReturn
    case changedText
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
//    weak var changedText: ToolbarChangedText?
    weak var startedEditing: StartedEditing?
    
    @IBOutlet var contentView: UIView!
    
    
    @IBOutlet weak var removeAllButton: UIButton!
    
    @IBOutlet weak var newMatchButton: UIButton!
    
    @IBOutlet weak var doneButton: UIButton!
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    
    @IBAction func removeAllPressed(_ sender: Any) {
        pressedButton?.buttonPressed(button: .removeAll)
    }
    
    @IBAction func newMatchPressed(_ sender: Any) {
        pressedButton?.buttonPressed(button: .newMatch)
    }
    
    @IBAction func donePressed(_ sender: Any) {
        pressedButton?.buttonPressed(button: .done)
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setUp()
    }
    
    init() {
        super.init(frame: .zero)
        setUp()
    }
    private func setUp() {
        print("SETT")
       // fromNib()
        //self.changeNumberDelegate = self
        clipsToBounds = true
//        layer.cornerRadius = 5
//        layer.backgroundColor = #colorLiteral(red: 0, green: 0.5981545251, blue: 0.937254902, alpha: 1)
        
        Bundle.main.loadNibNamed("ListToolBar", owner: self, options: nil)
        addSubview(contentView)
        contentView.frame = self.bounds
        contentView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        collectionView.register(UINib.init(nibName: "NewListToolbarCell", bundle: nil), forCellWithReuseIdentifier: "tooltopCellNew")
        
        flowLayout.estimatedItemSize = UICollectionViewFlowLayout.automaticSize
        
        removeAllButton.layer.cornerRadius = 6
        newMatchButton.layer.cornerRadius = 6
        doneButton.layer.cornerRadius = 6
    }
    
    func addList(list: EditableFindList) {
        print("add")
        calculateWhereToInsert(component: list)
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
        
        let symbolConfiguration = UIImage.SymbolConfiguration(pointSize: 10, weight: .semibold)
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
            print("calc")
            var indexPathToAppendTo = 0
            for (index, singleComponent) in editableListCategories.enumerated() {
                ///We are going to check if the singleComponent's order identifier is smaller than componentOrderID.
                ///If it is smaller, we know we must insert the cell ONE to the right of this indexPath.
                if singleComponent.orderIdentifier < componentOrderID {
                    indexPathToAppendTo = index + 1
                }
            }
    //        print("index... \(indexPathToAppendTo)")
            ///Now that we know where to append the green cell, let's do it!
            editableListCategories.insert(component, at: indexPathToAppendTo)
            let newIndexPath = IndexPath(item: indexPathToAppendTo, section: 0)
            collectionView.insertItems(at: [newIndexPath])

        }
     
}
