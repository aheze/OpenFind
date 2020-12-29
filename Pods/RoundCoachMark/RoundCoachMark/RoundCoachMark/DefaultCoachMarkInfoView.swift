//
//  DefaultCoachMarkInfoView.swift
//  RoundCoachMark
//
//  Created by Dima Choock on 17/12/2017.
//  Copyright © 2017 GPB DIDZHITAL. All rights reserved.
//

import UIKit

class DefaultCoachMarkInfoView: UIView, CoachMarkInfoView 
{
    var titleLabel:UILabel?
    var infoText:UITextView?
    var infoWidth:CGFloat = 0
    
    convenience init(width:CGFloat)
    {
        let frame = CGRect(x: 0, y: 0, width: width, height: 100)
        self.init(frame:frame)
    }
    override init(frame: CGRect) 
    {
        super.init(frame: frame)
        translatesAutoresizingMaskIntoConstraints = false
        backgroundColor = UIColor.clear
        infoWidth = frame.size.width
        
        // Properties:
        titleLabel = UILabel()
        titleLabel?.translatesAutoresizingMaskIntoConstraints = false
        titleLabel?.lineBreakMode = .byWordWrapping
        titleLabel?.numberOfLines = 3
        
        infoText = UITextView()
        infoText?.backgroundColor = UIColor.clear
        infoText?.translatesAutoresizingMaskIntoConstraints = false
        infoText?.textContainer.lineFragmentPadding = 0
        infoText?.isUserInteractionEnabled = false
        infoText?.showsHorizontalScrollIndicator = false
        infoText?.showsVerticalScrollIndicator = false
        
        // Layout:
        self.addSubview(titleLabel!)
        self.addSubview(infoText!)

        titleLabel!.leadingAnchor.constraint(equalTo:self.leadingAnchor, constant:0).isActive = true
        titleLabel!.trailingAnchor.constraint(equalTo:self.trailingAnchor, constant: 0).isActive = true
        titleLabel!.topAnchor.constraint(equalTo: self.topAnchor, constant: 0).isActive = true
        
        infoText!.leadingAnchor.constraint(equalTo:self.leadingAnchor, constant:0).isActive = true
        infoText!.trailingAnchor.constraint(equalTo:self.trailingAnchor, constant: 0).isActive = true
        infoText!.bottomAnchor.constraint(equalTo:self.bottomAnchor, constant: 0).isActive = true
        infoText!.topAnchor.constraint(equalTo: titleLabel!.bottomAnchor, constant: 8).isActive = true
        infoText?.textContainerInset = UIEdgeInsets.zero

    }
    required init?(coder aDecoder: NSCoder) 
    {
        super.init(coder: aDecoder)
        translatesAutoresizingMaskIntoConstraints = false
    }
    
    var viewSize:CGSize      
    {
        guard let title = titleLabel,
              let text = infoText else {return CGSize(width: infoWidth, height: 100)}

        let title_h = title.text?.calculateSize(width:infoWidth, font:title.font).height ?? title.bounds.size.height
        let text_h  = text.text.calculateSize(for:text).height
        return CGSize(width: infoWidth, height: 16 + title_h + text_h)
    }
    var centerOffset:CGPoint
    {
        return CGPoint.zero
    }
    
    func setTextInfo(title:String, info:String)
    {
        titleLabel?.text = title
        infoText?.text = info
    }
    func setTitleStyle(font:UIFont, color:UIColor)
    {
        titleLabel?.font = font
        titleLabel?.textColor = color
    }
    func setInfoStyle(font:UIFont, color:UIColor)
    {
        infoText?.font = font
        infoText?.textColor = color
    }
    
    func setInfo(_ info:Any){}
}
