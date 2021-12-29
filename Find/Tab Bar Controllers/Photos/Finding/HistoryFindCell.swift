//
//  HistoryFindCell.swift
//  Find
//
//  Created by Zheng on 3/9/20.
//  Copyright © 2020 Andrew. All rights reserved.
//

import UIKit

class HistoryFindCell: UITableViewCell {
    @IBOutlet var shadowView: CellShadowView!
    
    @IBOutlet var photoImageView: UIImageView!
    @IBOutlet var shadowImageView: UIImageView!
    @IBOutlet var starImageView: UIImageView!
    @IBOutlet var cacheImageView: UIImageView!
    
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var numberOfMatchesView: UIView!
    @IBOutlet var numberOfMatchesLabel: UILabel!
    @IBOutlet var textView: UITextView!
    
    @IBOutlet var drawingView: UIView!
    @IBOutlet var baseView: UIView!
}
