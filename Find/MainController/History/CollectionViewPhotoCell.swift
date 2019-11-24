//
//  CollectionViewPhotoCell.swift
//  Find
//
//  Created by Andrew on 11/11/19.
//  Copyright © 2019 Andrew. All rights reserved.
//

import UIKit

class CollectionViewPhotoCell: UICollectionViewCell {
    
    
    @IBOutlet weak var imageView: UIImageView!
    
 
    override func awakeFromNib() {
        super.awakeFromNib()

        contentView.translatesAutoresizingMaskIntoConstraints = false

        let leftConstraint = contentView.leftAnchor.constraint(equalTo: leftAnchor)
        let rightConstraint = contentView.rightAnchor.constraint(equalTo: rightAnchor)
        let topConstraint = contentView.topAnchor.constraint(equalTo: topAnchor)
        let bottomConstraint = contentView.bottomAnchor.constraint(equalTo: bottomAnchor)
        NSLayoutConstraint.activate([leftConstraint, rightConstraint, topConstraint, bottomConstraint])
    }
    // override func awakeFromNib() {
       // super.awakeFromNib()
      //  print("awakeNib")
//        let margins = contentView.layoutMarginsGuide
//        imageView.leadingAnchor.constraint(equalTo: margins.leadingAnchor, constant: 0).isActive = true
//        imageView.topAnchor.constraint(equalTo: margins.topAnchor, constant: 0).isActive = true
//        imageView.bottomAnchor.constraint(equalTo: margins.bottomAnchor, constant: 0).isActive = true
//        imageView.trailingAnchor.constraint(equalTo: margins.trailingAnchor, constant: 0).isActive = true

    //}
    
}
