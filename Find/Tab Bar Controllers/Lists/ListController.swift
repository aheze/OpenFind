//
//  ListController.swift
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
    
}

class LayerScrollView: UIScrollView, UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}
class ListController: UIViewController, ListDeletePressed, AdaptiveCollectionLayoutDelegate, UIAdaptivePresentationControllerDelegate, NewListMade, FinishedEditingList {


    
//    @IBOutlet weak var quickTourView: UIView!
//    @IBOutlet weak var quickTourHeightC: NSLayoutConstraint! /// 40
//    @IBOutlet weak var quickTourButton: UIButton!
//    @IBOutlet weak var closeQuickTourButton: UIButton!
    
    let defaults = UserDefaults.standard
    @IBAction func quickTourButtonPressed(_ sender: Any) {
        defaults.set(true, forKey: "listsViewedBefore")
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "ListsTutorialViewController") as! ListsTutorialViewController
        
        animateCloseQuickTour()
        present(vc, animated: true, completion: nil)
        
    }
    
    @IBAction func closeQuickTourButtonPressed(_ sender: Any) {
        animateCloseQuickTour()
    }
    
    func animateCloseQuickTour() {
        defaults.set(true, forKey: "listsViewedBefore")
        
//        quickTourHeightC.constant = 0
        
//        let topInset = topBlurView.frame.height
//        let padding = AdaptiveCollectionConfig.cellPadding
        
//        self.collectionView.verticalScrollIndicatorInsets.top = topInset
        
//        UIView.animate(withDuration: 0.5, animations: {
//            self.view.layoutIfNeeded()
//            self.quickTourButton.alpha = 0
//            self.closeQuickTourButton.alpha = 0
//
//
//            self.collectionView.contentInset = UIEdgeInsets(top: padding + topInset, left: padding, bottom: 82, right: padding)
//            self.collectionView.contentInset = UIEdgeInsets(top: padding, left: padding, bottom: 82, right: padding)
//        }) { _ in
//            self.quickTourView.alpha = 0
//        }
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
    
    func sortLists() {
        listCategories = listCategories!.sorted(byKeyPath: "dateCreated", ascending: false)
        guard let listCats = listCategories else { print("No LISTS..... or Error!"); return }
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
    func exitSwiftEntryKit() {
        SwiftEntryKit.dismiss()
        fadeSelectOptions(fadeOut: "fade out")
        selectButtonSelected = false
    }
    
    func deleteTheList() { ///Comes from EditListViewController, deletes an existing list.
        print("Delete Preexisting list")
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
        
        let deletedList = NSLocalizedString("deletedList", comment: "ListController def=Deleted list!")
        let tapToDismiss = NSLocalizedString("tapToDismiss", comment: "Multipurpose def=Tap to dismiss")
        
        let alertView = SPAlertView(title: deletedList, message: tapToDismiss, preset: SPAlertPreset.done)
        alertView.duration = 2.6
        alertView.present()
        
    }
    
    
    func listDeleteButtonPressed() {
        
        var titleMessage = ""
        var finishMessage = ""
        if indexPathsSelected.count == 1 {
            let deleteThisListQuestion = NSLocalizedString("deleteThisListQuestion",
                                                           comment: "ListController def=Delete this List?")
            let listDeletedExclaim = NSLocalizedString("listDeletedExclaim",
                                                       comment: "ListController def=List deleted!")
            
            
            titleMessage = deleteThisListQuestion
            finishMessage = listDeletedExclaim
        } else if indexPathsSelected.count == listCategories?.count {
            let deleteAllListsQuestion = NSLocalizedString("deleteAllListsQuestion",
                                                           comment: "ListController def=Delete ALL lists?!")
            let allListsDeletedExclaim = NSLocalizedString("allListsDeletedExclaim",
                                                       comment: "ListController def=All lists deleted!")
            
            titleMessage = deleteAllListsQuestion
            finishMessage = allListsDeletedExclaim
        } else {
            let deleteSelectedCountLists = NSLocalizedString("Delete %d lists?",
                                                             comment:"ListController def=Delete x lists?")
            let finishedDeleteSelectedCountLists = NSLocalizedString("%d lists deleted!",
                                                                     comment:"ListController def=x lists deleted!")
            
            
            titleMessage = String.localizedStringWithFormat(deleteSelectedCountLists, indexPathsSelected.count)
            finishMessage = String.localizedStringWithFormat(finishedDeleteSelectedCountLists, indexPathsSelected.count)
        }
        
        let cantBeUndone = NSLocalizedString("cantBeUndone", comment: "Multipurpose def=This action can't be undone.")
        
        let alert = UIAlertController(title: titleMessage, message: cantBeUndone, preferredStyle: .alert)
        
        let delete = NSLocalizedString("delete", comment: "Multipurpose def=Delete")
        
        alert.addAction(UIAlertAction(title: delete, style: UIAlertAction.Style.destructive, handler: { _ in
            var tempLists = [FindList]()
            var tempInts = [Int]()
            var arrayOfIndexPaths = [IndexPath]()
            for index in self.indexPathsSelected {
                if let cat = self.listCategories?[index] {
                    tempLists.append(cat)
                    tempInts.append(index)
                    arrayOfIndexPaths.append(IndexPath(item: index, section: 0))
                }
            }
            do {
                try self.realm.write {
                    self.realm.delete(tempLists)
                }
            } catch {
                print("error deleting category \(error)")
            }
            self.collectionView.deleteItems(at: arrayOfIndexPaths)
            self.indexPathsSelected.removeAll()
            self.numberOfSelected -= tempLists.count
            
            self.selectButtonSelected = false
            SwiftEntryKit.dismiss()
            self.fadeSelectOptions(fadeOut: "fade out")
            self.collectionView.allowsMultipleSelection = false
            self.sortLists()
            
            
            let tapToDismiss = NSLocalizedString("tapToDismiss", comment: "Multipurpose def=Tap to dismiss")
            let alertView = SPAlertView(title: finishMessage, message: tapToDismiss, preset: SPAlertPreset.done)
            alertView.duration = 2.6
            alertView.present()
        }))
        
        let cancel = NSLocalizedString("cancel", comment: "Multipurpose def=Cancel")
        alert.addAction(UIAlertAction(title: cancel, style: UIAlertAction.Style.cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
        
      
    }
    override var prefersStatusBarHidden: Bool {
        return false
    }
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
//
//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        if segue.identifier == "makeNewListSegue" {
//            let destinationVC = segue.destination as! MakeNewList
//            destinationVC.isModalInPresentation = true
//            destinationVC.newListDelegate = self
//            destinationVC.iconColorName = randomizedColor
//            segue.destination.presentationController?.delegate = self
//        } else if segue.identifier == "editListSegue" {
//            let destinationVC = segue.destination as! EditListViewController
//            destinationVC.isModalInPresentation = true
//            destinationVC.finalDeleteList = self
//            destinationVC.finishedEditingList = self
//
//            if let currentPath = listCategories?[currentEditingPresentationPath] {
//                destinationVC.name = currentPath.name
//                destinationVC.descriptionOfList = currentPath.descriptionOfList
//                var conts = [String]()
//                for singleCont in currentPath.contents {
//                    conts.append(singleCont)
//                }
//                destinationVC.contents = conts
//                destinationVC.iconImageName = currentPath.iconImageName
//                destinationVC.iconColorName = currentPath.iconColorName
//            }
//            segue.destination.presentationController?.delegate = self
//
//        }
//    }
    

    let realm = try! Realm()
    var listCategories: Results<FindList>?
    
    @IBOutlet var noListsDisplay: UIView!
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    
//    @IBOutlet weak var selectButton: UIButton!
    
    var swipedToDismiss = true
    var selectButtonSelected = false
    
    
    weak var changeNumberDelegateList: ChangeNumberOfSelectedList?
    var currentEditingPresentationPath = 0
    
    var indexPathsSelected = [Int]()
    var numberOfSelected = 0 {
        didSet {
            if numberOfSelected == 0 {
                changeNumberDelegateList?.disablePress(disable: true)
            } else {
                changeNumberDelegateList?.disablePress(disable: false)
            }
            changeNumberDelegateList?.changeLabel(to: numberOfSelected)
        }
    }
  
    
   func selectPressed(_ sender: UIButton) {
        
        ///First time press, will be true
        if selectButtonSelected == false {
            selectButtonSelected = true
            fadeSelectOptions(fadeOut: "fade in")
            collectionView.allowsMultipleSelection = true
            
        } else { ///Cancel will now be Select
            selectButtonSelected = false
            SwiftEntryKit.dismiss()
            fadeSelectOptions(fadeOut: "fade out")
            collectionView.allowsMultipleSelection = false
        }
    }
    
    @IBAction func blackXButtonPressed(_ sender: UIButton) {
        if let pvc = self.presentationController {
            pvc.delegate?.presentationControllerDidDismiss?(pvc)
        }
        self.dismiss(animated: true, completion: nil)
    }
    
    
//    @IBOutlet weak var addListButton: UIButton!
    func addListPressed(_ sender: UIButton) {
        exitSwiftEntryKit()
//        performSegue(withIdentifier: "makeNewListSegue", sender: self)
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let viewController = storyboard.instantiateViewController(withIdentifier: "ListBuilderViewController") as? ListBuilderViewController {
            viewController.newListDelegate = self
            viewController.iconColorName = randomizedColor
            self.present(viewController, animated: true)
        }
        
//        let destinationVC = segue.destination as! MakeNewList
//        destinationVC.isModalInPresentation = true
//        destinationVC.newListDelegate = self
//        destinationVC.iconColorName = randomizedColor
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
        setUpBarButtons()
//        addListButton.layer.cornerRadius = 6
//        addListButton.backgroundColor = UIColor(hexString: randomizedColor)
        
//        let topInset = topBlurView.frame.height
        let padding = AdaptiveCollectionConfig.cellPadding

        getData()
        collectionView.delaysContentTouches = false
//        selectButton.layer.cornerRadius = 6
        
        let defaults = UserDefaults.standard
        let listsViewedBefore = defaults.bool(forKey: "listsViewedBefore")
        
        if listsViewedBefore == false {
            
            collectionView.contentInset = UIEdgeInsets(top: padding + 40, left: padding, bottom: 82, right: padding)
            collectionView.verticalScrollIndicatorInsets.top = 40
            
//            quickTourHeightC.constant = 40
            UIView.animate(withDuration: 0.5, animations: {
                self.view.layoutIfNeeded()
            })
            
        } else {
            collectionView.contentInset = UIEdgeInsets(top: padding, left: padding, bottom: 82, right: padding)
//            collectionView.verticalScrollIndicatorInsets.top = topInset
            
//            quickTourView.alpha = 0
//            quickTourButton.alpha = 0
//            closeQuickTourButton.alpha = 0
//            quickTourHeightC.constant = 0
        }
        
        
        
        
//        navigationController?.view
//        
//        let constraint = navigationController!.navigationBar.bottomAnchor.constraint(equalTo: quickTourView.topAnchor)
//        NSLayoutConstraint.activate([constraint])
        
        self.title = "Lists"
        navigationController?.navigationBar.prefersLargeTitles = true
        
        let quickTourView = TutorialHeader()
        quickTourView.translatesAutoresizingMaskIntoConstraints = false
        navigationController!.view.insertSubview(quickTourView, belowSubview: navigationController!.navigationBar)
        
        NSLayoutConstraint.activate([
            quickTourView.heightAnchor.constraint(equalToConstant: 50),
            quickTourView.leftAnchor.constraint(equalTo: navigationController!.view.leftAnchor),
            quickTourView.rightAnchor.constraint(equalTo: navigationController!.view.rightAnchor),
//            quickTourView.topAnchor.constraint(equalTo: navigationController!.view.bottomAnchor)
//            ,
            quickTourView.bottomAnchor.constraint(equalTo: navigationController!.navigationBar.bottomAnchor, constant: 50)
        ])
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
        
    }
    func update(index: Int, name: String, description: String, contents: [String], imageName: String, imageColor: String) {
        print("updating with... \(name), \(description), \(contents)")
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
        collectionView.reloadData()
    }
}
extension ListController {
    func updateExistingList(name: String, description: String, contents: [String], imageName: String, imageColor: String, deleteList: Bool) {
        if deleteList {
            deleteTheList()
        } else {
            update(index: currentEditingPresentationPath, name: name, description: description, contents: contents, imageName: imageName, imageColor: imageColor)
        }
    }
}

extension ListController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
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
                                                          comment:"ListController def=\n... x more")
                
                textToDisplay += String.localizedStringWithFormat(overFlowCountMoreFormat, overFlowCount)
            }
            
            cell.contentsList.text = textToDisplay
            cell.baseView.layer.cornerRadius = 10
            cell.tapHighlightView.layer.cornerRadius = 10
            cell.tapHighlightView.alpha = 0
            cell.highlightView.layer.cornerRadius = 10
            
        }
        if indexPathsSelected.contains(indexPath.item) {
            UIView.animate(withDuration: 0.1, animations: {
                
                collectionView.selectItem(at: indexPath, animated: false, scrollPosition: [])
                cell.highlightView.alpha = 1
                cell.checkmarkView.alpha = 1
                cell.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
            })
        } else {
            UIView.animate(withDuration: 0.1, animations: {
                collectionView.deselectItem(at: indexPath, animated: false)
                cell.highlightView.alpha = 0
                cell.checkmarkView.alpha = 0
                cell.transform = CGAffineTransform.identity
            })
        }
        return cell
    }
    
    
    func collectionView(_ collectionView: UICollectionView,
                        heightForTextAtIndexPath indexPath: IndexPath) -> CGFloat {
        guard let cell = listCategories?[indexPath.item] else { print("ERRORRRRRR"); return 0 }
        
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
//            textToDisplay += "\n... \(overFlowCount) more"
            let overFlowCountMoreFormat = NSLocalizedString("%d overFlowCountMore",
                                                      comment:"ListController def=\n... x more")
            
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
                    cell.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
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
                }
                
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
                cell.transform = CGAffineTransform.identity
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

