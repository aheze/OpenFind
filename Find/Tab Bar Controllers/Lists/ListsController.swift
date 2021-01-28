//
//  ListsController.swift
//  Find
//
//  Created by Andrew on 1/20/20.
//  Copyright © 2020 Andrew. All rights reserved.
//

import UIKit
import SwiftEntryKit
import RealmSwift
import SPAlert


protocol ChangeNumberOfSelectedList: class {
    func changeLabel(to: Int)
    func disablePress(disable: Bool)
}
class ListsNavController: UINavigationController {
    var viewController: ListsController!
}

class LayerScrollView: UIScrollView, UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}
class ListsController: UIViewController, ListDeletePressed, AdaptiveCollectionLayoutDelegate, UIAdaptivePresentationControllerDelegate, NewListMade, FinishedEditingList {

    
    // MARK: - Tab bar
    var showSelectionControls: ((Bool) -> Void)? /// show or hide
    
    // MARK: - Selection
    var addButton: UIBarButtonItem!
    var selectButton: UIBarButtonItem!
    var updateSelectionLabel: ((Int) -> Void)?
    
    /// Whether is in select mode or not
    var selectButtonSelected = false
    var indexPathsSelected = [Int]()
    var numberOfSelected = 0 {
        didSet {
            updateSelectionLabel?(numberOfSelected)
        }
    }
    
    var presentingList: ((Bool) -> Void)? /// update status bar color
    var listsChanged: (() -> Void)? /// lists refreshed or added/deleted

    let defaults = UserDefaults.standard
    func animateCloseQuickTour(quickTourView: TutorialHeader) {
        defaults.set(true, forKey: "listsViewedBefore")
        
        let padding = AdaptiveCollectionConfig.cellPadding
        
        quickTourView.colorViewHeightConst.constant = 0
        
        UIView.animate(withDuration: 0.5, animations: {
            quickTourView.layoutIfNeeded()
            self.collectionView.contentInset.top = padding
            quickTourView.startTourButton.alpha = 0
            quickTourView.closeButton.alpha = 0
        }) { _ in
            quickTourView.removeFromSuperview()
        }
    }
    
    
    
    var colorArray: [String] = [
    "#eb2f06","#e55039","#f7b731","#fed330","#78e08f",
    "#fc5c65","#fa8231","#f6b93b","#b8e994","#2bcbba",
    "#ff6348","#b71540","#579f2b","#d1d8e0","#778ca3",
    "#e84393","#a55eea","#5352ed","#70a1ff","#40739e",
    "#45aaf2","#2d98da","#00aeef","#4b6584","#0a3d62"]
    var randomizedColor = ""
    
    func presentationControllerDidDismiss(_ presentationController: UIPresentationController) {
        SwiftEntryKit.dismiss()
    }
    
    /// Sort lists by date and show a no list view if no lists
    func sortLists() {
        listCategories = listCategories!.sorted(byKeyPath: "dateCreated", ascending: false)
        guard let listCats = listCategories else { return }
        if listCats.count == 0 {
            view.addSubview(noListsDisplay)
            noListsDisplay.snp.makeConstraints { (make) in
                make.center.equalToSuperview()
                make.width.equalTo(300)
                make.height.equalTo(300)
            }
        } else {
            noListsDisplay.removeFromSuperview()
        }
    }
    
    func deleteTheList() { ///Comes from EditListViewController, deletes an existing list.
        if let currentList = listCategories?[currentEditingPresentationPath] {
            do {
                try realm.write {
                    realm.delete(currentList)
                }
            } catch {
                print("error deleting category \(error)")
            }
            let indP = IndexPath(item: currentEditingPresentationPath, section: 0)
            sortLists()
            collectionView?.performBatchUpdates({
                self.collectionView?.deleteItems(at: [indP])
            }, completion: nil)
            currentEditingPresentationPath = -1
        }
        
        let deletedList = NSLocalizedString("deletedList", comment: "ListsController def=Deleted list!")
        let tapToDismiss = NSLocalizedString("tapToDismiss", comment: "Multipurpose def=Tap to dismiss")
        
        let alertView = SPAlertView(title: deletedList, message: tapToDismiss, preset: SPAlertPreset.done)
        alertView.duration = 2.6
        alertView.present()
        print("chaing list")
        listsChanged?()
    }
    
    let realm = try! Realm()
    var listCategories: Results<FindList>?
    
    @IBOutlet var noListsDisplay: UIView!
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    var swipedToDismiss = true
    
    
    weak var changeNumberDelegateList: ChangeNumberOfSelectedList?
    var currentEditingPresentationPath = 0
    
    
    @IBAction func blackXButtonPressed(_ sender: UIButton) {
        if let pvc = self.presentationController {
            pvc.delegate?.presentationControllerDidDismiss?(pvc)
        }
        self.dismiss(animated: true, completion: nil)
    }
    
    
    weak var delegate: UIAdaptivePresentationControllerDelegate?
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let layout = collectionView?.collectionViewLayout as? AdaptiveCollectionLayout {
          layout.delegate = self
        }
        
