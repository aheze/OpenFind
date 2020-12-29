//
//  ListBuilderViewController.swift
//  Find
//
//  Created by Zheng on 12/29/20.
//  Copyright © 2020 Andrew. All rights reserved.
//

import UIKit
import Parchment

protocol FinishedEditingList: class {
    func updateExistingList(name: String, description: String, contents: [String], imageName: String, imageColor: String, deleteList: Bool)
}
protocol NewListMade: class {
    func madeNewList(name: String, description: String, contents: [String], imageName: String, imageColor: String)
}
enum ListBuilderType {
    case editor /// edit existing list
    case maker /// make a new list
}
class ListBuilderViewController: UIViewController {
    
    var listBuilderType = ListBuilderType.editor
    
    @IBOutlet weak var topImageView: UIImageView!
    
    @IBOutlet weak var referenceView: UIView!
    
    lazy var generalVC: GeneralViewController = {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let viewController = storyboard.instantiateViewController(withIdentifier: "GeneralViewController") as! GeneralViewController
        
        return viewController
    }()
    lazy var symbolVC: SymbolsViewController = {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let viewController = storyboard.instantiateViewController(withIdentifier: "SymbolsViewController") as! SymbolsViewController
        
        return viewController
    }()
    lazy var colorVC: ColorsViewController = {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let viewController = storyboard.instantiateViewController(withIdentifier: "ColorsViewController") as! ColorsViewController
        
        return viewController
    }()
    
    
    var name = ""
    var descriptionOfList = ""
    var contents = [String]()
    var iconImageName = "square.grid.2x2"
    var iconColorName = "#579f2b"
    
    var canDismiss = false
    
    weak var finishedEditingList: FinishedEditingList?
    weak var newListDelegate: NewListMade?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUpPagingVC()
    }
    
    
    func returnCompletedList() {
        if listBuilderType == .editor {
            finishedEditingList?.updateExistingList(name: name, description: descriptionOfList, contents: contents, imageName: iconImageName, imageColor: iconColorName, deleteList: false)
        } else {
            newListDelegate?.madeNewList(name: name, description: descriptionOfList, contents: contents, imageName: iconImageName, imageColor: iconColorName)
        }
        self.dismiss(animated: true, completion: nil)
        
    }
}

extension ListBuilderViewController: GetGeneralInfo, GetIconInfo, GetColorInfo {
    func returnNewGeneral(nameOfList: String, desc: String, contentsOfList: [String], hasErrors: Bool, overrideMake: Bool) {
        name = nameOfList
        descriptionOfList = desc
        contents = contentsOfList
        
        canDismiss = !hasErrors ///dismiss if no errors
        print("has errors? \(hasErrors)")
        
        print("Return New General, has errors: \(hasErrors)")
        if overrideMake == true {
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
    
    
    
    func setUpPagingVC() {
        
        let firstVCTitle = NSLocalizedString("firstVCTitle", comment: "EditList def=General")
        let secondVCTitle = NSLocalizedString("secondVCTitle", comment: "EditList def=Icon")
        let thirdVCTitle = NSLocalizedString("thirdVCTitle", comment: "EditList def=Color")
        
        generalVC.title = firstVCTitle
        symbolVC.title = secondVCTitle
        colorVC.title = thirdVCTitle
        
        generalVC.generalDelegate = self
        generalVC.deleteThisList = { [weak self] in
            self?.finishedEditingList?.updateExistingList(name: "", description: "", contents: [""], imageName: "", imageColor: "", deleteList: true)
            self?.presentingViewController?.dismiss(animated: true, completion: nil)
        }
        
        symbolVC.iconDelegate = self
        colorVC.colorDelegate = self
        
        let pagingViewController = PagingViewController(viewControllers: [
            generalVC,
            symbolVC,
            colorVC
        ])
        
        addChild(pagingViewController)
        referenceView.addSubview(pagingViewController.view)
        
        pagingViewController.view.snp.makeConstraints { (make) in
            make.left.equalToSuperview()
            make.right.equalToSuperview()
            make.bottom.equalToSuperview()
            make.top.equalToSuperview()
        }
        
        pagingViewController.textColor = UIColor(named: "PureBlack")!
        pagingViewController.backgroundColor = UIColor(named: "PureBlank")!
        pagingViewController.menuBackgroundColor = UIColor(named: "PureBlank")!
        pagingViewController.selectedTextColor = UIColor(named: "LinkColor")!
        pagingViewController.selectedTextColor = UIColor(named: "LinkColor")!
        pagingViewController.selectedBackgroundColor = UIColor(named: "PureBlank")!
        pagingViewController.contentInteraction = .none
        
        pagingViewController.delegate = self
    
        pagingViewController.didMove(toParent: self)
        
        let symbolConfiguration = UIImage.SymbolConfiguration(pointSize: 55, weight: .semibold)
        let newImage = UIImage(systemName: iconImageName, withConfiguration: symbolConfiguration)?.withTintColor(UIColor(hexString: iconColorName), renderingMode: .alwaysOriginal)
        topImageView.image = newImage
    }
}

extension ListBuilderViewController: PagingViewControllerDelegate {
    func pagingViewController<T>(_ pagingViewController: PagingViewController, didScrollToItem pagingItem: T, startingViewController: UIViewController?, destinationViewController: UIViewController, transitionSuccessful: Bool) where T : PagingItem, T : Comparable, T : Hashable {
        
        guard let indexItem = pagingViewController.state.currentPagingItem as? PagingIndexItem else {
            return
        }
        let indexC = indexItem.index
        
        if indexC == 1 {
            symbolVC.scrolledHere()
        } else if indexC == 2 {
            colorVC.scrolledHere()
        }
    }
}
