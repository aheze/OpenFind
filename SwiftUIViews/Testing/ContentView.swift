//
//  ContentView.swift
//  Find
//
//  Created by A. Zheng (github.com/aheze) on 12/31/21.
//  Copyright © 2021 A. Zheng. All rights reserved.
//
    

import SwiftUI

struct ContentView: View {
    @StateObject var model = ColorPickerViewModel()
    var body: some View {
//        ProgressLineViewTester()
//        FindIconView(color: 0x00aeef)
//            .frame(width: 30, height: 30)
//        ColorPickerView(model: model)
        SliderViewTester()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
