//
//  SettingsPageView.swift
//  Find
//
//  Created by A. Zheng (github.com/aheze) on 4/4/22.
//  Copyright © 2022 A. Zheng. All rights reserved.
//
    

import SwiftUI

struct SettingsPageView: View {
    var page: SettingsPage
    var sizeChanged: ((CGSize) -> Void)?
    var body: some View {
        Text("HI!!!!!")
            .readSize {
                self.sizeChanged?($0)
            }
    }
}
