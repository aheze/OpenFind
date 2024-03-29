//
//  ListBuilderViewController.swift
//  Find
//
//  Created by Zheng on 12/29/20.
//  Copyright © 2020 Andrew. All rights reserved.
//

import UIKit

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
    
    @IBOutlet var topView: UIView! /// header at the top
    @IBOutlet var topImageView: UIImageView! /// show the symbol and color
    @IBOutlet var promptLabel: UILabel! /// Edit list or New List
    @IBOutlet var cancelButton: UIButton!
    @IBOutlet var saveButton: UIButton!
    
    @IBOutlet var tutorialContainer: UIView!
    @IBOutlet var tutorialContainerHeightC: NSLayoutConstraint!
    
    let defaults = UserDefaults.standard
    
    func animateCloseQuickTour(quickTourView: TutorialHeader) {
        defaults.set(true, forKey: "listsBuilderViewedBefore")
        
        quickTourView.colorViewHeightConst.constant = 0
        tutorialContainerHeightC.constant = 0
        
        UIView.animate(withDuration: 0.5, animations: {
            quickTourView.layoutIfNeeded()
            self.view.layoutIfNeeded()
            quickTourView.startTourButton.alpha = 0
            quickTourView.closeButton.alpha = 0
            
        }) { _ in
            quickTourView.removeFromSuperview()
        }
    }
    
    weak var finishedEditingList: FinishedEditingList?
    weak var newListDelegate: NewListMade?
    
    var donePressed: (() -> Void)?
    @IBAction func cancelButtonPressed(_ sender: Any) {
        donePressed?()
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func saveButtonPressed(_ sender: Any) {
        view.endEditing(true)
        
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
        } else {
            returnCompletedList()
        }
    }
    
    @IBOutlet var referenceView: UIView!
    
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
        
        let listsBuilderViewedBefore = defaults.bool(forKey: "listsBuilderViewedBefore")
        
        if !listsBuilderViewedBefore {
            let quickTourView = TutorialHeader()
            quickTourView.colorView.backgroundColor = #colorLiteral(red: 0.9607843161, green: 0.8247417789, blue: 0.1493863227, alpha: 1)
            
            tutorialContainerHeightC.constant = 50
            tutorialContainer.addSubview(quickTourView)
            
            quickTourView.snp.makeConstraints { make in
                make.top.equalToSuperview()
                make.left.equalToSuperview()
                make.right.equalToSuperview()
                make.height.equalTo(50)
            }
            
            quickTourView.pressed = { [weak self] in
                
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let vc = storyboard.instantiateViewController(withIdentifier: "ListsBuilderTutorialViewController") as! ListsBuilderTutorialViewController
                
                self?.animateCloseQuickTour(quickTourView: quickTourView)
                self?.present(vc, animated: true, completion: nil)
            }
            
            quickTourView.closed = { [weak self] in
                self?.animateCloseQuickTour(quickTourView: quickTourView)
            }
        }

        setupPagingVC()
        
        setupAccessibility()
    }
    
    func returnCompletedList() {
        if listBuilderType == .editor {
            contents = generalVC.contents
            finishedEditingList?.updateExistingList(name: name, description: descriptionOfList, contents: contents, imageName: iconImageName, imageColor: iconColorName, deleteList: false)
        } else {
            newListDelegate?.madeNewList(name: name, description: descriptionOfList, contents: contents, imageName: iconImageName, imageColor: iconColorName)
        }
        donePressed?()
        dismiss(animated: true, completion: nil)
    }
}

extension ListBuilderViewController: GetIconInfo, GetColorInfo {
    func returnNewIcon(iconName: String) {
        iconImageName = iconName
        let symbolConfiguration = UIImage.SymbolConfiguration(pointSize: 55, weight: .semibold)
        let newImage = UIImage(systemName: iconImageName, withConfiguration: symbolConfiguration)?.withTintColor(UIColor(hexString: iconColorName), renderingMode: .alwaysOriginal)
        topImageView.image = newImage
        updateTopImageLabel()
    }
    
    func returnNewColor(colorName: String) {
        iconColorName = colorName
        let symbolConfiguration = UIImage.SymbolConfiguration(pointSize: 55, weight: .semibold)
        let newImage = UIImage(systemName: iconImageName, withConfiguration: symbolConfiguration)?.withTintColor(UIColor(hexString: iconColorName), renderingMode: .alwaysOriginal)
        topImageView.image = newImage
        updateTopImageLabel()
    }
    
    func setupPagingVC() {
        let firstVCTitle = NSLocalizedString("firstVCTitle", comment: "EditList def=General")
        let secondVCTitle = NSLocalizedString("secondVCTitle", comment: "EditList def=Icon")
        let thirdVCTitle = NSLocalizedString("thirdVCTitle", comment: "EditList def=Color")
        
        generalVC.title = firstVCTitle
        symbolVC.title = secondVCTitle
        colorVC.title = thirdVCTitle
        
        generalVC.deleteThisList = { [weak self] in
            self?.finishedEditingList?.updateExistingList(name: "", description: "", contents: [""], imageName: "", imageColor: "", deleteList: true)
            self?.dismiss(animated: true, completion: nil)
        }
        
        symbolVC.iconDelegate = self
        colorVC.colorDelegate = self
        
        generalVC.receiveGeneral(nameOfList: name, desc: descriptionOfList, contentsOfList: contents)
        
        symbolVC.selectedIconName = iconImageName
        colorVC.colorName = iconColorName
        
        let pagingViewController = PagingViewController(viewControllers: [
            generalVC,
            symbolVC,
            colorVC
        ])
        
        addChild(pagingViewController)
        referenceView.addSubview(pagingViewController.view)
        
        pagingViewController.view.snp.makeConstraints { make in
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
