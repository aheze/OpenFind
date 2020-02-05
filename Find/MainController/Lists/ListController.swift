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
    
    
    func presentationControllerDidDismiss(_ presentationController: UIPresentationController) {
        print("Did Dismiss")
        SwiftEntryKit.dismiss()
    }

    
    
    func listDeleteButtonPressed() {
        //let indexes = indexPathsSelected
        var tempLists = [FindList]()
        var arrayOfIndexPaths = [IndexPath]()
        for index in indexPathsSelected {
            if let cat = listCategories?[index] {
                tempLists.append(cat)
                arrayOfIndexPaths.append(IndexPath(item: index, section: 0))
            }
        }
        print(tempLists.count)
        do {
            try realm.write {
                realm.delete(tempLists)
            }
        } catch {
            print("error deleting category \(error)")
        }
        //collectionView.reloadData()
        collectionView.deleteItems(at: arrayOfIndexPaths)
        indexPathsSelected.removeAll()
        numberOfSelected -= tempLists.count
        if listCategories?.count == 0 {
            SwiftEntryKit.dismiss()
        }
//        let realm = try! Realm()
//        try! realm.write {
//            realm.delete(newVideos)
//        }
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
        performSegue(withIdentifier: "makeNewListSegue", sender: self)
        print("add")
        let newList = FindList()
        newList.name = "sdfhjk"
        newList.descriptionOfList = "Description.....asjdkh skdjhfks dfkjhsf ksdfks fkhfkjsh dvhkdfgddfkjn ldfjglkdf glkjfl kdlfjglkd ljdflgkjd gldkfjlkd lkdjglkd fgjdl"
        newList.contents = "asjdkh skdjhfks dfkjhsf ksdfks fkhfkjsh dvhkdfgddfkjn ldfjglkdf glkjfl kdlfjglkd ljdflgkjd gldkfjlkd lkdjglkd fgjdlfkgjdfg sljdf lsjlfk sdkljfls dfkjsdl flskjfl sdkjfls dflksdjfl;dsjhf;skhf skdfj dfhgkjldsfh gkjdsfhg klsdhfgl kdsfhgkljdhsfg lhdfkghdsfklgjhsdfk gdkfjghdsklffgh sdklfjghsdlkf gskdjfhasjdkh skdjhfks dfkjhsf ksdfks fkhfkjsh dvhkdfgddfkjn ldfjglkdf glkjfl kdlfjglkd ljdflgkjd gldkfjlkd lkdjglkd fgjdlfkgjdfg sljdf lsjlfk sdkljfls dfkjsdl flskjfl sdkjfls dflksdjfl;dsjhf;skhf skdfj dfhgkjldsfh gkjdsfhg klsdhfgl kdsfhgkljdhsfg lhdfkghdsfklgjhsdfk gdkfjghdsklffgh sdklfjghsdlkf gskdjfhkasjdkh skdjhfks dfkjhsf ksdfks fkhfkjsh dvhkdfgddfkjn ldfjglkdf glkjfl kdlfjglkd ljdflgkjd gldkfjlkd lkdjglkd fgjdlfkgjdfg sljdf lsjlfk sdkljfls dfkjsdl flskjfl sdkjfls dflksdjfl;dsjhf;skhf skdfj dfhgkjldsfh gkjdsfhg klsdhfgl kdsfhgkljdhsfg lhdfkghdsfklgjhsdfk gdkfjghdsklffgh sdklfjghsdlkf gskdjfhkasjdkh skdjhfks dfkjhsf ksdfks fkhfkjsh dvhkdfgddfkjn ldfjglkdf glkjfl kdlfjglkd ljdflgkjd gldkfjlkd lkdjglkd fgjdlfkgjdfg sljdf lsjlfk sdkljfls dfkjsdl flskjfl sdkjfls dflksdjfl;dsjhf;skhf skdfj dfhgkjldsfh gkjdsfhg klsdhfgl kdsfhgkljdhsfg lhdfkghdsfklgjhsdfk gdkfjghdsklffgh sdklfjghsdlkf gskdjfhkk"
        save(findList: newList)
//        collectionView?.performBatchUpdates({
//          self.collectionView?.insertItems(at: [coll])
//        }, completion: nil)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let layout = collectionView?.collectionViewLayout as? AdaptiveCollectionLayout {
          layout.delegate = self
        }
        getData()
        selectButton.layer.cornerRadius = 4
    }
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(true)
        print("DISSAPEA")
        indexPathsSelected.removeAll()
    }
    func getData() {
        listCategories = realm.objects(FindList.self)
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
        
        //collectionView.reloadData()
        let indexPath = IndexPath(
            item: (self.listCategories?.count ?? 1) - 1,
           section: 0
         )
        collectionView?.performBatchUpdates({
            self.collectionView?.insertItems(at: [indexPath])
        }, completion: nil)
        
    }
    
}

extension ListController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func madeNewList(name: String, description: String, contents: String, imageName: String, imageColor: UIColor) {
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
        cell.contentsList.text = listT?.contents
        
        
        
        return cell
    }
    
    
    func collectionView(_ collectionView: UICollectionView,
                        heightForTextAtIndexPath indexPath: IndexPath) -> CGFloat {
        
        guard let item = listCategories?[indexPath.item] else { return 0}
        
            let textHeight = item.contents.count
            // I get text height and as my font equal ~1pt, it's multiply and than addition it. Maybe you need to
            /// modify that value for greater stability height calculations.
            /// And you can get there image height for adding it to
            let extensionHeight = Double(textHeight) * 0.70
            // It's for example, when you need to remove height
            //let dateHeight: CGFloat = item.expiring == nil ? -12.5 : 0
            return AdaptiveCollectionConfig.cellBaseHeight + CGFloat(textHeight) + CGFloat(extensionHeight)
            //+ dateHeight
        
    }
    
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
//        print(collectionView.contentInset.left)
//        let itemSize = (collectionView.frame.width - (16 + 16 + 8)) / 2 ///section insets is 16
//        print(itemSize)
//       return CGSize(width: itemSize, height: itemSize)
//    }
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
//        return 8
//    }
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
//        return 8
//    }
    
//    func collectionView(_ collectionView: UICollectionView, heightForDescriptionAtIndexPath indexPath: IndexPath, withWidth width: CGFloat) -> CGFloat {
//        let item = listCategories?[indexPath.row]
//        let itemSize = item?.contents.heightWithConstrainedWidth(width: width-24, font: UIFont.systemFont(ofSize: 10))
//
//        print("DescSize: \(itemSize)")
////        let character = charactersData[indexPath.item]
////        let descriptionHeight = heightForText(character.description, width: width-24)
//        let height = 4 + 17 + 4 + Int(itemSize ?? CGFloat(10)) + 12
//        return CGFloat(height)
//    }
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

