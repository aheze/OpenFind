//
//  RectOverlay.swift
//  Find
//
//  Created by Andrew on 9/10/19.
//  Copyright © 2019 Andrew. All rights reserved.
//

import UIKit
import ARKit
extension ViewController {
    
    
    
    func getRect(size: CGSize) -> SCNShape {
        
        //.2
        
        var cwfirst = size.width
        var chfirst = size.height
        let widthToHeightRatio = chfirst / cwfirst
        cwfirst = 0.21
        chfirst = cwfirst * widthToHeightRatio
        
        
        let cw = cwfirst / 2
        let ch = chfirst / 2
        print(size)
        let ptA = CGPoint(x: -cw, y: ch)
        let ptB = CGPoint(x: cw, y: ch)
        let ptC = CGPoint(x: cw, y: -ch)
        let ptD = CGPoint(x: -cw, y: -ch)
        
        
        
      //  let abw = CGFloat(0.005)  //border width of corner arc
        //let abl = CGFloat(0.040)  //4 centimeters, length from outermost point
        //let ablS = CGFloat(0.035) //3.5 cm, length fron innermost point (bl minus borderwidth)
        let bw = CGFloat(cwfirst / 50)
        let bl = CGFloat(bw * 6)
        let blS = CGFloat(bl - bw)
        
        let p1 = CGPoint(x: ptA.x - bw, y: ptA.y + bw)
        let p2 = CGPoint(x: ptA.x + blS, y: ptA.y + bw)
        let p3 = CGPoint(x: ptA.x + blS, y: ptA.y)
        let p4 = CGPoint(x: ptA.x, y: ptA.y - blS)
        let p5 = CGPoint(x: ptA.x - bw, y: ptA.y - blS)
        
        let p6 = CGPoint(x: ptB.x - blS, y: ptB.y + bw)
        let p7 = CGPoint(x: ptB.x + bw, y: ptB.y + bw)
        let p8 = CGPoint(x: ptB.x + bw, y: ptB.y - blS)
        let p9 = CGPoint(x: ptB.x, y: ptB.y - blS)
        let p10 = CGPoint(x: ptB.x - blS, y: ptB.y)
        
        let p11 = CGPoint(x: ptC.x + bw, y: ptC.y + blS)
        let p12 = CGPoint(x: ptC.x + bw, y: ptC.y - bw)
        let p13 = CGPoint(x: ptC.x - blS, y: ptC.y - bw)
        let p14 = CGPoint(x: ptC.x - blS, y: ptC.y)
        let p15 = CGPoint(x: ptC.x, y: ptC.y + blS)
        
        let p16 = CGPoint(x: ptD.x, y: ptD.y + blS)
        let p17 = CGPoint(x: ptD.x + blS, y: ptD.y)
        let p18 = CGPoint(x: ptD.x + blS, y: ptD.y - bw)
        let p19 = CGPoint(x: ptD.x - bw, y: ptD.y - bw)
        let p20 = CGPoint(x: ptD.x - bw, y: ptD.y + blS)
        
        
        let edgeWidth = bw / 2 // edge (the border)
        let ewS = (bw - CGFloat(edgeWidth)) / 2 //currently 1.5 (distance from border to a side of the edge)
        
        let p21 = CGPoint(x: p3.x, y: p3.y + ewS)
        let p22 = CGPoint(x: p2.x, y: p2.y - ewS)
        
        let p23 = CGPoint(x: p6.x, y: p6.y - ewS)
        let p24 = CGPoint(x: p10.x, y: p10.y + ewS)
        
        let p25 = CGPoint(x: p9.x + ewS, y: p9.y)
        let p26 = CGPoint(x: p8.x - ewS, y: p8.y)
        
        let p27 = CGPoint(x: p15.x + ewS, y: p15.y)
        let p28 = CGPoint(x: p11.x - ewS, y: p11.y)
        
        
        let p29 = CGPoint(x: p14.x, y: p14.y - ewS)
        let p30 = CGPoint(x: p13.x, y: p13.y + ewS)
        
        let p31 = CGPoint(x: p17.x, y: p17.y - ewS)
        let p32 = CGPoint(x: p18.x, y: p18.y + ewS)
        
        let p33 = CGPoint(x: p16.x - ewS, y: p16.y)
        let p34 = CGPoint(x: p20.x + ewS, y: p20.y)
        
        let p35 = CGPoint(x: p5.x + ewS, y: p5.y)
        let p36 = CGPoint(x: p4.x - ewS, y: p4.y)
        
        let path = UIBezierPath()
        path.move(to: p1)
        path.addLine(to: p2)
        path.addLine(to: p22)
        path.addLine(to: p23)
        path.addLine(to: p6)
        path.addLine(to: p7)
        path.addLine(to: p8)
        path.addLine(to: p26)
        path.addLine(to: p28)
        path.addLine(to: p11)
        path.addLine(to: p12)
        path.addLine(to: p13)
        path.addLine(to: p30)
        path.addLine(to: p32)
        path.addLine(to: p18)
        path.addLine(to: p19)
        path.addLine(to: p20)
        path.addLine(to: p34)
        path.addLine(to: p35)
        path.addLine(to: p5)
        path.close()
        
    
        let cutoutPath = UIBezierPath()
        cutoutPath.move(to: ptA)
        cutoutPath.addLine(to: p3)
        cutoutPath.addLine(to: p21)
        cutoutPath.addLine(to: p24)
        cutoutPath.addLine(to: p10)
        cutoutPath.addLine(to: ptB)
        cutoutPath.addLine(to: p9)
        cutoutPath.addLine(to: p25)
        cutoutPath.addLine(to: p27)
        cutoutPath.addLine(to: p15)
        cutoutPath.addLine(to: ptC)
        cutoutPath.addLine(to: p14)
        cutoutPath.addLine(to: p29)
        cutoutPath.addLine(to: p31)
        cutoutPath.addLine(to: p17)
        cutoutPath.addLine(to: ptD)
        cutoutPath.addLine(to: p16)
        cutoutPath.addLine(to: p33)
        cutoutPath.addLine(to: p36)
        cutoutPath.close()
        
        path.append(cutoutPath.reversing())
        path.usesEvenOddFillRule = false
        
        
        let shape = SCNShape(path: path, extrusionDepth: 0.001)
        let color = #colorLiteral(red: 0, green: 0.7389578223, blue: 0.9509587884, alpha: 1)
        shape.firstMaterial?.diffuse.contents = color
        
        return shape
    }
}
