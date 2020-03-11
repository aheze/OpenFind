//
//  FindBar.swift
//  Find
//
//  Created by Zheng on 3/9/20.
//  Copyright © 2020 Andrew. All rights reserved.
//

import UIKit
import SwiftEntryKit

class FindBar: UIView, UISearchBarDelegate {
    
    
//    override func awakeFromNib() {
//        super.awakeFromNib()
//        
//        print("AWAKE!!")
//        
//        
//        
//        
//    }
    
    @IBOutlet var contentView: FindBar!
    
    @IBOutlet weak var searchBar: UISearchBar!
    
    
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
        
        
        
        Bundle.main.loadNibNamed("FindBar", owner: self, options: nil)
        addSubview(contentView)
        contentView.frame = self.bounds
        contentView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
//        searchBar.searchTextField.backgroundColor = .red
        searchBar.searchTextField.backgroundColor = UIColor(named: "Gray1")
//        searchBar.tintColor = .red
        searchBar.barTintColor = UIColor(named: "Gray3")
        searchBar.layer.borderWidth = 1
        searchBar.layer.borderColor = UIColor(named: "Gray3")?.cgColor
//        searchBar.backgroundColor = .red
        
//        searchBar.layer.cornerRadius = 5
    }
//    public func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
//            searchBar.setShowsCancelButton(true, animated: true)
//        }
//
//        public func searchBarShouldEndEditing(_ searchBar: UISearchBar) -> Bool {
//            searchBar.setShowsCancelButton(false, animated: true)
//
//            return true
//        }
//    //    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
//    //        searchBar.showsCancelButton = true
//    //    }
//        func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
//            searchBar.resignFirstResponder()
//            // Stop doing the search stuff
//            // and clear the text in the search bar
//    //        searchBar.searchTextField.endEditing(true)
//    //        // Hide the cancel button
//    //        searchBar.showsCancelButton = false
//            // You could also change the position, frame etc of the searchBar
//        }
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    
    
}

