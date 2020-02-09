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
    func madeNewList(name: String, description: String, contents: String, imageName: String, imageColor: String)
}
protocol ReturnGeneralNow: class {
    func updateInfo()
}
protocol ReturnIconNow: class {
    func updateInfo()
}
protocol ReturnColorNow: class {
    func updateInfo()
}
class MakeNewList: UIViewController, GetGeneralInfo, GetIconInfo, GetColorInfo {
    

    
    var name = "Untitled"
    var descriptionOfList = "No description..."
    var contents = ""
    var iconImageName = "square.grid.2x2"
    var iconColorName = "00AEEF"
    var shouldDismiss = true
    
    func returnNewGeneral(nameOfList: String, desc: String, contentsOfList: String, interrupt: Bool) {
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
    func returnCompletedList() {
        print("name: \(name), description: \(descriptionOfList), contents: \(contents), imageName: \(iconImageName), imageColor: \(iconColorName)")
        newListDelegate?.madeNewList(name: name, description: descriptionOfList, contents: contents, imageName: iconImageName, imageColor: iconColorName)
        self.dismiss(animated: true, completion: nil)
    }
    
    func returnNewIcon(iconName: String) {
        iconImageName = iconName
    }
    
    func returnNewColor(colorName: String) {
        iconColorName = colorName
    }
    
    
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var doneWithListButton: UIButton!
    
    @IBAction func doneWithListPressed(_ sender: Any) {
        returnGeneralNowDelegate?.updateInfo()
        returnIconNowDelegate?.updateInfo()
        returnColorNowDelegate?.updateInfo()
//        if contentsTextView.text.isEmpty {
//            SwiftEntryKitTemplates().displaySEK(message: "Can't create a list with no contents!", backgroundColor: #colorLiteral(red: 0.9254902005, green: 0.2352941185, blue: 0.1019607857, alpha: 1), textColor: #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0), location: .top)
//        } else {
//        if shouldDismiss == true {
//            print("SHOULD DISMISS")
//            view.endEditing(true)
//            //print("asdkahskdhaksdhaksjdh")
//            print("name: \(name), description: \(descriptionOfList), contents: \(contents), imageName: \(iconImageName), imageColor: \(iconColorName)")
//            newListDelegate?.madeNewList(name: name, description: descriptionOfList, contents: contents, imageName: iconImageName, imageColor: iconColorName)
//            //self.dismiss(animated: true, completion: nil)
//        }
//        }
    }
    

    weak var returnGeneralNowDelegate: ReturnGeneralNow?
    weak var returnIconNowDelegate: ReturnIconNow?
    weak var returnColorNowDelegate: ReturnColorNow?
    
    weak var newListDelegate: NewListMade?

    override func viewDidLoad() {
        super.viewDidLoad()
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
        self.returnGeneralNowDelegate = firstViewController
        self.returnIconNowDelegate = secondViewController
        self.returnColorNowDelegate = thirdViewController
        
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
        
        doneWithListButton.layer.cornerRadius = 4
    }
}
