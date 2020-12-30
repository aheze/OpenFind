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
    
    @IBOutlet weak var topImageView: UIImageView! /// show the symbol and color
    @IBOutlet weak var promptLabel: UILabel! /// Edit list or New List
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var saveButton: UIButton!
    
    weak var finishedEditingList: FinishedEditingList?
    weak var newListDelegate: NewListMade?
    
    @IBAction func cancelButtonPressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func saveButtonPressed(_ sender: Any) {
        view.endEditing(true)
        
        
        print("save pressed")
        var newName = generalVC.name
        var newDesc = generalVC.descriptionOfList
        
        let untitledName = NSLocalizedString("untitledName", comment: "GeneralViewController def=Untitled")
        let noDescription = NSLocalizedString("noDescription", comment: "GeneralViewController def=No Description")
        if newName == "" { newName = untitledName }
        if newDesc == "" { newDesc = noDescription }
        
        name = newName
        descriptionOfList = newDesc
        contents = generalVC.contents
        iconImageName = symbolVC.selectedIconName
        iconColorName = colorVC.colorName

        findAndStoreErrors(contentsArray: generalVC.contents)
        if showDoneAlerts() { /// true = has errors
            print("has errors")
        } else {
            print("No errors")
            returnCompletedList()
        }
    }
    
    
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
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if listBuilderType == .editor {
            promptLabel.text = "Edit List"
        } else {
            promptLabel.text = "New List"
        }
        setUpPagingVC()
    }
    
    
    func returnCompletedList() {
        if listBuilderType == .editor {
            print("is editor")
            finishedEditingList?.updateExistingList(name: name, description: descriptionOfList, contents: contents, imageName: iconImageName, imageColor: iconColorName, deleteList: false)
        } else {
            print("make new")
            newListDelegate?.madeNewList(name: name, description: descriptionOfList, contents: contents, imageName: iconImageName, imageColor: iconColorName)
        }
        self.dismiss(animated: true, completion: nil)
        
    }
}

extension ListBuilderViewController: GetGeneralInfo, GetIconInfo, GetColorInfo {
    func returnFinishedGeneral(nameOfList: String, desc: String, contentsOfList: [String]) {
        name = nameOfList
        descriptionOfList = desc
        contents = contentsOfList
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
            self?.dismiss(animated: true, completion: nil)
        }
        
        symbolVC.iconDelegate = self
        colorVC.colorDelegate = self
        
        generalVC.receiveGeneral(nameOfList: name, desc: descriptionOfList, contentsOfList: contents)
//        symbolVC.receiveIcon(name: iconImageName)
//        colorVC.receiveColor(name: iconColorName)
        
        
        symbolVC.selectedIconName = iconImageName
        colorVC.colorName = iconColorName
        print("set colors")
        
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
        pagingViewController.backgroundColor = UIColor.secondarySystemBackground
        pagingViewController.menuBackgroundColor = UIColor.secondarySystemBackground
        pagingViewController.selectedTextColor = UIColor(named: "LinkColor")!
        pagingViewController.selectedBackgroundColor = UIColor.secondarySystemBackground
        pagingViewController.borderColor = UIColor.quaternaryLabel
        pagingViewController.contentInteraction = .none
    
        pagingViewController.didMove(toParent: self)
        
        let symbolConfiguration = UIImage.SymbolConfiguration(pointSize: 55, weight: .semibold)
        let newImage = UIImage(systemName: iconImageName, withConfiguration: symbolConfiguration)?.withTintColor(UIColor(hexString: iconColorName), renderingMode: .alwaysOriginal)
        topImageView.image = newImage
    }
}
