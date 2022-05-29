//
//  PhotosCellResultsImageView.swift
//  Find
//
//  Created by A. Zheng (github.com/aheze) on 5/28/22.
//  Copyright © 2022 A. Zheng. All rights reserved.
//
    
import SwiftUI

struct PhotosCellResultsImageViewState {
    var title = ""
}

struct PhotosCellResultsImageView: View {
    @ObservedObject var model: PhotosCellImageViewModel
    @ObservedObject var resultsModel: PhotosCellResultsImageViewModel
    @ObservedObject var textModel: EditableTextViewModel
    @ObservedObject var highlightsViewModel: HighlightsViewModel
    @ObservedObject var realmModel: RealmModel
    
    var body: some View {
        let state = getState()
        
        HStack(alignment: .top) {
            PhotosCellImageView(model: model)
                .frame(width: 100)
                .cornerRadius(12)
            
            VStack(spacing: 10) {
                HStack {
                    Text(state.title)
                        .font(UIFont.preferredCustomFont(forTextStyle: .title3, weight: .semibold).font)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    Text(resultsModel.resultsText)
                        .font(UIFont.preferredFont(forTextStyle: .subheadline).font)
                        .foregroundColor(UIColor.secondaryLabel.color)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(
                            Capsule()
                                .fill(UIColor.secondarySystemBackground.color)
                        )
                }
                
                EditableTextView(model: textModel, text: .constant(resultsModel.text))
                    .allowsHitTesting(false)
                
                if let note = resultsModel.note {
                    EditableTextView(model: textModel, text: .constant(note))
                        .overlay(
                            HighlightsView(highlightsViewModel: highlightsViewModel, realmModel: realmModel)
                        )
                        .allowsHitTesting(false)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .padding(6)
                        .overlay(
                            Text("NOTE")
                                .foregroundColor(UIColor.secondaryLabel.color)
                                .font(UIFont.preferredCustomFont(forTextStyle: .caption1, weight: .bold).font)
                                .padding(7)
                                .background(
                                    UIColor.label.color
                                        .cornerRadius(6, corners: .bottomLeft)
                                        .opacity(0.1)
                                )
                            ,
                            alignment: .topTrailing
                        )
                        .background(UIColor.secondarySystemBackground.color)
                        .cornerRadius(10)
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
        .padding(16)
        .background(UIColor.systemBackground.color)
        .cornerRadius(16)
        .edgesIgnoringSafeArea(.all)
    }
    
    func getState() -> PhotosCellResultsImageViewState {
        var state = PhotosCellResultsImageViewState()
        guard let findPhoto = resultsModel.findPhoto else { return state }
        
        state.title = findPhoto.dateString()
        
        return state
    }
}
