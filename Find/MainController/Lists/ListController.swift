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
    }
    func exitSwiftEntryKit() {
        SwiftEntryKit.dismiss()
        fadeSelectOptions(fadeOut: "fade out")
        selectButtonSelected = false
        enterSelectMode(entering: false)
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
    }
    
    
    func listDeleteButtonPressed() {
        sortLists()
        var tempLists = [FindList]()
        var tempInts = [Int]()
        var arrayOfIndexPaths = [IndexPath]()
        for index in indexPathsSelected {
            if let cat = listCategories?[index] {
                tempLists.append(cat)
                tempInts.append(index)
                arrayOfIndexPaths.append(IndexPath(item: index, section: 0))
                
            }
        }
        print("Index selected: \(indexPathsSelected)")
        do {
            try realm.write {
                realm.delete(tempLists)
            }
        } catch {
            print("error deleting category \(error)")
        }
        collectionView.deleteItems(at: arrayOfIndexPaths)
        indexPathsSelected.removeAll()
        numberOfSelected -= tempLists.count
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "makeNewListSegue" {
            print("newList")
            let destinationVC = segue.destination as! MakeNewList
            destinationVC.isModalInPresentation = true
            destinationVC.newListDelegate = self
            segue.destination.presentationController?.delegate = self
        }
    }
    

    let realm = try! Realm()
    var listCategories: Results<FindList>?
    
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    
    @IBOutlet weak var selectButton: UIButton!
    
    var swipedToDismiss = true
    var selectButtonSelected = false
    weak var changeNumberDelegateList: ChangeNumberOfSelectedList?
    var selectionMode: Bool = false {
        didSet {
            print("selection mode: \(selectionMode)")
            collectionView.allowsMultipleSelection = selectionMode
            //fileUrlsSelected.removeAll()
        }
    }
    
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
        addHeight()
        collectionView.deleteItems(at: arrayOfIndexPaths)
        indexPathsSelected.removeAll()
    }
    
    
    @IBAction func selectPressed(_ sender: UIButton) {
        selectButtonSelected = !selectButtonSelected ///First time press, will be true
        if selectButtonSelected == true {
            print("select")
            fadeSelectOptions(fadeOut: "fade in")
        } else { ///Cancel will now be Select
            print("cancel")
            //selectButtonSelected = true
            swipedToDismiss = false
            fadeSelectOptions(fadeOut: "fade out")
            swipedToDismiss = true
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
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let layout = collectionView?.collectionViewLayout as? AdaptiveCollectionLayout {
          layout.delegate = self
        }
        let padding = AdaptiveCollectionConfig.cellPadding
        collectionView.contentInset = UIEdgeInsets(top: padding, left: padding, bottom: padding, right: padding)
        getData()
        collectionView.delaysContentTouches = false
        selectButton.layer.cornerRadius = 4
       // sortLists()
        addHeight()
        print("Cellheights: \(cellHeights)")
    }
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(true)
        print("DISSAPEA")
        indexPathsSelected.removeAll()
    }
    func getData() {
        listCategories = realm.objects(FindList.self)
        sortLists()
        collectionView.reloadData()
    }
    
    func addHeight() {
        cellHeights.removeAll()
        if let cats = listCategories {
            for cell in cats {
                let sizeOfWidth = ((collectionView.bounds.width - (AdaptiveCollectionConfig.cellPadding * 3)) / 2) - 20
               // print("size of Width: \(sizeOfWidth)")
                //let sizeOfWidth = collectionView.frame.size.width - (AdaptiveCollectionConfig.cellPadding * 3) - 20
                
                let newDescHeight = cell.descriptionOfList.heightWithConstrainedWidth(width: sizeOfWidth, font: UIFont.systemFont(ofSize: 16))
                
                let array = cell.contents
                let arrayAsString = array.joined(separator:"\n")
                let newContentsHeight = arrayAsString.heightWithConstrainedWidth(width: sizeOfWidth, font: UIFont.systemFont(ofSize: 16))
                let extensionHeight = newDescHeight + newContentsHeight
                cellHeights.append(extensionHeight)
            }
        }
      //  print("add height - height: \(cellHeights)")
      //  print("list categories    : \(listCategories)")
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
        addHeight()
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
            try! realm.write {
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
        }
        collectionView.reloadData()
    }