extension ListController {
    
 
    //MARK: Selection
//    func deselectAllItems() {
//        var reloadPaths = [IndexPath]()
//        for indexP in indexPathsSelected {
//            let indexPath = IndexPath(item: indexP, section: 0)
//            collectionView.deselectItem(at: indexPath, animated: true)
//            if let cell = collectionView.cellForItem(at: indexPath) as? ListCollectionCell {
//                UIView.animate(withDuration: 0.1, animations: {
//                    cell.highlightView.alpha = 0
//                    cell.checkmarkView.alpha = 0
//                    cell.transform = CGAffineTransform.identity
//                })
//            } else {
//                reloadPaths.append(indexPath)
//            }
//        }
//        collectionView.reloadItems(at: reloadPaths)
//        indexPathsSelected.removeAll()
//        numberOfSelected = 0
//    }
    func fadeSelectOptions(fadeOut: String) {
        switch fadeOut {
        case "fade out":
//            deselectAllItems()
        
        print("fade out")
//            UIView.transition(with: selectButton, duration: 0.1, options: .transitionCrossDissolve, animations: {
//
//                let select = NSLocalizedString("select", comment: "ListController def=select")
//
//                self.selectButton.setTitle(select, for: .normal)
//                self.view.layoutIfNeeded()
//            }, completion: nil)
            
        case "fade in":
            if listCategories?.count == 0 {
                
                selectButtonSelected = false
                var attributes = EKAttributes.bottomFloat
                attributes.entryBackground = .color(color: .white)
                attributes.entranceAnimation = .translation
                attributes.exitAnimation = .translation
                attributes.displayDuration = 0.7
                attributes.positionConstraints.size.height = .constant(value: 50)
                attributes.statusBar = .light
                attributes.entryInteraction = .absorbTouches
                
                attributes.scroll = .enabled(swipeable: false, pullbackAnimation: .jolt)
                let contentView = UIView()
                contentView.backgroundColor = #colorLiteral(red: 0.4666666687, green: 0.7647058964, blue: 0.2666666806, alpha: 1)
                contentView.layer.cornerRadius = 8
                let subTitle = UILabel()
                
                let noListsCreatedYet = NSLocalizedString("noListsCreatedYet",
                                                          comment: "ListController def=No Lists Created Yet!")
                subTitle.text = noListsCreatedYet
                subTitle.textColor = UIColor.white
                contentView.addSubview(subTitle)
                subTitle.snp.makeConstraints { (make) in
                    make.center.equalToSuperview()
                }
                
                let edgeWidth = CGFloat(600)
                attributes.positionConstraints.maxSize = .init(width: .constant(value: edgeWidth), height: .intrinsic)
                SwiftEntryKit.display(entry: contentView, using: attributes)
                
                selectButtonSelected = false
                collectionView.allowsMultipleSelection = false
                
            } else {
                // Create a basic toast that appears at the top
                var attributes = EKAttributes.bottomFloat
                attributes.entryBackground = .color(color: .white)
                attributes.entranceAnimation = .translation
                attributes.exitAnimation = .translation
                attributes.displayDuration = .infinity
                attributes.positionConstraints.size.height = .constant(value: 50)
                attributes.statusBar = .light
                attributes.entryInteraction = .absorbTouches
                
                attributes.scroll = .enabled(swipeable: false, pullbackAnimation: .jolt)
                
                let edgeWidth = CGFloat(600)
                attributes.positionConstraints.maxSize = .init(width: .constant(value: edgeWidth), height: .intrinsic)
                let customView = ListSelect()
                customView.listDeletePressed = self
                changeNumberDelegateList = customView
                
                SwiftEntryKit.display(entry: customView, using: attributes)
                changeNumberDelegateList?.disablePress(disable: true)
                
//                let cancel = NSLocalizedString("cancel", comment: "Multipurpose def=Cancel")
                let done = NSLocalizedString("done", comment: "Multipurpose def=Done")
//                selectButton.setTitle(done, for: .normal)
                UIView.animate(withDuration: 0.1, animations: {
                    self.view.layoutIfNeeded()
                })
            }
            
        default:
            print("unknown case, fade")
        }
    }
}


/// stopped here for localization
