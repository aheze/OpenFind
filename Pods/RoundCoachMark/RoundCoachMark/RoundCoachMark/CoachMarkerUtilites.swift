//
//  CoachMarkerUtilites.swift
//  RoundCoachMark
//
//  Created by Dima Choock on 17/12/2017.
//  Copyright © 2017 GPB DIDZHITAL. All rights reserved.
//

import Foundation

extension UIView 
{
    func constrainFill(padding:CGPoint) 
    {
        guard superview != nil else {return}
        
        translatesAutoresizingMaskIntoConstraints = false
        leadingAnchor.constraint(equalTo: superview!.leadingAnchor, constant: padding.x).isActive = true
        topAnchor.constraint(equalTo: superview!.topAnchor, constant: padding.y).isActive = true
        trailingAnchor.constraint(equalTo: superview!.trailingAnchor, constant: padding.x).isActive = true
        bottomAnchor.constraint(equalTo: superview!.bottomAnchor, constant: padding.y).isActive = true
    }
    func constrainSize(_ size:CGSize) 
    {
        translatesAutoresizingMaskIntoConstraints = false
        heightAnchor.constraint(equalToConstant: size.height).isActive = true
        widthAnchor.constraint(equalToConstant: size.width).isActive = true
    }
    func constrainCenter(offset:CGPoint)
    {
        guard superview != nil else {return}
        translatesAutoresizingMaskIntoConstraints = false
        centerXAnchor.constraint(equalTo: superview!.centerXAnchor, constant: offset.x).isActive = true
        centerYAnchor.constraint(equalTo: superview!.centerYAnchor, constant:offset.y).isActive = true
    }
}

extension String
{
    func calculateSize (for view:UITextView) ->CGSize
    {
        let insets = view.textContainerInset
        let padding = view.textContainer.lineFragmentPadding * 2
        let probe_size = CGSize(width:view.bounds.width - insets.left - insets.right - padding, height:CGFloat(MAXFLOAT))
        let font = view.font ?? UIFont.systemFont(ofSize:10)
        let size = self.boundingRect(with: probe_size,
                                     options: NSStringDrawingOptions(rawValue: (NSStringDrawingOptions.usesLineFragmentOrigin.rawValue | NSStringDrawingOptions.usesFontLeading.rawValue)),
                                     attributes: [NSAttributedString.Key.font:font],
                                     context: nil).size
        return CGSize(width:size.width,height:size.height + insets.top + insets.bottom)
    }
    func calculateSize(width:CGFloat, font:UIFont) ->CGSize
    {
        let probe_size = CGSize(width:width, height:CGFloat(MAXFLOAT))
        let size = (self + "a").boundingRect(with: probe_size,
                                             options: [NSStringDrawingOptions.usesLineFragmentOrigin,NSStringDrawingOptions.usesFontLeading],
                                             attributes: [NSAttributedString.Key.font:font],
                                             context: nil).size
        return size
    }
}
