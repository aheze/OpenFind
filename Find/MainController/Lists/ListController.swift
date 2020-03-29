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
}
class ListController: UIViewController, ListDeletePressed, AdaptiveCollectionLayoutDelegate, UIAdaptivePresentationControllerDelegate, NewListMade, TellControllerToDeleteList {
    var cellHeights = [CGFloat]()
    
    func presentationControllerDidDismiss(_ presentationController: UIPresentationController) {
        print("Did Dismiss")
        SwiftEntryKit.dismiss()
    }
    
    func sortLists() {
        listCategories = listCategories!.sorted(byKeyPath: "dateCreated", ascending: false)
        guard let listCats = listCategories else { print("No LISTS..... or Error!"); return }
        if listCats.count == 0 {
            print("NONE LISTS!!")
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
                print("BATCH UP")
                self.collectionView?.deleteItems(at: [indP])
            }, completion: nil)
            currentEditingPresentationPath = -1
        }
        
        let alertView = SPAlertView(title: "Deleted list!", message: "Tap to dismiss", preset: SPAlertPreset.done)
        alertView.duration = 2.6
        alertView.present()
        
    }
    
    
    func listDeleteButtonPressed() {
        
        var titleMessage = ""
        var finishMessage = ""
        if indexPathsSelected.count == 1 {
            titleMessage = "Delete this List?"
            finishMessage = "List deleted!"
        } else if indexPathsSelected.count == listCategories?.count {
            titleMessage = "Delete ALL lists?!"
            finishMessage = "All lists deleted!"
        } else {
            titleMessage = "Delete \(indexPathsSelected.count) lists?"
            finishMessage = "\(indexPathsSelected.count) lists deleted!"
        }
        
        let alert = UIAlertController(title: titleMessage, message: "This action can't be undone.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Delete", style: UIAlertAction.Style.destructive, handler: { _ in
            var tempLists = [FindList]()
            var tempInts = [Int]()
//            var contentsToDelete =
            var arrayOfIndexPaths = [IndexPath]()
            for index in self.indexPathsSelected {
                if let cat = self.listCategories?[index] {
                    tempLists.append(cat)
                    tempInts.append(index)
                    arrayOfIndexPaths.append(IndexPath(item: index, section: 0))
                    
                }
            }
            print("Index selected: \(self.indexPathsSelected)")
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
            
            
            
            let alertView = SPAlertView(title: finishMessage, message: "Tap to dismiss", preset: SPAlertPreset.done)
            alertView.duration = 2.6
            alertView.present()
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
        
      
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "makeNewListSegue" {
            print("newList")
            let destinationVC = segue.destination as! MakeNewList
            destinationVC.isModalInPresentation = true
            destinationVC.newListDelegate = self
            segue.destination.presentationController?.delegate = self
        } else if segue.identifier == "editListSegue" {
            print("editList")
            let destinationVC = segue.destination as! EditListViewController
            destinationVC.isModalInPresentation = true
            destinationVC.finalDeleteList = self
            destinationVC.finishedEditingList = self
            
            if let currentPath = listCategories?[currentEditingPresentationPath] {
                destinationVC.name = currentPath.name
                destinationVC.descriptionOfList = currentPath.descriptionOfList
                var conts = [String]()
                for singleCont in currentPath.contents {
                    conts.append(singleCont)
                }
                destinationVC.contents = conts
                destinationVC.iconImageName = currentPath.iconImageName
                destinationVC.iconColorName = currentPath.iconColorName
            }
            segue.destination.presentationController?.delegate = self
            
        }
    }
    

    let realm = try! Realm()
    var listCategories: Results<FindList>?
    
    @IBOutlet var noListsDisplay: UIView!
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    
    @IBOutlet weak var selectButton: UIButton!
    
    var swipedToDismiss = true
    var selectButtonSelected = false
    
    
    weak var changeNumberDelegateList: ChangeNumberOfSelectedList?
    var currentEditingPresentationPath = 0
    
    var indexPathsSelected = [Int]()
    var numberOfSelected = 0 {
        didSet {
            changeNumberDelegateList?.changeLabel(to: numberOfSelected)
        }
    }
    
    @IBAction func clearPressed(_ sender: Any) {
        var tempLists = [FindList]()
        var tempInts = [Int]()
        var arrayOfIndexPaths = [IndexPath]()
        for (inx, index) in listCategories!.enumerated() {
            tempLists.append(index)
            tempInts.append(inx)
            arrayOfIndexPaths.append(IndexPath(item: inx, section: 0))
        }
        print("Index selected: \(indexPathsSelected)")
        do {
            try realm.write {
                realm.delete(tempLists)
            }
        } catch {
            print("error deleting category \(error)")
        }
//        addHeight()
        collectionView.deleteItems(at: arrayOfIndexPaths)
        indexPathsSelected.removeAll()
    }
    
    
    @IBAction func selectPressed(_ sender: UIButton) {
//        selectButtonSelected = !selectButtonSelected ///First time press, will be true
        if selectButtonSelected == false {
            selectButtonSelected = true
            print("selecting now")
            fadeSelectOptions(fadeOut: "fade in")
            collectionView.allowsMultipleSelection = true
        } else { ///Cancel will now be Select
            print("canceling now")
            selectButtonSelected = false
            //selectButtonSelected = true
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
    
    
    @IBAction func addListPressed(_ sender: UIButton) {
        exitSwiftEntryKit()
        performSegue(withIdentifier: "makeNewListSegue", sender: self)
    }
    
    weak var delegate: UIAdaptivePresentationControllerDelegate?
    override func viewDidLoad() {
        super.viewDidLoad()
        if let layout = collectionView?.collectionViewLayout as? AdaptiveCollectionLayout {
          layout.delegate = self
        }
        let padding = AdaptiveCollectionConfig.cellPadding
        collectionView.contentInset = UIEdgeInsets(top: padding, left: padding, bottom: 82, right: padding)
        getData()
        collectionView.delaysContentTouches = false
        selectButton.layer.cornerRadius = 6
//        addHeight()
        print("Cellheights: \(cellHeights)")
    }
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(true)
        print("DISSAPEA")
        indexPathsSelected.removeAll()
    }
    func getData() {
        listCategories = realm.objects(FindList.self)
        
        
//        guard let listCats = listCategories else { print("No LISTS..... or Error!"); return }
//        if listCats.count == 0 {
//            view.addSubview(noListsDisplay)
//            noListsDisplay.snp.makeConstraints { (make) in
//                make.center.equalToSuperview()
//                make.width.equalTo(300)
//                make.height.equalTo(300)
//            }
//        }
        sortLists()
        collectionView.reloadData()
    }
    
//    func addHeight() {
//        cellHeights.removeAll()
//        if let cats = listCategories {
//            for cell in cats {
//                let sizeOfWidth = ((collectionView.bounds.width - (AdaptiveCollectionConfig.cellPadding * 3)) / 2) - 20
//               // print("size of Width: \(sizeOfWidth)")
//                //let sizeOfWidth = collectionView.frame.size.width - (AdaptiveCollectionConfig.cellPadding * 3) - 20
//
//                let newDescHeight = cell.descriptionOfList.heightWithConstrainedWidth(width: sizeOfWidth, font: UIFont.systemFont(ofSize: 16))
//
//                let array = cell.contents
//                let arrayAsString = array.joined(separator:"\n")
//                let newContentsHeight = arrayAsString.heightWithConstrainedWidth(width: sizeOfWidth, font: UIFont.systemFont(ofSize: 16))
//                let extensionHeight = newDescHeight + newContentsHeight
//                cellHeights.append(extensionHeight)
//            }
//        }
//    }
    func save(findList: FindList) {
        do {
            try realm.write {
                realm.add(findList)
            }
        } catch {
            print("Error saving category \(error)")
        }
        sortLists()
//        addHeight()
        //collectionView.reloadData()
        let indexPath = IndexPath(
            item: 0,
           section: 0
         )
        //collectionView.reloadData()
        collectionView?.performBatchUpdates({
            self.collectionView?.insertItems(at: [indexPath])
        }, completion: nil)
        
    }
    func update(index: Int, name: String, description: String, contents: [String], imageName: String, imageColor: String) {
        if let listToEdit = listCategories?[index] {
            do {
                try realm.write {
                    listToEdit.name = name
                    listToEdit.descriptionOfList = description
                    listToEdit.contents.removeAll()
                    print("UPDATE")
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
extension ListController: ListFinishedEditing {
    func updateExistingList(name: String, description: String, contents: [String], imageName: String, imageColor: String) {
        print("updating list")
        update(index: currentEditingPresentationPath, name: name, description: description, contents: contents, imageName: imageName, imageColor: imageColor)
    }
}

extension ListController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func madeNewList(name: String, description: String, contents: [String], imageName: String, imageColor: String) {
        print("add")
        let newList = FindList()
        newList.name = name
        newList.descriptionOfList = description
        
        for cont in contents {
            newList.contents.append(cont)
        }
        
        
        newList.iconImageName = imageName
        newList.iconColorName = imageColor
        newList.dateCreated = Date()
       //newList.indexOrder = listCategories!.count
        save(findList: newList)
        print("new list")
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return listCategories?.count ?? 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "listCollectionCell", for: indexPath) as! ListCollectionCell
        
        if let listT = listCategories?[indexPath.item] {
            
            cell.title.text = listT.name
            cell.nameDescription.text = listT.descriptionOfList
            //cell.contentView.clipsToBounds = true
            
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
                textToDisplay += "\n... \(overFlowCount) more"
            }
            
//            let array = listT.contents.joined(separator:"\n")
            
            cell.contentsList.text = textToDisplay
            cell.baseView.layer.cornerRadius = 10
            cell.tapHighlightView.layer.cornerRadius = 10
            cell.tapHighlightView.alpha = 0
            cell.highlightView.layer.cornerRadius = 10
            print("CELL FOR ITEM, \(listT.name)")
            
        }
        if indexPathsSelected.contains(indexPath.item) {
            print("contains select")
            UIView.animate(withDuration: 0.1, animations: {
                
                collectionView.selectItem(at: indexPath, animated: false, scrollPosition: [])
                cell.highlightView.alpha = 1
                cell.checkmarkView.alpha = 1
                cell.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
            })
        } else {
            print("contains DEselect")
            UIView.animate(withDuration: 0.1, animations: {
//                    cell.isSelected = false
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
            textToDisplay += "\n... \(overFlowCount) more"
        }
        
        
//        let arrayAsString = array.joined(separator:"\n")
        let newContentsHeight = textToDisplay.heightWithConstrainedWidth(width: sizeOfWidth, font: UIFont.systemFont(ofSize: 16))
        
        let titleHeight = cell.name.heightWithConstrainedWidth(width: sizeOfWidth, font: UIFont.systemFont(ofSize: 22, weight: .bold))
        
        let extendHeight = newDescHeight + newContentsHeight + titleHeight
        
        return AdaptiveCollectionConfig.cellBaseHeight + extendHeight + 8 //+ 300
    }
  
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print("did")
        if selectButtonSelected == true {
            print("SEL MODE")
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
            print("NOT")
            collectionView.deselectItem(at: indexPath, animated: true)
            currentEditingPresentationPath = indexPath.item
            performSegue(withIdentifier: "editListSegue", sender: self)
            //print("false")
            //performSegue(withIdentifier: "makeNewListSegue", sender: self)
//            let storyboard1 = UIStoryboard(name: "Main", bundle: nil)
//            let swipeViewController = storyboard1.instantiateViewController(withIdentifier: "EditListViewController") as! EditListViewController
            //let firstViewController = EditListViewController()
//            swipeViewController.modalPresentationStyle = .custom
//            swipeViewController.transitioningDelegate = self
//            swipeViewController.finalDeleteList = self
//
//            if let currentPath = listCategories?[indexPath.item] {
//
//
//                swipeViewController.name = currentPath.name
//                swipeViewController.descriptionOfList = currentPath.descriptionOfList
//                var conts = [String]()
//                for singleCont in currentPath.contents {
//                    conts.append(singleCont)
//                }
//                swipeViewController.contents = conts
//                swipeViewController.iconImageName = currentPath.iconImageName
//                swipeViewController.iconColorName = currentPath.iconColorName
//            }
//            swipeViewController.finalDeleteList = self
//            swipeViewController.finishedEditingList = self
            
//            present(swipeViewController, animated: true, completion: nil)
            
            
        }
    }
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        print("deselecting at indexpath")
        if selectButtonSelected == true {
            indexPathsSelected.remove(object: indexPath.item)
            numberOfSelected -= 1
            let cell = collectionView.cellForItem(at: indexPath) as! ListCollectionCell
            UIView.animate(withDuration: 0.1, animations: {
                cell.highlightView.alpha = 0
                cell.checkmarkView.alpha = 0
                cell.transform = CGAffineTransform.identity
            })
            
            //changeNumberDelegate?.changeLabel(to: numberOfSelected)
            
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
    func deselectAllItems() {
        print("deselc all items-------------")
        print(indexPathsSelected)
        var reloadPaths = [IndexPath]()
        for indexP in indexPathsSelected {
            
            
            let indexPath = IndexPath(item: indexP, section: 0)
            print("indexP: \(indexPath)")
            collectionView.deselectItem(at: indexPath, animated: true)
            if let cell = collectionView.cellForItem(at: indexPath) as? ListCollectionCell {
                UIView.animate(withDuration: 0.1, animations: {
                    cell.highlightView.alpha = 0
                    cell.checkmarkView.alpha = 0
                    cell.transform = CGAffineTransform.identity
                })
            } else {
                reloadPaths.append(indexPath)
                print("Not visible")
            }
        }
        collectionView.reloadItems(at: reloadPaths)
        indexPathsSelected.removeAll()
        numberOfSelected = 0
    }
    func fadeSelectOptions(fadeOut: String) {
        switch fadeOut {
        case "fade out":
            
            deselectAllItems()
            UIView.transition(with: selectButton, duration: 0.1, options: .transitionCrossDissolve, animations: {
              self.selectButton.setTitle("Select", for: .normal)
                self.view.layoutIfNeeded()
            }, completion: nil)
            
        case "fade in":
            print("changing to select mode present entry")
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
                //let font = UIFont.systemFont(ofSize: 18, weight: UIFont.Weight.light)
                let contentView = UIView()
                contentView.backgroundColor = #colorLiteral(red: 0.4666666687, green: 0.7647058964, blue: 0.2666666806, alpha: 1)
                contentView.layer.cornerRadius = 8
                let subTitle = UILabel()
                subTitle.text = "No Lists Created Yet!"
                contentView.addSubview(subTitle)
                subTitle.snp.makeConstraints { (make) in
                    make.center.equalToSuperview()
                }
                
                
                SwiftEntryKit.display(entry: contentView, using: attributes)
                
                selectButtonSelected = false
                fadeSelectOptions(fadeOut: "fade out")
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
                
                
//                attributes.lifecycleEvents.willDisappear = {
//
//                    self.fadeSelectOptions(fadeOut: "fade out")
//                    self.selectButtonSelected = false
//                    self.enterSelectMode(entering: false)
//                }
                let customView = ListSelect()
                customView.listDeletePressed = self
                changeNumberDelegateList = customView
                //selectionMode = true
                //changeNumberDelegate?.changeLabel(to: 4)
                SwiftEntryKit.display(entry: customView, using: attributes)
//                enterSelectMode(entering: true)
                
                selectButton.setTitle("Cancel", for: .normal)
                UIView.animate(withDuration: 0.1, animations: {
                    self.view.layoutIfNeeded()
                })
            }
            
        default:
            print("unknown case, fade")
        }
    }
}

extension ListController:  UIViewControllerTransitioningDelegate {
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return self
    }
    
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return self
    }
}
extension ListController: UIViewControllerAnimatedTransitioning {
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.38
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        // Retrieve the view controllers participating in the current transition from the context.
        let fromView = transitionContext.viewController(forKey: .from)!.view!
        let toView = transitionContext.viewController(forKey: .to)!.view!

        
        // If the view to transition from is this controller's view, the drawer is being presented.
        let isPresentingDrawer = fromView == view
        
//        UIView.animate(withDuration: 0.5, animations: {
//
//        })
        
        let drawerView = isPresentingDrawer ? toView : fromView

        if isPresentingDrawer {
            // Any presented views must be part of the container view's hierarchy
            transitionContext.containerView.addSubview(drawerView)
        }

        /***** Animation *****/
        
        let collViewHeight = view.frame.size.height
        let drawerSize = CGSize(
            width: UIScreen.main.bounds.size.width,
            height: collViewHeight)
        
        print(drawerSize)
        // Determine the drawer frame for both on and off screen positions.
        let yPos = UIScreen.main.bounds.size.height - collViewHeight
        
        
        print(collViewHeight)
        print("y pos: \(yPos)")
        
        let onScreenDrawerFrame = CGRect(origin: CGPoint(x: 0, y: yPos), size: drawerSize)
        let offScreenDrawerFrame = CGRect(origin: CGPoint(x: drawerSize.width, y: yPos), size: drawerSize)
        
        
        if isPresentingDrawer == false {
            let diffYPos = UIScreen.main.bounds.size.height - (collViewHeight / 0.97)
            //let newyPos = yPos * 0.97
            //onScreenDrawerFrame.origin.y = yPos
           var newFrame = onScreenDrawerFrame
            
            //newFrame.origin.x *= 0.97
            //newFrame.origin.x *= 0.97
            //newFrame.size.width *= 0.97
          newFrame.origin.y = diffYPos
            newFrame.size.height = collViewHeight / 0.97
            print("Fram: \(newFrame)")
            drawerView.frame = newFrame
        } else {
            print("off Fram: \(offScreenDrawerFrame)")
            drawerView.frame = offScreenDrawerFrame
        }
        //drawerView.frame = isPresentingDrawer ? offScreenDrawerFrame : onScreenDrawerFrame
        drawerView.layer.cornerRadius = 10
        
        let animationDuration = transitionDuration(using: transitionContext)
        
        // Animate the drawer sliding in and out.
        UIView.animate(withDuration: animationDuration, delay: .zero, options: .curveEaseOut, animations: {
            if isPresentingDrawer == false {
                print("dismissing")
                
                drawerView.frame = offScreenDrawerFrame
                toView.transform = CGAffineTransform.identity
                toView.layer.cornerRadius = 0
            } else {
                print("presenting")
                drawerView.frame = onScreenDrawerFrame
                fromView.transform = CGAffineTransform(scaleX: 0.97, y: 0.97)
                fromView.layer.cornerRadius = 14
            }
        }, completion: { (success) in
            // Cleanup view hierarchy
            if !isPresentingDrawer {
                drawerView.removeFromSuperview()
            }
            
            // IMPORTANT: Notify UIKit that the transition is complete.
            transitionContext.completeTransition(success)
        })
    }
}