//    func removeContents(at indexes: [Int]) {
//        let newVideos = [Video]()
//        for (index, video) in favorite!.videos.enumerated() {
//            if !indexes.contains(index) {
//                newVideos.append(video)
//            }
//        }
//
//        let realm = try! Realm()
//        try! realm.write {
//            realm.delete(newVideos)
//        }
//    }
    
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
            
            let array = listT.contents.joined(separator:"\n")
            cell.contentsList.text = array
            cell.baseView.layer.cornerRadius = 10
            
        }
        //cell.contentView.layer.cornerRadius = 10
        
        
        
        return cell
    }
    
    
    func collectionView(_ collectionView: UICollectionView,
                        heightForTextAtIndexPath indexPath: IndexPath) -> CGFloat {
        guard let cell = listCategories?[indexPath.item] else { print("ERRORRRRRR"); return 0 }
        let sizeOfWidth = ((collectionView.bounds.width - (AdaptiveCollectionConfig.cellPadding * 3)) / 2) - 20
        let newDescHeight = cell.descriptionOfList.heightWithConstrainedWidth(width: sizeOfWidth, font: UIFont.systemFont(ofSize: 16))
        let array = cell.contents
        let arrayAsString = array.joined(separator:"\n")
        let newContentsHeight = arrayAsString.heightWithConstrainedWidth(width: sizeOfWidth, font: UIFont.systemFont(ofSize: 16))
        return AdaptiveCollectionConfig.cellBaseHeight + cellHeights[indexPath.item] + 25 //+ 300
    }
  
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print("did")
        if selectionMode == true {
            indexPathsSelected.append(indexPath.item)
            numberOfSelected += 1
                
        } else {
            currentEditingPresentationPath = indexPath.item
            //print("false")
            //performSegue(withIdentifier: "makeNewListSegue", sender: self)
            let storyboard1 = UIStoryboard(name: "Main", bundle: nil)
            let swipeViewController = storyboard1.instantiateViewController(withIdentifier: "EditListViewController") as! EditListViewController
            //let firstViewController = EditListViewController()
            swipeViewController.modalPresentationStyle = .custom
            swipeViewController.transitioningDelegate = self
            swipeViewController.finalDeleteList = self
            
            if let currentPath = listCategories?[indexPath.item] {
                
                
                swipeViewController.name = currentPath.name
                swipeViewController.descriptionOfList = currentPath.descriptionOfList
                var conts = [String]()
                for singleCont in currentPath.contents {
                    conts.append(singleCont)
                }
                swipeViewController.contents = conts
                swipeViewController.iconImageName = currentPath.iconImageName
                swipeViewController.iconColorName = currentPath.iconColorName
            }
            
            swipeViewController.finishedEditingList = self
            
            present(swipeViewController, animated: true, completion: nil)
            
            collectionView.deselectItem(at: indexPath, animated: true)
        }
    }
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        print("deselecting at indexpath")
        if selectionMode == true {
            indexPathsSelected.remove(object: indexPath.item)
            numberOfSelected -= 1
            //changeNumberDelegate?.changeLabel(to: numberOfSelected)
            
        }

        
    }
//
//      func heightForText(_ text: String, width: CGFloat) -> CGFloat {
//        let font = UIFont.systemFont(ofSize: 10)
//        let rect = NSString(string: text).boundingRect(with: CGSize(width: width, height: CGFloat(MAXFLOAT)), options: .usesLineFragmentOrigin, attributes: convertToOptionalNSAttributedStringKeyDictionary([convertFromNSAttributedStringKey(NSAttributedString.Key.font): font]), context: nil)
//        return ceil(rect.height)
//      }
    
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
        print("deselc")
        
        for i in 0..<collectionView.numberOfSections {
            for j in 0..<collectionView.numberOfItems(inSection: i) {
                collectionView.deselectItem(at: IndexPath(row: j, section: i), animated: false)
            }
        }

        //fileUrlsSelected.removeAll()
        indexPathsSelected.removeAll()
        numberOfSelected = 0
    }
    func fadeSelectOptions(fadeOut: String) {
        switch fadeOut {
        case "fade out":
            
            if swipedToDismiss == false {
                SwiftEntryKit.dismiss()
            }
            UIView.transition(with: selectButton, duration: 0.1, options: .transitionCrossDissolve, animations: {
              self.selectButton.setTitle("Select", for: .normal)
            }, completion: nil)
            UIView.animate(withDuration: 0.5, animations: {
                self.view.layoutIfNeeded()
            })
            indexPathsSelected.removeAll()
            deselectAllItems()
            
            
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
                attributes.lifecycleEvents.willDisappear = {
                    
                    self.fadeSelectOptions(fadeOut: "fade out")
                    self.selectButtonSelected = false
                    self.enterSelectMode(entering: false)
                }
                let customView = ListSelect()
                customView.listDeletePressed = self
                changeNumberDelegateList = customView
                //selectionMode = true
                //changeNumberDelegate?.changeLabel(to: 4)
                SwiftEntryKit.display(entry: customView, using: attributes)
                enterSelectMode(entering: true)
                
                selectButton.setTitle("Cancel", for: .normal)
                UIView.animate(withDuration: 0.5, animations: {
                    self.view.layoutIfNeeded()
                })
            }
            
        default:
            print("unknown case, fade")
        }
    }
    func enterSelectMode(entering: Bool) {
        if entering == true {
            selectionMode = true
        } else {
            selectionMode = false
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
