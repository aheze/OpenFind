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
//protocol ToolbarChangedText: class {
//    func changedText(type: ToolbarTextChangeType, special: String)
//}
protocol StartedEditing: class {
    func startedEditing(start: Bool)
}
class ListToolBar: UIView, InjectLists {
   
    
    
    
    @IBOutlet weak var flowLayout: UICollectionViewFlowLayout!
    
//    var selectedLists = [EditableFindList]()
     
//    var origCategories = [EditableFindList]()
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

        
//        let layout =7
    }
    
//    func injectLists(lists: [EditableFindList]) {
//        editableListCategories = lists
//        collectionView.reloadData()
//    }
    
    func addList(list: EditableFindList) {
        print("add")
        calculateWhereToInsert(component: list)
    }
    
//    func removeList(list: EditableFindList) {
//        collectionView.deleteItems(at: <#T##[IndexPath]#>)
//    }
    
}

extension ListToolBar: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return editableListCategories.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "tooltopCellNew", for: indexPath) as! NewListToolbarCell
        //            if let list = listCategories?[indexPath.row] {
                let list = editableListCategories[indexPath.item]
                    cell.labelText.text = list.name
                    cell.backgroundColor = UIColor(hexString: list.iconColorName)
                    cell.layer.cornerRadius = 6
                    let symbolConfiguration = UIImage.SymbolConfiguration(pointSize: 10, weight: .semibold)
                    let newImage = UIImage(systemName: list.iconImageName, withConfiguration: symbolConfiguration)?.withTintColor(UIColor.white, renderingMode: .alwaysOriginal)
                    
                    cell.imageView.image = newImage
    //            }
                return cell
        
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let newList = editableListCategories[indexPath.item]
        selectedList?.addList(list: newList)
        
        editableListCategories.remove(at: indexPath.item)
        collectionView.deleteItems(at: [indexPath])
//        if editableListCategories.count <= 1 {
//            updateListsLayout(toType: "addListsNow")
//        }
//        selectedLists.insert(newList, at: 0)
//        print(selectedLists)
//
//        let indexP = IndexPath(item: 0, section: 0)
//        searchCollectionView.performBatchUpdates({
//            self.searchCollectionView.insertItems(at: [indexP])
//            self.insertingListsCount += 1
//        }, completion: { _ in
//            self.insertingListsCount -= 1
//            if self.isSchedulingList == true {
//                if self.insertingListsCount == 0 {
//                    self.isSchedulingList = false
//                    self.updateListsLayout(toType: "doneAndShrink")
//                }
//            }
//        })
//
////            listViewCollectionView.insertItems(at: [indexP])
//
//        editableListCategories.remove(at: indexPath.item)
//        listsCollectionView.deleteItems(at: [indexPath])
//        if selectedLists.count <= 1 {
//            updateListsLayout(toType: "addListsNow")
//        }
        
//        sortSearchTerms()
    }
    
    
}
extension ListToolBar {
//    func textFieldDidBeginEditing(_ textField: UITextField) {
//        startedEditing?.startedEditing(start: true)
////        if editableListCategories.count == 0 {
////            changedText?.changedText(type: .beganEditing, special: "onlyTextBox")
//////            updateListsLayout(toType: "onlyTextBox")
////        } else {
////            changedText?.changedText(type: .beganEditing, special: "addListsNow")
//////            updateListsLayout(toType: "addListsNow")
////        }
//
//    }
//    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
//    //        finalTextToFind = newSearchTextField.text ?? ""
//        endEditing(true)
//        startedEditing?.startedEditing(start: false)
////        changedText?.changedText(type: .shouldReturn, special: "nothing")
////            if insertingListsCount == 0 {
////                updateListsLayout(toType: "doneAndShrink")
////            } else {
////                isSchedulingList = true
////            }
//    //        print("RETURN")
//    //        print("Text: \(textField.text)")
//            return true
//        }
//        func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
//
////            changedText?.changedText(type: .changedText, special: "nothing")
////            if let updatedString = (textField.text as NSString?)?.replacingCharacters(in: range, with: string) {
////                let splits = updatedString.components(separatedBy: "\u{2022}")
////                let uniqueSplits = splits.uniques
////                if uniqueSplits.count != splits.count {
////                    print("DUPD UPD UPD UPDU PDPUDP")
////                    resetFastHighlights()
////                    allowSearch = false
////                    showDuplicateAlert(show: true)
////                } else {
////                    showDuplicateAlert(show: false)
////                    allowSearch = true
////                    finalTextToFind = updatedString
////                    sortSearchTerms()
////                }
////
////            }
//
//
//            return true
//        }
//        func showDuplicateAlert(show: Bool) {
//            if show == true {
//
//                warningHeightC.constant = 32
//                UIView.animate(withDuration: 0.5, animations: {
//                    self.warningView.alpha = 1
//                    self.warningLabel.alpha = 1
//                    self.view.layoutIfNeeded()
//                })
//            } else {
//                warningHeightC.constant = 6
//                UIView.animate(withDuration: 0.5, animations: {
//                    self.warningView.alpha = 0
//                    self.warningLabel.alpha = 0
//    //                self.warningLabel.text = "Find is paused | Duplicates are not allowed"
//                    self.view.layoutIfNeeded()
//                })
//            }
//        }

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
