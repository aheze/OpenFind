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
class ListController: UIViewController, ListDeletePressed, AdaptiveCollectionLayoutDelegate, UIAdaptivePresentationControllerDelegate, NewListMade {
    
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
    func listDeleteButtonPressed() {
        
        //print("Delete:")
        //let indexes = indexPathsSelected
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
        //for temp in tempInts
//        var array1 = ["a", "b", "c", "d", "e"]
//        let array2 = ["a", "c", "d"]
        //cellHeights = tempInts.filter { !cellHeights.contains($0) }
        print("cellHeights    : \(cellHeights)")
        print("list categories    : \(listCategories)")
//        for listT in tempLists {
//
//        }
        print("Index selected: \(indexPathsSelected)")
        do {
            try realm.write {
                realm.delete(tempLists)
            }
        } catch {
            print("error deleting category \(error)")
        }
        addHeight()
        //collectionView.reloadData()
        //print("sldjfsldfksj     d")
        collectionView.deleteItems(at: arrayOfIndexPaths)
        //print("sldjfsldfksjd  sfds")
        indexPathsSelected.removeAll()
        numberOfSelected -= tempLists.count
        if listCategories?.count == 0 {
            SwiftEntryKit.dismiss()
        }
        //print("sldjfsldfk            sjd")
        //collectionView.reloadData()
//        let realm = try! Realm()
//        try! realm.write {
//            realm.delete(newVideos)
//        }
        SwiftEntryKit.dismiss()
        //exitSwiftEntryKit()
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
    
    var indexPathsSelected = [Int]()
    var numberOfSelected = 0 {
        didSet {
            changeNumberDelegateList?.changeLabel(to: numberOfSelected)
        }
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
                print("size of Width: \(sizeOfWidth)")
                //let sizeOfWidth = collectionView.frame.size.width - (AdaptiveCollectionConfig.cellPadding * 3) - 20
                
                let newDescHeight = cell.descriptionOfList.heightWithConstrainedWidth(width: sizeOfWidth, font: UIFont.systemFont(ofSize: 16))
                let newContentsHeight = cell.contents.heightWithConstrainedWidth(width: sizeOfWidth, font: UIFont.systemFont(ofSize: 16))
                print(newDescHeight)
                print(newContentsHeight)
                
            
                let extensionHeight = newDescHeight + newContentsHeight
                cellHeights.append(extensionHeight)
            }
        }
        print("add height - height: \(cellHeights)")
        print("list categories    : \(listCategories)")
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
    
}

extension ListController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func madeNewList(name: String, description: String, contents: String, imageName: String, imageColor: String) {
        print("add")
        let newList = FindList()
        newList.name = name
        newList.descriptionOfList = description
        newList.contents = contents
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
        let listT = listCategories?[indexPath.item]
        cell.title.text = listT?.name
        cell.nameDescription.text = listT?.descriptionOfList
        cell.contentsList.text = listT?.contents.replacingOccurrences(of: " \u{2022} ", with: "", options: .literal, range: nil)
        cell.contentView.layer.cornerRadius = 10
        
        
        
        return cell
    }
    
    
    func collectionView(_ collectionView: UICollectionView,
                        heightForTextAtIndexPath indexPath: IndexPath) -> CGFloat {
        print("Height for text")
        print("ListCount: \(listCategories?.count)")
        guard let cell = listCategories?[indexPath.item] else { print("ERRORRRRRR"); return 0 }
        
        //let cell = item.contents.count
        // I get text height and as my font equal ~1pt, it's multiply and than addition it. Maybe you need to
        /// modify that value for greater stability height calculations.
        /// And you can get there image height for adding it to
        let sizeOfWidth = ((collectionView.bounds.width - (AdaptiveCollectionConfig.cellPadding * 3)) / 2) - 20
        print("size of Width: \(sizeOfWidth)")
        //let sizeOfWidth = collectionView.frame.size.width - (AdaptiveCollectionConfig.cellPadding * 3) - 20
        
        let newDescHeight = cell.descriptionOfList.heightWithConstrainedWidth(width: sizeOfWidth, font: UIFont.systemFont(ofSize: 16))
        let newContentsHeight = cell.contents.heightWithConstrainedWidth(width: sizeOfWidth, font: UIFont.systemFont(ofSize: 16))
        //print(newDescHeight)
       // print(newContentsHeight)
        
    
        let extensionHeight = newDescHeight + newContentsHeight
        // It's for example, when you need to remove height
        //let dateHeight: CGFloat = item.expiring == nil ? -12.5 : 0
        //print("Cell: \(cell)")
        print("height: \(AdaptiveCollectionConfig.cellBaseHeight + extensionHeight + 45)")
        print(cellHeights[indexPath.item])
        return AdaptiveCollectionConfig.cellBaseHeight + cellHeights[indexPath.item] + 45 //+ 300
        //+ dateHeight
        
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print("did")
        if selectionMode == true {
            indexPathsSelected.append(indexPath.item)
            numberOfSelected += 1
                
        } else {
            print("false")
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

