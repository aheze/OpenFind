//
//  MakeNewList.swift
//  Find
//
//  Created by Andrew on 1/26/20.
//  Copyright © 2020 Andrew. All rights reserved.
//

import UIKit
import SwiftEntryKit
import Parchment

protocol NewListMade: class {
    func madeNewList(name: String, description: String, contents: [String], imageName: String, imageColor: String)
}
protocol ReturnGeneralNow: class {
    func updateInfo()
}
protocol ScrolledToIcons: class {
    func scrolledHere()
}
protocol ScrolledToColors: class {
    func scrolledHere()
}

class MakeNewList: UIViewController, GetGeneralInfo, GetIconInfo, GetColorInfo, DeleteList {
    

    let originalListName = NSLocalizedString("originalListName", comment: "EditList def=Untitled")
    let originalDescriptionOfList = NSLocalizedString("originalDescriptionOfList", comment: "EditList def=No description...")
    
    lazy var name = originalListName
    lazy var descriptionOfList = originalDescriptionOfList
    
//    var name = "Untitled"
//    var descriptionOfList = "No description..."
    var contents = [String]()
    var iconImageName = "square.grid.2x2"
    var iconColorName = "579f2b"
    var shouldDismiss = true
    
    func returnCompletedList() {
         print("name: \(name), description: \(descriptionOfList), contents: \(contents), imageName: \(iconImageName), imageColor: \(iconColorName)")
         newListDelegate?.madeNewList(name: name, description: descriptionOfList, contents: contents, imageName: iconImageName, imageColor: iconColorName)
         self.dismiss(animated: true, completion: nil)
     }
     
    @IBOutlet weak var stretchyView: UIView!
    
    @IBOutlet weak var stretchyHeight: NSLayoutConstraint!
    
    @IBOutlet weak var topImageView: UIImageView!
    
    
    func returnNewGeneral(nameOfList: String, desc: String, contentsOfList: [String], hasErrors: Bool, overrideMake: Bool) {
        name = nameOfList
        descriptionOfList = desc
        contents = contentsOfList
        
        shouldDismiss = !hasErrors ///dismiss if no errors
        
        
        
        print("Return New General, has errors: \(hasErrors)")
        if overrideMake == true {
            //view.endEditing(true)
            returnCompletedList()
        }
    }
 
    func returnNewIcon(iconName: String) {
        iconImageName = iconName
        let symbolConfiguration = UIImage.SymbolConfiguration(pointSize: 55, weight: .semibold)
        let newImage = UIImage(systemName: iconImageName, withConfiguration: symbolConfiguration)?.withTintColor(UIColor(hexString: iconColorName), renderingMode: .alwaysOriginal)
        topImageView.image = newImage
    }
    
    func returnNewColor(colorName: String) {
        iconColorName = colorName
        let symbolConfiguration = UIImage.SymbolConfiguration(pointSize: 55, weight: .semibold)
        let newImage = UIImage(systemName: iconImageName, withConfiguration: symbolConfiguration)?.withTintColor(UIColor(hexString: iconColorName), renderingMode: .alwaysOriginal)
        topImageView.image = newImage
    }
    
    func deleteList() {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBOutlet weak var headerView: UIView!
    
    
    @IBOutlet weak var cancelButton: UIButton!
    
    @IBAction func cancelButtonPressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
        
    }
    @IBOutlet weak var doneWithListButton: UIButton!
    
    @IBAction func doneWithListPressed(_ sender: Any) {
        returnGeneralNowDelegate?.updateInfo()
        if shouldDismiss == true {
            shouldDismiss = false
            returnCompletedList()
        }
    }
    

    weak var returnGeneralNowDelegate: ReturnGeneralNow?
    weak var scrolledToIcons: ScrolledToIcons?
    weak var scrolledToColors: ScrolledToColors?
    
    
    weak var newListDelegate: NewListMade?

