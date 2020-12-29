//
//  CoachMarksView.swift
//  RoundCoachMark
//
//  Created by Dima Choock on 13/12/2017.
//  Copyright © 2017 GPB DIDZHITAL. All rights reserved.
//

import UIKit

class CoachMarksCanvas: UIView 
{
// MARK: - MARK INFO
    
    var markInfo:CoachMarkInfoView?
    {
        didSet
        {
            resetMarkInfo()
            (markInfo as! UIView).alpha = 0
        }
    }
    private func resetMarkInfo()
    {
        guard let mark_info = markInfo as? UIView else {return}
        mark_info.removeFromSuperview()
        addSubview(mark_info)
        let size = markInfo?.viewSize ?? CGSize(width:100,height:100)

        if let info_h = infoViewH, let info_w = infoViewW
        {
            info_h.constant = size.height
            info_w.constant = size.width
            layoutIfNeeded()
        }
        else
        {
            infoViewH = mark_info.heightAnchor.constraint(equalToConstant: size.height)
            infoViewW = mark_info.widthAnchor.constraint(equalToConstant: size.width)
            infoViewH!.isActive = true
            infoViewW!.isActive = true
        }
        mark_info.constrainCenter(offset:markInfo?.centerOffset ?? CGPoint.zero)
    }
    
// MARK: - CONTROL INTERFACE
    
    func replaceCurrentMark(with mark:CoachMarker.MarkInfo, completion:@escaping ()->Void)
    {
        if let ring = ringView
        {
            ring.openRing(false,
            completion:
            { [weak self] in
                ring.removeFromSuperview()
                self?.show(mark,completion:completion)
            })
            ringView = nil
            (markInfo as! UIView).alpha = 0
            return 
        }
        show(mark,completion:completion)
    }
    
    func show(_ mark:CoachMarker.MarkInfo,completion:@escaping ()->Void)
    {
        guard animate(true) else {return}
        if let info_view = mark.infoView    {markInfo = info_view}
        if let (title,text) = mark.textInfo {markInfo?.setTextInfo(title:title, info:text);resetMarkInfo()}
        if let info = mark.info             {markInfo?.setInfo(info);resetMarkInfo()}
        layoutIfNeeded()
        
        let info_frame = (markInfo as! UIView).frame
        (markInfo as! UIView).alpha = 0
        let ring = CoachRing(controlCenter:mark.position, controlRadius:mark.aperture/2, innerRect:info_frame, outerRect:self.bounds)//, excenterShift:CGPoint(x:0,y:-20), excenterRadius:nil)
        ringView = CoachRingView(frame:self.bounds)
        ringView!.ringGeometry = ring
        ringView!.backgroundColor = UIColor.clear
        resetRingViewParameters()
        insertSubview(ringView!, at:0)
        ringView?.openRing(true,
        completion:
        {
            [weak self] in
            (self?.markInfo as! UIView).alpha = 1
            self?.animate(false)
            completion()
        })
    }
    
    func removeCurrentMark(completion:@escaping ()->Void)
    {
        guard animate(true) else {return} 
        if let ring = ringView
        {
            ring.openRing(false,
            completion:
            { 
                [weak self] in
                ring.removeFromSuperview()
                self?.animate(false)
                completion()
            })
            ringView = nil
            (markInfo as! UIView).alpha = 0
        }
        else
        {
            animate(false)
            completion()
        }
    }
    
    @discardableResult private func animate(_ activate:Bool ) ->Bool
    {
        if      activate && animating  {return false}
        else if activate && !animating {animating = activate;return true}
        else                           {animating = false;return false} 
    }
    
// MARK: - CUSTOMIZABLE PARAMETERS
    
    var ringView:CoachRingView?
    var infoViewH:NSLayoutConstraint?
    var infoViewW:NSLayoutConstraint?
    
    var ringMainColor:UIColor  = UIColor(red:0.000, green:0.387, blue:0.742, alpha: 0.8)
    var ringEchoColor:UIColor  = UIColor.white
    var ringPeriod:Double      = 0.3
    var apPeriod:Double        = 0.4
    var apTravel:CGFloat       = 10
    var ecTravel:CGFloat       = 30
    var ecBeginOpacity:CGFloat = 0.6
    var ecEndOpacity:CGFloat   = 0.0
    
    private func resetRingViewParameters()
    {
        ringView?.ringMainColor    = ringMainColor
        ringView?.ringEchoColor    = ringEchoColor
        ringView?.ringPeriod       = ringPeriod
        ringView?.aperturePeriod   = apPeriod
        ringView?.apertureTravel   = apTravel
        ringView?.echoTravel       = ecTravel
        ringView?.echoBeginOpacity = ecBeginOpacity
        ringView?.echoEndOpacity   = ecEndOpacity
    }

    
// MARK: - INIT
    
    private var animating:Bool = false
    
    required init?(coder aDecoder: NSCoder) 
    {
        super.init(coder: aDecoder)
        translatesAutoresizingMaskIntoConstraints = false
    }
    
    override init(frame: CGRect) 
    {
        super.init(frame: frame)
        translatesAutoresizingMaskIntoConstraints = false
    }

}