        if let randColorString = colorArray.randomElement() {
            randomizedColor = randColorString
        }
        setupBarButtons()
        
        let padding = AdaptiveCollectionConfig.cellPadding
        
        collectionView.contentInset.left = padding
        collectionView.contentInset.right = padding

        getData()
        collectionView.delaysContentTouches = false
        
        let listsViewedBefore = defaults.bool(forKey: "listsViewedBefore")
        
        
        if listsViewedBefore == false {
            let quickTourView = TutorialHeader()
            quickTourView.colorView.backgroundColor = UIColor(named: "TabIconListsMain")
            
            if let navController = navigationController {
                navController.view.insertSubview(quickTourView, belowSubview: navigationController!.navigationBar)
                
                quickTourView.snp.makeConstraints { (make) in
                    make.height.equalTo(50)
                    make.left.equalToSuperview()
                    make.right.equalToSuperview()
                    make.bottom.equalTo(navController.navigationBar.snp.bottom).offset(50)
                }
                
                collectionView.contentInset.top = padding + 50
                
                quickTourView.pressed = { [weak self] in
                    
                    let storyboard = UIStoryboard(name: "Main", bundle: nil)
                    let vc = storyboard.instantiateViewController(withIdentifier: "ListsTutorialViewController") as! ListsTutorialViewController
                    
                    self?.animateCloseQuickTour(quickTourView: quickTourView)
                    self?.present(vc, animated: true, completion: nil)
                }
                
                quickTourView.closed = { [weak self] in
                    self?.animateCloseQuickTour(quickTourView: quickTourView)
                }
            }
            
        }
        
        let bottomInset = CGFloat(ConstantVars.tabHeight)
        let bottomSafeAreaHeight = UIApplication.shared.windows.filter {$0.isKeyWindow}.first?.safeAreaInsets.bottom ?? 0
        collectionView.contentInset.bottom = bottomInset
        collectionView.verticalScrollIndicatorInsets.bottom = bottomInset - CGFloat(bottomSafeAreaHeight)
        
        self.title = "Lists"
        navigationController?.navigationBar.prefersLargeTitles = true
        
        
    }
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(true)
        indexPathsSelected.removeAll()
    }
    func getData() {
        listCategories = realm.objects(FindList.self)
        sortLists()
        collectionView.reloadData()
    }
    
    func save(findList: FindList) {
        do {
            try realm.write {
                realm.add(findList)
            }
        } catch {
            print("Error saving category \(error)")
        }
        sortLists()
        
        let indexPath = IndexPath(
            item: 0,
           section: 0
        )
        collectionView?.performBatchUpdates({
            self.collectionView?.insertItems(at: [indexPath])
        }, completion: nil)
        listsChanged?()
    }
    func update(index: Int, name: String, description: String, contents: [String], imageName: String, imageColor: String) {
        if let listToEdit = listCategories?[index] {
            do {
                try realm.write {
                    listToEdit.name = name
                    listToEdit.descriptionOfList = description
                    listToEdit.contents.removeAll()
                    for cont in contents {
                        listToEdit.contents.append(cont)
                    }
                    print(listToEdit.contents)
                    listToEdit.iconImageName = imageName
                    listToEdit.iconColorName = imageColor
                }
            } catch {
                print("Error saving category \(error)")
            }
        }
        listsChanged?()
        collectionView.reloadData()
    }
}
extension ListsController {
    func updateExistingList(name: String, description: String, contents: [String], imageName: String, imageColor: String, deleteList: Bool) {
        if deleteList {
            deleteTheList()
        } else {
            update(index: currentEditingPresentationPath, name: name, description: description, contents: contents, imageName: imageName, imageColor: imageColor)
        }
    }
}

extension ListsController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func madeNewList(name: String, description: String, contents: [String], imageName: String, imageColor: String) {
        
        
        let listsCount = defaults.integer(forKey: "listsCreateCount")
        let newListsCount = listsCount + 1
        defaults.set(newListsCount, forKey: "listsCreateCount")
        
        
        let newList = FindList()
        newList.name = name
        newList.descriptionOfList = description
        
        for cont in contents {
            newList.contents.append(cont)
        }
        
