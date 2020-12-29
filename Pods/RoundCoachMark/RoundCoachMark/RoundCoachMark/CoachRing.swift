//
//  CoachCircle.swift
//  RoundCoachMark
//
//  Created by Dima Choock on 13/12/2017.
//  Copyright © 2017 GPB DIDZHITAL. All rights reserved.
//

import Foundation

public struct CoachRing
{
    public var radius:CGFloat = 0
    public var center:CGPoint = CGPoint.zero
    public let controlCenter:CGPoint
    public let controlRadius:CGFloat
    
    static let contentInset:CGFloat = 20
    
    public init?(controlCenter c:CGPoint, controlRadius cr:CGFloat, innerRect ir:CGRect, outerRect or:CGRect, overlappingAllowed:Bool = true, excenterShift:CGPoint? = nil, excenterRadius:CGFloat? = nil) 
    {
        let cd = 2*cr
        if !overlappingAllowed
        {
            let control_bb = CGRect(origin:CGPoint(x:c.x-cr,y:c.y-cr), size:CGSize(width:cd, height:cd))
            if ir.intersects(control_bb) {return nil}
        }
        
        self.controlCenter = c
        self.controlRadius = cr
        
        self.center = defineCenter(excenterShift,excenterRadius)
        self.radius = defineRadius(self.center, ir)
    }
    
    private func defineCenter(_ excenterShift:CGPoint?, _ excenterRadius:CGFloat?) ->CGPoint
    {
        guard let es = excenterShift
        else
        {
            return controlCenter
        }
        let s_center = CGPoint(x: controlCenter.x+es.x, y: controlCenter.y+es.y)
        guard let er = excenterRadius
        else
        {
            return s_center
        }
        
        let span = UInt32(er*100)
        let half_span = UInt32(er*50)
        let dx = CGFloat(half_span - arc4random_uniform(span))/50.0
        let dy = CGFloat(half_span - arc4random_uniform(span))/50.0
        
        return CGPoint(x: s_center.x+dx, y: s_center.y+dy)
    }
    
    private func defineRadius(_ center:CGPoint, _ ir:CGRect) ->CGFloat
    {
        var max_distance:CGFloat = 0
        let corners = [ir.origin, CGPoint(x:ir.minX,y:ir.maxY),CGPoint(x:ir.maxX,y:ir.minY),CGPoint(x:ir.maxX,y:ir.maxY)]
        for corner in corners
        {
            let distance = corner.distance(to:center)
            max_distance = max_distance < distance ? distance : max_distance
        }
        return max_distance + CoachRing.contentInset
    }
}

extension CGPoint 
{
    func distance(to p:CGPoint) -> CGFloat 
    {
        return sqrt(pow(x - p.x, 2) + pow(y - p.y, 2))
    }
}
