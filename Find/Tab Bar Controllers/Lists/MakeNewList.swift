////
////  MakeNewList.swift
////  Find
////
////  Created by Andrew on 1/26/20.
////  Copyright © 2020 Andrew. All rights reserved.
////
//
//import UIKit
//import SwiftEntryKit
//import Parchment
//
//
//protocol ReturnGeneralNow: class {
//    func updateInfo()
//}
//protocol ScrolledToIcons: class {
//    func scrolledHere()
//}
//protocol ScrolledToColors: class {
//    func scrolledHere()
//}
//
//class MakeNewList: UIViewController, GetGeneralInfo, GetIconInfo, GetColorInfo, DeleteList {
//    
//
////    @IBOutlet weak var quickTourView: UIView!
////    @IBOutlet weak var quickTourHeightC: NSLayoutConstraint! /// 40
////    @IBOutlet weak var quickTourButton: UIButton!
////    @IBOutlet weak var closeQuickTourButton: UIButton!
//    
//    let defaults = UserDefaults.standard
//    @IBAction func quickTourButtonPressed(_ sender: Any) {
//        
//        let storyboard = UIStoryboard(name: "Main", bundle: nil)
//        let vc = storyboard.instantiateViewController(withIdentifier: "ListsBuilderTutorialViewController") as! ListsBuilderTutorialViewController
//        
//        animateCloseQuickTour()
//        present(vc, animated: true, completion: nil)
//    }
//    
//    @IBAction func closeQuickTourButtonPressed(_ sender: Any) {
//        animateCloseQuickTour()
//    }
//    
//    func animateCloseQuickTour() {
//        defaults.set(true, forKey: "listsBuilderViewedBefore")
////
////        quickTourHeightC.constant = 0
////        UIView.animate(withDuration: 0.5, animations: {
////            self.view.layoutIfNeeded()
////            self.quickTourButton.alpha = 0
////            self.closeQuickTourButton.alpha = 0
////        }) { _ in
////            self.quickTourView.alpha = 0
////        }
//    }
//    
//    
//    let originalListName = NSLocalizedString("originalListName", comment: "EditList def=Untitled")
//    let originalDescriptionOfList = NSLocalizedString("originalDescriptionOfList", comment: "EditList def=No description...")
//    
//    lazy var name = originalListName
//    lazy var descriptionOfList = originalDescriptionOfList
//    
////    var name = "Untitled"
////    var descriptionOfList = "No description..."
//    var contents = [String]()
//    var iconImageName = "square.grid.2x2"
//    var iconColorName = "579f2b"
//    var shouldDismiss = true
//    
//    func returnCompletedList() {
//        print("name: \(name), description: \(descriptionOfList), contents: \(contents), imageName: \(iconImageName), imageColor: \(iconColorName)")
//        newListDelegate?.madeNewList(name: name, description: descriptionOfList, contents: contents, imageName: iconImageName, imageColor: iconColorName)
//        self.dismiss(animated: true, completion: nil)
//    }
//     
//    @IBOutlet weak var stretchyView: UIView!
//    
//    @IBOutlet weak var stretchyHeight: NSLayoutConstraint!
//    
//    @IBOutlet weak var topImageView: UIImageView!
//    
//    
//    func returnNewGeneral(nameOfList: String, desc: String, contentsOfList: [String], hasErrors: Bool, overrideMake: Bool) {
//        name = nameOfList
//        descriptionOfList = desc
//        contents = contentsOfList
//        
//        shouldDismiss = !hasErrors ///dismiss if no errors
//        
//        
//        
//        print("Return New General, has errors: \(hasErrors)")
//        if overrideMake == true {
//            //view.endEditing(true)
//            returnCompletedList()
//        }
//    }
// 
//    func returnNewIcon(iconName: String) {
//        iconImageName = iconName
//        let symbolConfiguration = UIImage.SymbolConfiguration(pointSize: 55, weight: .semibold)
//        let newImage = UIImage(systemName: iconImageName, withConfiguration: symbolConfiguration)?.withTintColor(UIColor(hexString: iconColorName), renderingMode: .alwaysOriginal)
//        topImageView.image = newImage
//    }
//    
//    func returnNewColor(colorName: String) {
//        iconColorName = colorName
//        let symbolConfiguration = UIImage.SymbolConfiguration(pointSize: 55, weight: .semibold)
//        let newImage = UIImage(systemName: iconImageName, withConfiguration: symbolConfiguration)?.withTintColor(UIColor(hexString: iconColorName), renderingMode: .alwaysOriginal)
//        topImageView.image = newImage
//    }
//    
//    func deleteList() {
//        self.dismiss(animated: true, completion: nil)
//    }
//    
//    @IBOutlet weak var headerView: UIView!
//    
//    
//    @IBOutlet weak var cancelButton: UIButton!
//    
//    @IBAction func cancelButtonPressed(_ sender: Any) {
//        self.dismiss(animated: true, completion: nil)
//        
//    }
//    @IBOutlet weak var doneWithListButton: UIButton!
//    
//    @IBAction func doneWithListPressed(_ sender: Any) {
//        returnGeneralNowDelegate?.updateInfo()
//        if shouldDismiss == true {
//            shouldDismiss = false
//            returnCompletedList()
//        }
//    }
//    
//
//    weak var returnGeneralNowDelegate: ReturnGeneralNow?
//    weak var scrolledToIcons: ScrolledToIcons?
//    weak var scrolledToColors: ScrolledToColors?
//    
//    
//    weak var newListDelegate: NewListMade?
//
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        
//        let quickTourView = TutorialHeader()
//        
//        navigationController!.view.insertSubview(quickTourView, at: 0)
//        
//        NSLayoutConstraint.activate([
//            quickTourView.leftAnchor.constraint(equalTo: navigationController!.view.leftAnchor),
//            quickTourView.rightAnchor.constraint(equalTo: navigationController!.view.rightAnchor),
//            quickTourView.topAnchor.constraint(equalTo: navigationController!.view.topAnchor),
//            quickTourView.bottomAnchor.constraint(equalTo: navigationController!.navigationBar.bottomAnchor)
//            ])
//        
//        let listsViewedBefore = defaults.bool(forKey: "listsBuilderViewedBefore")
//        
////        if listsViewedBefore == false {
////
////            quickTourHeightC.constant = 40
////            UIView.animate(withDuration: 0.5, animations: {
////                self.view.layoutIfNeeded()
////            })
////
////        } else {
////            quickTourView.alpha = 0
////            quickTourButton.alpha = 0
////            closeQuickTourButton.alpha = 0
////            quickTourHeightC.constant = 0
////        }
//        
//        setUpViews()
//    }
//    func setUpViews() {
//        
//        let storyboard1 = UIStoryboard(name: "Main", bundle: nil)
//        let firstViewController = storyboard1.instantiateViewController(withIdentifier: "GeneralViewController") as! GeneralViewController
//        
//        let storyboard2 = UIStoryboard(name: "Main", bundle: nil)
//        let secondViewController = storyboard2.instantiateViewController(withIdentifier: "SymbolsViewController") as! SymbolsViewController
//        
//        let storyboard3 = UIStoryboard(name: "Main", bundle: nil)
//        let thirdViewController = storyboard3.instantiateViewController(withIdentifier: "ColorsViewController") as! ColorsViewController
//
//        let firstVCTitle = NSLocalizedString("firstVCTitle", comment: "EditList def=General")
//        let secondVCTitle = NSLocalizedString("secondVCTitle", comment: "EditList def=Icon")
//        let thirdVCTitle = NSLocalizedString("thirdVCTitle", comment: "EditList def=Color")
//        
//        firstViewController.title = firstVCTitle
//        secondViewController.title = secondVCTitle
//        thirdViewController.title = thirdVCTitle
//        
//        firstViewController.generalDelegate = self
//        
//        firstViewController.deleteTheList = self
//        
//        secondViewController.iconDelegate = self
//        thirdViewController.colorDelegate = self
//        
//        self.scrolledToIcons = secondViewController
//        self.scrolledToColors = thirdViewController
//        thirdViewController.receiveColor(name: iconColorName)
//        
//        self.returnGeneralNowDelegate = firstViewController
//        
//        let pagingViewController = PagingViewController(viewControllers: [
//          firstViewController,
//          secondViewController,
//          thirdViewController
//        ])
//        addChild(pagingViewController)
//        view.addSubview(pagingViewController.view)
//        
//        pagingViewController.view.snp.makeConstraints { (make) in
//            make.left.equalToSuperview()
//            make.right.equalToSuperview()
//            make.bottom.equalToSuperview()
////            make.top.equalTo(stretchyView.snp.bottom)
//            
////            make.top.equalTo(quickTourView.snp.bottom)
//        }
//        pagingViewController.textColor = UIColor(named: "PureBlack")!
//        pagingViewController.backgroundColor = UIColor(named: "PureBlank")!
//        pagingViewController.menuBackgroundColor = UIColor(named: "PureBlank")!
//        pagingViewController.selectedTextColor = UIColor(named: "LinkColor")!
//        pagingViewController.selectedTextColor = UIColor(named: "LinkColor")!
//        pagingViewController.selectedBackgroundColor = UIColor(named: "PureBlank")!
//        
//        pagingViewController.delegate = self
//        pagingViewController.contentInteraction = .none
//        
//        
//        pagingViewController.didMove(toParent: self)
//        
//        
//        let symbolConfiguration = UIImage.SymbolConfiguration(pointSize: 55, weight: .semibold)
//        let newImage = UIImage(systemName: iconImageName, withConfiguration: symbolConfiguration)?.withTintColor(UIColor(hexString: iconColorName), renderingMode: .alwaysOriginal)
//        topImageView.image = newImage
//        
//    }
//}
//extension MakeNewList: PagingViewControllerDelegate {
//    func pagingViewController<T>(_ pagingViewController: PagingViewController, didScrollToItem pagingItem: T, startingViewController: UIViewController?, destinationViewController: UIViewController, transitionSuccessful: Bool) where T : PagingItem, T : Comparable, T : Hashable {
//        
//        guard let indexItem = pagingViewController.state.currentPagingItem as? PagingIndexItem else {
//            return
//        }
//        let indexC = indexItem.index
//        
//        if indexC == 1 {
//            scrolledToIcons?.scrolledHere()
//        } else if indexC == 2 {
//            scrolledToColors?.scrolledHere()
//        }
//    }
//}
//
