//
//  SettingsCustomView.swift
//  Find
//
//  Created by A. Zheng (github.com/aheze) on 4/4/22.
//  Copyright © 2022 A. Zheng. All rights reserved.
//
    

import SwiftUI

struct SettingsCustomView: View {
    let identifier: AnyHashable
    var body: some View {
        Text(verbatim: "Custom view: \(identifier)")
    }
}
