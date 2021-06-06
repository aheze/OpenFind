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

class ListsNavController: UINavigationController {
    var viewController: ListsController!
}
class ListsController: UIViewController, AdaptiveCollectionLayoutDelegate, UIAdaptivePresentationControllerDelegate, NewListMade, FinishedEditingList {

    
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
        
        let alertView = SPAlertView(title: deletedList, message: tapToDismiss, preset: .done)
        alertView.present(duration: 3.6, haptic: .success)
        listsChanged?()
    }
    
    let realm = try! Realm()
    var listCategories: Results<FindList>?
    
    @IBOutlet var noListsDisplay: UIView!
    
    @IBOutlet weak var collectionView: UICollectionView!
    
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

extension ListsController {
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
}

extension String {
    func heightWithConstrainedWidth(width: CGFloat, font: UIFont) -> CGFloat {
        let constraintRect = CGSize(width: width, height: .greatestFiniteMagnitude)
        let boundingBox = self.boundingRect(with: constraintRect, options: [.usesLineFragmentOrigin, .usesFontLeading], attributes: [NSAttributedString.Key.font: font], context: nil)
        return boundingBox.height
    }
}