        newList.iconImageName = imageName
        newList.iconColorName = imageColor
        newList.dateCreated = Date()
        save(findList: newList)
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return listCategories?.count ?? 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "listCollectionCell", for: indexPath) as! ListCollectionCell
        
        if let listT = listCategories?[indexPath.item] {
            
            cell.title.text = listT.name
            cell.nameDescription.text = listT.descriptionOfList
            
            let symbolConfiguration = UIImage.SymbolConfiguration(pointSize: 100, weight: .semibold)
            let newImage = UIImage(systemName: listT.iconImageName, withConfiguration: symbolConfiguration)?.withTintColor(UIColor(hexString: listT.iconColorName), renderingMode: .alwaysOriginal)
            cell.imageView.image = newImage
            
            var textToDisplay = ""
            var overFlowCount = 0
            for (index, text) in listT.contents.enumerated() {
                
                if index <= 10 {
                    if index == listT.contents.count - 1 {
                        textToDisplay += text
                    } else {
                        textToDisplay += "\(text)\n"
                    }
                } else {
                    overFlowCount += 1
                }
            }
            
            if overFlowCount >= 1 {
                let overFlowCountMoreFormat = NSLocalizedString("%d overFlowCountMore",
                                                          comment:"ListsController def=\n... x more")
                
                textToDisplay += String.localizedStringWithFormat(overFlowCountMoreFormat, overFlowCount)
            }
            
            cell.contentsList.text = textToDisplay
            cell.baseView.layer.cornerRadius = 10
            cell.tapHighlightView.layer.cornerRadius = 10
            cell.tapHighlightView.alpha = 0
            cell.highlightView.layer.cornerRadius = 10
            
        }
        if indexPathsSelected.contains(indexPath.item) {
            collectionView.selectItem(at: indexPath, animated: false, scrollPosition: [])
            cell.highlightView.alpha = 1
            cell.checkmarkView.alpha = 1
        } else {
            collectionView.deselectItem(at: indexPath, animated: false)
            cell.highlightView.alpha = 0
            cell.checkmarkView.alpha = 0
        }
        return cell
    }
    
    
    func collectionView(_ collectionView: UICollectionView,
                        heightForTextAtIndexPath indexPath: IndexPath) -> CGFloat {
        guard let cell = listCategories?[indexPath.item] else { return 0 }
        
        let sizeOfWidth = ((collectionView.bounds.width - (AdaptiveCollectionConfig.cellPadding * 3)) / 2) - 20
        
        
        let newDescHeight = cell.descriptionOfList.heightWithConstrainedWidth(width: sizeOfWidth, font: UIFont.systemFont(ofSize: 16))
        let array = cell.contents
        
        
        var textToDisplay = ""
        var overFlowCount = 0
        for (index, text) in array.enumerated() {
            
            if index <= 10 {
                if index == array.count - 1 {
                    textToDisplay += text
                } else {
                    textToDisplay += "\(text)\n"
                }
            } else {
                overFlowCount += 1
            }
        }
        if overFlowCount >= 1 {
            let overFlowCountMoreFormat = NSLocalizedString("%d overFlowCountMore",
                                                      comment:"ListsController def=\n... x more")
            
            textToDisplay += String.localizedStringWithFormat(overFlowCountMoreFormat, overFlowCount)
        }
    
        let newContentsHeight = textToDisplay.heightWithConstrainedWidth(width: sizeOfWidth, font: UIFont.systemFont(ofSize: 16))
        
        let titleHeight = cell.name.heightWithConstrainedWidth(width: sizeOfWidth, font: UIFont.systemFont(ofSize: 22, weight: .bold))
        
        let extendHeight = newDescHeight + newContentsHeight + titleHeight
        
        return AdaptiveCollectionConfig.cellBaseHeight + extendHeight + 8 //+ 300
    }
  
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if selectButtonSelected == true {
            indexPathsSelected.append(indexPath.item)
            numberOfSelected += 1
            if let cell = collectionView.cellForItem(at: indexPath) as? ListCollectionCell {
                UIView.animate(withDuration: 0.1, animations: {
                    cell.highlightView.alpha = 1
                    cell.checkmarkView.alpha = 1
                    cell.highlightView.frame.size.width = 40
                })
            }
                
        } else {
            collectionView.deselectItem(at: indexPath, animated: true)
            currentEditingPresentationPath = indexPath.item
            
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            if let viewController = storyboard.instantiateViewController(withIdentifier: "ListBuilderViewController") as? ListBuilderViewController {
                viewController.finishedEditingList = self
                
                if let currentPath = listCategories?[currentEditingPresentationPath] {
                    viewController.name = currentPath.name
                    viewController.descriptionOfList = currentPath.descriptionOfList
                    var contents = [String]()
                    
                    for singleContent in currentPath.contents {
                        contents.append(singleContent)
                    }
                    viewController.isModalInPresentation = true
                    viewController.contents = contents
                    viewController.iconImageName = currentPath.iconImageName
                    viewController.iconColorName = currentPath.iconColorName
                    
                    viewController.donePressed = { [weak self] in
                        self?.presentingList?(false)
                    }
                }
                
                presentingList?(true)
                self.present(viewController, animated: true)
            }
        }
    }
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        if selectButtonSelected == true {
            indexPathsSelected.remove(object: indexPath.item)
            numberOfSelected -= 1
            let cell = collectionView.cellForItem(at: indexPath) as! ListCollectionCell
            UIView.animate(withDuration: 0.1, animations: {
                cell.highlightView.alpha = 0
                cell.checkmarkView.alpha = 0
            })
        }
    }
}

extension String {
    func heightWithConstrainedWidth(width: CGFloat, font: UIFont) -> CGFloat {
        let constraintRect = CGSize(width: width, height: .greatestFiniteMagnitude)
        let boundingBox = self.boundingRect(with: constraintRect, options: [.usesLineFragmentOrigin, .usesFontLeading], attributes: [NSAttributedString.Key.font: font], context: nil)
        return boundingBox.height
    }
}
