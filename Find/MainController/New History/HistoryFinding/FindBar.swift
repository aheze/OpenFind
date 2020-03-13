//
//  FindBar.swift
//  Find
//
//  Created by Zheng on 3/9/20.
//  Copyright © 2020 Andrew. All rights reserved.
//

import UIKit
import SwiftEntryKit
import RealmSwift

class FindBar: UIView, UISearchBarDelegate {
    
    let deviceSize = UIScreen.main.bounds.size
    
    let realm = try! Realm()
    var listCategories: Results<FindList>?
    var editableListCategories = [EditableFindList]()
    var selectedLists = [EditableFindList]()
    
    
    @IBOutlet var contentView: FindBar!
    
    @IBOutlet weak var searchBar: UISearchBar!
    
    weak var injectListDelegate: InjectLists?
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setUp()
    }
    
    init() {
        super.init(frame: .zero)
        setUp()
    }
    private func setUp() {
       // fromNib()
        //self.changeNumberDelegate = self
        clipsToBounds = true
        layer.cornerRadius = 5
        layer.backgroundColor = #colorLiteral(red: 0, green: 0.5981545251, blue: 0.937254902, alpha: 1)
        
        
        
        Bundle.main.loadNibNamed("FindBar", owner: self, options: nil)
        addSubview(contentView)
        contentView.frame = self.bounds
        contentView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
//        searchBar.searchTextField.backgroundColor = .red
        searchBar.searchTextField.backgroundColor = UIColor(named: "Gray1")
//        searchBar.tintColor = .red
        searchBar.barTintColor = UIColor(named: "Gray3")
        searchBar.layer.borderWidth = 1
        searchBar.layer.borderColor = UIColor(named: "Gray3")?.cgColor
        
        loadListsRealm()
        
        let toolbar = ListToolBar()
        toolbar.frame.size = CGSize(width: deviceSize.width, height: 80)
        toolbar.editableListCategories = editableListCategories
        injectListDelegate = toolbar
        
        toolbar.pressedButton = self
        toolbar.selectedList = self
        toolbar.startedEditing = self
                
        searchBar.inputAccessoryView = toolbar
        searchBar.searchTextField.tokenBackgroundColor = UIColor(named: "FeedbackGradientLeft")
        
        
        
        
//        searchBar.backgroundColor = .red
        
//        searchBar.layer.cornerRadius = 5
    }

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    
    
}
extension FindBar: ToolbarButtonPressed, SelectedList, StartedEditing {
    
    func buttonPressed(button: ToolbarButtonType) {
        switch button {
        case .removeAll:
            removeAllLists()
        case .newMatch:
            if let searchText = searchBar.text {
                searchBar.text = "\(searchText)\u{2022}"
            }
        case .done:
            self.endEditing(true)
        }
    }
    func removeAllLists() {
        searchBar.searchTextField.tokens = []
        var tempArray = [EditableFindList]()
        for singleList in selectedLists {
//            let indP = IndexPath(item: index, section: 0)
            tempArray.append(singleList)
//            calculateWhereToPlaceComponent(component: singleList, placeInSecondCollectionView: indP)
        }
        
        
        selectedLists.removeAll()
//        searchCollectionView.reloadData()
        for temp in tempArray {
            injectListDelegate?.addList(list: temp)
//            calculateWhereToInsert(component: temp)
        }
//        print("remove")
    }
    
    func addList(list: EditableFindList) {
        let insertPosition = selectedLists.count
        selectedLists.append(list)
//        selectedLists.insert(list, at: 0)
        
        let newImage = UIImage(systemName: list.iconImageName)?.withTintColor(UIColor(hexString: list.iconColorName))
        let newToken = UISearchToken(icon: newImage, text: list.name)
        
        newToken.representedObject = list
//        purchasesToken.c

        searchBar.searchTextField.insertToken(newToken, at: insertPosition)
//        if selectedLists.count <= 1 {
//            updateListsLayout(toType: "addListsNow")
//        }
    
//        let indexP = IndexPath(item: 0, section: 0)
//        searchCollectionView.performBatchUpdates({
//            print("add3")
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
        
//        sortSearchTerms()
    }
    
    func startedEditing(start: Bool) {
        print("started editing")
    }
    
    func loadListsRealm() {
        
        listCategories = realm.objects(FindList.self)
        selectedLists.removeAll()
        editableListCategories.removeAll()
        
        listCategories = listCategories!.sorted(byKeyPath: "dateCreated", ascending: false)
        if let lC = listCategories {
            for (index, singleL) in lC.enumerated() {
                
                let editList = EditableFindList()
                
                editList.name = singleL.name
                editList.descriptionOfList = singleL.descriptionOfList
                editList.iconImageName = singleL.iconImageName
                editList.iconColorName = singleL.iconColorName
                editList.orderIdentifier = index
                var contents = [String]()
                for singleCont in singleL.contents {
                    contents.append(singleCont)
                }
                
                editList.contents = contents
                
                editableListCategories.append(editList)
            }
        }
//        print("Loading lists")
        for singL in editableListCategories {
            print(singL.name)
        }
        
//        searchCollectionView.reloadData()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
//        print("Change123123, \(searchText)")
        var tokenLists = [EditableFindList]()
        
        searchBar.searchTextField.tokens.forEach {
            if let list = $0.representedObject as? EditableFindList {
//                print(list.name)
//                if !selectedLists.contains(list) {
                    tokenLists.append(list)
//                }
            }
        }
//        selectedLists = tokenLists
        var tempLists = [EditableFindList]()
        for list in selectedLists {
            if !tokenLists.contains(list) {
                tempLists.append(list)
            }
            
            
//            print("del list: \(tempLi.name)")
        }
        for list in tempLists {
            injectListDelegate?.addList(list: list)
        }
        tempLists.forEach { list in
//            print("DELELE: \(list.name)")
            selectedLists.remove(object: list)
        }
//        let tokens = searchBar.searchTextField.tokens
    }

}
