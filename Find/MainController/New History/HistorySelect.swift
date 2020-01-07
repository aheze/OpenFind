//
//  HistorySelector.swift
//  Find
//
//  Created by Andrew on 1/6/20.
//  Copyright © 2020 Andrew. All rights reserved.
//

import UIKit

class HistorySelect: UIView {
    
    @IBOutlet var contentView: UIView!
    
    @IBOutlet weak var photoSelectLabel: UILabel!
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    init() {
        super.init(frame: .zero)
        setup()
    }
    
    private func setup() {
       // fromNib()
        print("setUP")
        clipsToBounds = true
        layer.cornerRadius = 5
        layer.backgroundColor = #colorLiteral(red: 0, green: 0.5981545251, blue: 0.937254902, alpha: 1)
        
        Bundle.main.loadNibNamed("HistorySelect", owner: self, options: nil)
        addSubview(contentView)
        contentView.frame = self.bounds
        contentView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    }
//    func fromNib<T : UIView>() -> T? {
//        guard let contentView = Bundle(for: type(of: self)).loadNibNamed(type(of: self).className, owner: self, options: nil)?.first as? T else {
//            return nil
//        }
//        addSubview(contentView)
//        contentView.fillSuperview()
//        return contentView
//    }
}
////
////  Object+ClassName.swift
////  SwiftEntryKit_Example
////
////  Created by Daniel Huri on 4/25/18.
////  Copyright (c) 2018 huri000@gmail.com. All rights reserved.
////
//
//import Foundation
//
//extension NSObject {
//    var className: String {
//        return String(describing: type(of: self))
//    }
//
//    class var className: String {
//        return String(describing: self)
//    }
//}
