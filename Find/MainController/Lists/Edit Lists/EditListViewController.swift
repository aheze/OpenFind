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
    func receiveGeneral(name: String, desc: String, contents: [String])
}
protocol ReceiveIcon: class {
    func receiveIcon(name: String)
}
protocol ReceiveColor: class {
    func receiveColor(name: String)
}


protocol ListFinishedEdiding: class {
    func updateExistingList(name: String, description: String, contents: [String], imageName: String, imageColor: String)
}

class EditListViewController: UIViewController, GetGeneralInfo, GetIconInfo, GetColorInfo {
    
    @IBOutlet weak var headerView: UIView!
    
    @IBOutlet weak var saveButton: UIButton!
    
    @IBOutlet weak var cancelButton: UIButton!
    
    @IBAction func savePressed(_ sender: Any) {
    }
    
    
    @IBAction func cancelPressed(_ sender: Any) {
        presentingViewController?.dismiss(animated: true, completion: nil)
    }

    
    weak var populateGeneral: ReceiveGeneral?
    weak var populateIcon: ReceiveIcon?
    weak var populateColor: ReceiveColor?
    
    var name = "Untitled"
    var descriptionOfList = "No description..."
    var contents = [String]()
    var iconImageName = "square.grid.2x2"
    var iconColorName = "00AEEF"
    var shouldDismiss = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        saveButton.layer.cornerRadius = 4
        cancelButton.layer.cornerRadius = 4
        setUpViews()
        
        
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
            secondViewController.iconDelegate = self
            thirdViewController.colorDelegate = self
            
    //        self.returnInfoNowDelegate = firstViewController
    //        self.returnInfoNowDelegate = secondViewController
    //        self.returnInfoNowDelegate = thirdViewController
            self.populateGeneral = firstViewController
            self.populateIcon = secondViewController
            self.populateColor = thirdViewController
            
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
                make.top.equalTo(headerView.snp.bottom)
            }
            
            pagingViewController.didMove(toParent: self)
            
            // doneWithListButton.layer.cornerRadius = 4
        }
    
    func returnNewGeneral(nameOfList: String, desc: String, contentsOfList: [String], interrupt: Bool) {
        name = nameOfList
        descriptionOfList = desc
        contents = contentsOfList
        shouldDismiss = !interrupt
        print("sdfk")
        if shouldDismiss == true {
            view.endEditing(true)
            returnCompletedList()
        }
    }
       
       
    func returnNewIcon(iconName: String) {
        iconImageName = iconName
    }
   
    func returnNewColor(colorName: String) {
        iconColorName = colorName
    }
    
    func returnCompletedList() {
        print("name: \(name), description: \(descriptionOfList), contents: \(contents), imageName: \(iconImageName), imageColor: \(iconColorName)")
       // newListDelegate?.madeNewList(name: name, description: descriptionOfList, contents: contents, imageName: iconImageName, imageColor: iconColorName)
        self.dismiss(animated: true, completion: nil)
    }
    
    
    
}
