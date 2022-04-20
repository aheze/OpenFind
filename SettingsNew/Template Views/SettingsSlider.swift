//
//  SettingsSlider.swift
//  Find
//
//  Created by A. Zheng (github.com/aheze) on 4/4/22.
//  Copyright © 2022 A. Zheng. All rights reserved.
//

import SwiftUI

struct SettingsSlider: View {
    @ObservedObject var model: SettingsViewModel
    @ObservedObject var realmModel: RealmModel
    
    var numberOfSteps: Int?
    var minValue: Double
    var maxValue: Double
    var minSymbol: SettingsRow.Symbol
    var maxSymbol: SettingsRow.Symbol
    var saveAsInt: Bool /// precision
    var storage: KeyPath<RealmModel, Binding<Double>>

    var body: some View {
        Slider(
            value: realmModel[keyPath: storage],
            in: minValue ... maxValue
        ) {
            EmptyView()
        } minimumValueLabel: {
            VStack {
                switch minSymbol {
                case .system(name: let name, weight: let weight):
                    Image(systemName: name)
                        .font(UIFont.preferredCustomFont(forTextStyle: .body, weight: weight).font)
                case .text(string: let string):
                    Text(string)
                }
            }
        } maximumValueLabel: {
            VStack {
                switch maxSymbol {
                case .system(name: let name, weight: let weight):
                    Image(systemName: name)
                        .font(UIFont.preferredCustomFont(forTextStyle: .body, weight: weight).font)
                case .text(string: let string):
                    Text(string)
                }
            }
        }
        .accessibilityElement(children: .combine)
        .padding(SettingsConstants.rowVerticalInsetsFromSlider)
        .padding(SettingsConstants.rowHorizontalInsets)
    }
}
