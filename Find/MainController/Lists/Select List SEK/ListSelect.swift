//
//  ListSelect.swift
//  Find
//
//  Created by Andrew on 1/20/20.
//  Copyright © 2020 Andrew. All rights reserved.
//

import UIKit

protocol ListDeletePressed: class {
    func listDeleteButtonPressed()
}

class ListSelect: UIView, ChangeNumberOfSelectedList {
    
    @IBOutlet var contentView: ListSelect!
    
    weak var listDeletePressed: ListDeletePressed?
    func changeLabel(to: Int) {
        if to == 1 {
            listSelectLabel.fadeTransition(0.1)
            
            let oneListSelected = NSLocalizedString("oneListSelected", comment: "ListSelect def=One List Selected")
            listSelectLabel.text = oneListSelected
//            listSelectLabel.text = "\(to) List Selected"
        } else {
            listSelectLabel.fadeTransition(0.1)
            
            let numberListsSelected = NSLocalizedString("%d numberLists",
                                                                         comment:"ListController def=x Lists Selected")
            listSelectLabel.text = String.localizedStringWithFormat(numberListsSelected, to)
//            listSelectLabel.text = "\(to) Lists Selected"
        }
        
    }
    
    func disablePress(disable: Bool) {
        if disable == true {
            deleteButton.isEnabled = false
        } else {
            deleteButton.isEnabled = true
        }
        
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setUp()
    }
    
    init() {
        super.init(frame: .zero)
        setUp()
    }
    private func setUp() {
       // fromNib()
        //self.changeNumberDelegate = self
        clipsToBounds = true
        layer.cornerRadius = 5
        layer.backgroundColor = #colorLiteral(red: 0, green: 0.5981545251, blue: 0.937254902, alpha: 1)
        
        Bundle.main.loadNibNamed("ListsSelect", owner: self, options: nil)
        addSubview(contentView)
        contentView.frame = self.bounds
        contentView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    }
    
    @IBOutlet weak var listSelectLabel: UILabel!
    
    @IBOutlet weak var deleteButton: UIButton!
    
    @IBAction func deletePressed(_ sender: UIButton) {
        listDeletePressed?.listDeleteButtonPressed()
    }
    
}
