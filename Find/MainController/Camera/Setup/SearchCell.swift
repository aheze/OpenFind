//
//  SearchCell.swift
//  Find
//
//  Created by Zheng on 2/29/20.
//  Copyright © 2020 Andrew. All rights reserved.
//

import UIKit

class SearchCell: UICollectionViewCell {

    @IBOutlet weak var imageView: UIImageView!
    
    @IBOutlet weak var nameLabel: UILabel!
    
//    @IBOutlet weak var labelWidth: NSLayoutConstraint!
    
    @IBOutlet weak var labelRightC: NSLayoutConstraint!
    
    //forces the system to do one layout pass
    var isHeightCalculated: Bool = false
    
    var autoWidth = true
    override func prepareForReuse() {
        super.prepareForReuse()
        print("reuse! search cell")
//        NotificationCenter.default.removeObserver(self)
    }
    
//    @objc func changeWidth(_ notification: Notification) {
//      //  print("receive highlight string errors")
//       // print("Errors? \(notification.userInfo)")
//        print("DELETE")
//        if let data = notification.userInfo as? [Int: Bool] {
//            print("CHANGE STATUS: \(data)")
//            if data[0]! == false {
//                autoWidth = false
//            } else {
//                autoWidth = true
//            }
////            if indexPath >= data[0]! + 1 {
////                indexPath -= 1
////            }
//          //  print("HAS DATA")
//         //   print("data: \(data)")
//        }
//    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        print("AWAKE FROM NIB ")
//        NotificationCenter.default.addObserver(self, selector: #selector(changeWidth), name: .changeSearchListSize, object: nil)
        
    }
    
    
    
//    override func preferredLayoutAttributesFitting(_ layoutAttributes: UICollectionViewLayoutAttributes) -> UICollectionViewLayoutAttributes {
//        //Exhibit A - We need to cache our calculation to prevent a crash.
//        if !isHeightCalculated {
//            setNeedsLayout()
//            layoutIfNeeded()
//            let size = contentView.systemLayoutSizeFitting(layoutAttributes.size)
//            var newFrame = layoutAttributes.frame
//            newFrame.size.width = CGFloat(ceilf(Float(size.width)))
//            layoutAttributes.frame = newFrame
//            isHeightCalculated = true
//        }
//        return layoutAttributes
//    }
    
}
