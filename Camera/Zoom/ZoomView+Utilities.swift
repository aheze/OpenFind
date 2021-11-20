//
//  ZoomView+Utilities.swift
//  Camera
//
//  Created by Zheng on 11/20/21.
//  Copyright © 2021 Andrew. All rights reserved.
//

import UIKit

extension CGFloat {
    var clean: String {
        let double = Double(self)
        return self.truncatingRemainder(dividingBy: 1) == 0 ? String(format: "%.0f", self) : String(double)
    }
}
extension Double {
    func truncate(places : Int)-> Double {
        return Double(floor(pow(10.0, Double(places)) * self)/pow(10.0, Double(places)))
    }
}
extension CGFloat {
    var string: String {
        let value = Double(self).truncate(places: 1)
        return "\(value)"
    }
}
