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
    
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBAction func xButtonPressed(_ sender: Any) {
        SwiftEntryKit.dismiss()
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        
    }
    
}

class HelpCell: UITableViewCell {
    
    
    @IBOutlet weak var nameLabel: UILabel!
    
}

class HelpController: UIViewController {

    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var descriptionLabel: UILabel!
    
    var titleName = "" {
        didSet {
            titleLabel.text = titleName
        }
    }
    var descName = "" {
        didSet {
            descriptionLabel.text = descName
        }
    }
    
}
