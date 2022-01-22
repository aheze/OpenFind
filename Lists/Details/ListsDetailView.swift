//
//  ListsDetailView.swift
//  Find
//
//  Created by A. Zheng (github.com/aheze) on 1/21/22.
//  Copyright © 2022 A. Zheng. All rights reserved.
//


import SwiftUI

struct ListsDetailView: View {
    @ObservedObject var model: ListsDetailViewModel
    var body: some View {
        ScrollView {
            VStack {
                Text("List: \(model.list.name)")
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .padding(.top, model.topContentInset)
            .onOffsetChange { offset in
                model.scrollViewOffsetUpdated(offset)
            }
        }
        .background(Color(UIColor.secondarySystemBackground))
        .coordinateSpace(name: "scroll")
    }
}