    override func viewDidLoad() {
        super.viewDidLoad()
        setUpViews()
        let defaults = UserDefaults.standard
        let listsViewedBefore = defaults.bool(forKey: "listsBuilderViewedBefore")
        if listsViewedBefore == false {
            defaults.set(true, forKey: "listsBuilderViewedBefore")
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let vc = storyboard.instantiateViewController(withIdentifier: "ListsBuilderTutorialViewController") as! ListsBuilderTutorialViewController
            vc.view.layer.cornerRadius = 10
            vc.view.clipsToBounds = true
            
            var attributes = EKAttributes.centerFloat
            attributes.displayDuration = .infinity
            attributes.entryInteraction = .absorbTouches
            attributes.scroll = .disabled
            attributes.shadow = .active(with: .init(color: .black, opacity: 0.5, radius: 10, offset: .zero))
            attributes.screenBackground = .color(color: EKColor(#colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.3802521008)))
            attributes.entryBackground = .color(color: .white)
            attributes.screenInteraction = .absorbTouches
            attributes.positionConstraints.size.height = .constant(value: screenBounds.size.height - CGFloat(100))
            attributes.positionConstraints.maxSize = .init(width: .constant(value: 600), height: .constant(value: 800))
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
                SwiftEntryKit.display(entry: vc, using: attributes)
            })
        }
    }
    func setUpViews() {
        
        let storyboard1 = UIStoryboard(name: "Main", bundle: nil)
        let firstViewController = storyboard1.instantiateViewController(withIdentifier: "GeneralViewController") as! GeneralViewController
        
        let storyboard2 = UIStoryboard(name: "Main", bundle: nil)
        let secondViewController = storyboard2.instantiateViewController(withIdentifier: "SymbolsViewController") as! SymbolsViewController
        
        let storyboard3 = UIStoryboard(name: "Main", bundle: nil)
        let thirdViewController = storyboard3.instantiateViewController(withIdentifier: "ColorsViewController") as! ColorsViewController

        let firstVCTitle = NSLocalizedString("firstVCTitle", comment: "EditList def=General")
        let secondVCTitle = NSLocalizedString("secondVCTitle", comment: "EditList def=Icon")
        let thirdVCTitle = NSLocalizedString("thirdVCTitle", comment: "EditList def=Color")
        
        firstViewController.title = firstVCTitle
        secondViewController.title = secondVCTitle
        thirdViewController.title = thirdVCTitle
        
        firstViewController.generalDelegate = self
        
        firstViewController.deleteTheList = self
        
        secondViewController.iconDelegate = self
        thirdViewController.colorDelegate = self
        
        self.scrolledToIcons = secondViewController
        self.scrolledToColors = thirdViewController
        thirdViewController.receiveColor(name: iconColorName)
        
        self.returnGeneralNowDelegate = firstViewController
        
        let pagingViewController = FixedPagingViewController(viewControllers: [
          firstViewController,
          secondViewController,
          thirdViewController
        ])
        addChild(pagingViewController)
        view.addSubview(pagingViewController.view)
        
        pagingViewController.view.snp.makeConstraints { (make) in
            make.left.equalToSuperview()
            make.right.equalToSuperview()
            make.bottom.equalToSuperview()
            make.top.equalTo(stretchyView.snp.bottom)
        }
        pagingViewController.textColor = UIColor(named: "PureBlack")!
        pagingViewController.backgroundColor = UIColor(named: "PureBlank")!
        pagingViewController.menuBackgroundColor = UIColor(named: "PureBlank")!
        pagingViewController.selectedTextColor = UIColor(named: "LinkColor")!
        pagingViewController.selectedTextColor = UIColor(named: "LinkColor")!
        pagingViewController.selectedBackgroundColor = UIColor(named: "PureBlank")!
        
        pagingViewController.delegate = self
        pagingViewController.contentInteraction = .none
        
        
        pagingViewController.didMove(toParent: self)
        
        
        let symbolConfiguration = UIImage.SymbolConfiguration(pointSize: 55, weight: .semibold)
        let newImage = UIImage(systemName: iconImageName, withConfiguration: symbolConfiguration)?.withTintColor(UIColor(hexString: iconColorName), renderingMode: .alwaysOriginal)
        topImageView.image = newImage
        
    }
}
extension MakeNewList: PagingViewControllerDelegate {
    func pagingViewController<T>(_ pagingViewController: PagingViewController<T>, didScrollToItem pagingItem: T, startingViewController: UIViewController?, destinationViewController: UIViewController, transitionSuccessful: Bool) where T : PagingItem, T : Comparable, T : Hashable {
        
        guard let indexItem = pagingViewController.state.currentPagingItem as? PagingIndexItem else {
            return
        }
        let indexC = indexItem.index
        
        if indexC == 1 {
            scrolledToIcons?.scrolledHere()
        } else if indexC == 2 {
            scrolledToColors?.scrolledHere()
        }
    }
}

