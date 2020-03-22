//
//  EditListViewController.swift
//  Find
//
//  Created by Zheng on 2/15/20.
//  Copyright © 2020 Andrew. All rights reserved.
//

import UIKit
import Parchment


protocol ReceiveGeneral: class {
    func receiveGeneral(nameOfList: String, desc: String, contentsOfList: [String])
}
protocol ReceiveIcon: class {
    func receiveIcon(name: String)
}
protocol ReceiveColor: class {
    func receiveColor(name: String)
}


protocol ListFinishedEditing: class {
    func updateExistingList(name: String, description: String, contents: [String], imageName: String, imageColor: String)
}
protocol TellControllerToDeleteList: class {
    func deleteTheList()
}

class EditListViewController: UIViewController, GetGeneralInfo, GetIconInfo, GetColorInfo, DeleteList {
    
    @IBOutlet weak var headerView: UIView!
    
    @IBOutlet weak var saveButton: UIButton!
    
    @IBOutlet weak var cancelButton: UIButton!
    
    @IBAction func savePressed(_ sender: Any) {
        print("done pressed, waiting")
        
        returnGeneralNowDelegate?.updateInfo()
//        returnIconNowDelegate?.updateInfo()
//        returnColorNowDelegate?.updateInfo()
        
        if shouldDismiss == true {
            shouldDismiss = false
            print(shouldDismiss)
            returnCompletedList()
        }
        
        
    }
    weak var finalDeleteList: TellControllerToDeleteList?
    
    @IBOutlet weak var stretchyView: UIView!
    
    @IBOutlet weak var topImageView: UIImageView!
    
    @IBAction func cancelPressed(_ sender: Any) {
        presentingViewController?.dismiss(animated: true, completion: nil)
    }

    weak var returnGeneralNowDelegate: ReturnGeneralNow?
//    weak var returnIconNowDelegate: ReturnIconNow?
//    weak var returnColorNowDelegate: ReturnColorNow?
    
    weak var populateGeneral: ReceiveGeneral?
    weak var populateIcon: ReceiveIcon?
    weak var populateColor: ReceiveColor?
    
    weak var scrolledToIcons: ScrolledToIcons?
    weak var scrolledToColors: ScrolledToColors?

   // var shouldDismiss = false
    
    weak var finishedEditingList: ListFinishedEditing?
    
    var name = "Untitled"
    var descriptionOfList = "No description..."
    var contents = [String]()
    var iconImageName = "square.grid.2x2"
    var iconColorName = "#579f2b"
    
    var shouldDismiss = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        saveButton.layer.cornerRadius = 6
//        cancelButton.layer.cornerRadius = 6
        setUpViews()
        
        populateGeneral?.receiveGeneral(nameOfList: name, desc: descriptionOfList, contentsOfList: contents)
        populateIcon?.receiveIcon(name: iconImageName)
        populateColor?.receiveColor(name: iconColorName)
        
    }
    func setUpViews() {
        let storyboard1 = UIStoryboard(name: "Main", bundle: nil)
        let firstViewController = storyboard1.instantiateViewController(withIdentifier: "GeneralViewController") as! GeneralViewController
        
        let storyboard2 = UIStoryboard(name: "Main", bundle: nil)
        let secondViewController = storyboard2.instantiateViewController(withIdentifier: "SymbolsViewController") as! SymbolsViewController
        
        let storyboard3 = UIStoryboard(name: "Main", bundle: nil)
        let thirdViewController = storyboard3.instantiateViewController(withIdentifier: "ColorsViewController") as! ColorsViewController

        firstViewController.title = "General"
        secondViewController.title = "Icon"
        thirdViewController.title = "Color"
        
        firstViewController.generalDelegate = self
        
        firstViewController.deleteTheList = self
        
        secondViewController.iconDelegate = self
        thirdViewController.colorDelegate = self
        
//        self.returnInfoNowDelegate = firstViewController
//        self.returnInfoNowDelegate = secondViewController
//        self.returnInfoNowDelegate = thirdViewController
        self.scrolledToIcons = secondViewController
        self.scrolledToColors = thirdViewController
    
        self.populateGeneral = firstViewController
        self.populateIcon = secondViewController
        self.populateColor = thirdViewController
        
        self.returnGeneralNowDelegate = firstViewController
//        self.returnIconNowDelegate = secondViewController
//        self.returnColorNowDelegate = thirdViewController
            
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
        pagingViewController.contentInteraction = .none
        
        pagingViewController.delegate = self
    
        pagingViewController.didMove(toParent: self)
        
        let symbolConfiguration = UIImage.SymbolConfiguration(pointSize: 55, weight: .semibold)
        let newImage = UIImage(systemName: iconImageName, withConfiguration: symbolConfiguration)?.withTintColor(UIColor(hexString: iconColorName), renderingMode: .alwaysOriginal)
        //self.imageView.image = newImage
        topImageView.image = newImage
        // doneWithListButton.layer.cornerRadius = 4
    }
    
    func deleteList() {
        finalDeleteList?.deleteTheList()
        print("delete sdfkdhfksdhfkjskdjhfkjsd kjsdhk sdf")
        presentingViewController?.dismiss(animated: true, completion: nil)
    }
    func returnNewGeneral(nameOfList: String, desc: String, contentsOfList: [String], hasErrors: Bool, overrideMake: Bool) {
        name = nameOfList
        descriptionOfList = desc
        contents = contentsOfList
        
        shouldDismiss = !hasErrors ///dismiss if no errors
        print("has errors? \(hasErrors)")
        
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
        //self.imageView.image = newImage
        topImageView.image = newImage
    }
   
    func returnNewColor(colorName: String) {
        iconColorName = colorName
        let symbolConfiguration = UIImage.SymbolConfiguration(pointSize: 55, weight: .semibold)
        let newImage = UIImage(systemName: iconImageName, withConfiguration: symbolConfiguration)?.withTintColor(UIColor(hexString: iconColorName), renderingMode: .alwaysOriginal)
        //self.imageView.image = newImage
        topImageView.image = newImage
    }
    
    func returnCompletedList() {
        finishedEditingList?.updateExistingList(name: name, description: descriptionOfList, contents: contents, imageName: iconImageName, imageColor: iconColorName)
        presentingViewController?.dismiss(animated: true, completion: nil)
        print("Completed. name: \(name), description: \(descriptionOfList), contents: \(contents), imageName: \(iconImageName), imageColor: \(iconColorName)")
       // newListDelegate?.madeNewList(name: name, description: descriptionOfList, contents: contents, imageName: iconImageName, imageColor: iconColorName)
        //self.dismiss(animated: true, completion: nil)
    }

}
extension EditListViewController: PagingViewControllerDelegate {
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
