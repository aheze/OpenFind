//
//  HelpControllers.swift
//  Find
//
//  Created by Zheng on 2/21/20.
//  Copyright © 2020 Andrew. All rights reserved.
//

import UIKit
import SwiftEntryKit


class DefaultHelpController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var arrayOfHelp = [String]()
    var indexToData = [String]()
    
    var currentPath = -1
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        arrayOfHelp.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "HelpCellID") as! HelpCell
        cell.nameLabel.text = arrayOfHelp[indexPath.row]
        return cell
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let sizeOfWidth = tableView.bounds.width - 32
        let baseHeight = arrayOfHelp[indexPath.row].heightWithConstrainedWidth(width: sizeOfWidth, font: UIFont.systemFont(ofSize: 18))
        return baseHeight + 32
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        currentPath = indexPath.row
        performSegue(withIdentifier: "showHelpController", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showHelpController" {
            print("help pressed")
            let destinationVC = segue.destination as! HelpController
            destinationVC.titleName = arrayOfHelp[currentPath]
            destinationVC.descName = indexToData[currentPath]
        }
    }
    
    
    @IBOutlet weak var tableView: UITableView!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(closeTapped))
//        navigationController?.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(closeTapped))

    }
    @objc func closeTapped() {
        SwiftEntryKit.dismiss()
    }
}

class HelpCell: UITableViewCell {
    
    
    @IBOutlet weak var nameLabel: UILabel!
    
}

class HelpController: UIViewController {

    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var descriptionLabel: UILabel!
    
    var titleName = "" 
    var descName = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.largeTitleDisplayMode = .never
        titleLabel.text = titleName
        descriptionLabel.text = descName
    }
    
}
