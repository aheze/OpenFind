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
                        .font(UIFont.preferredFont(forTextStyle: .footnote).font)
                        .foregroundColor(UIColor.secondaryLabel.color)
                        .background(
                            Capsule()
                                .fill(UIColor.secondarySystemBackground.color)
                                .padding(.horizontal, -12)
                                .padding(.vertical, -6)
                        )
                        .padding(.trailing, 12)
                }
                
                VStack(spacing: PhotosResultsCellConstants.rightSpacing) {
                    if resultsModel.resultsFoundInText {
                        EditableTextView(model: textModel, text: .constant(resultsModel.text))
                            .background(
                                HighlightsView(highlightsViewModel: highlightsViewModel, realmModel: realmModel)
                            )
                            .allowsHitTesting(false)
                    }
                
                    if let note = resultsModel.note {
                        EditableTextView(model: textModel, text: .constant(note))
                            .allowsHitTesting(false)
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .padding(6)
                            .overlay(
                                Text("NOTE")
                                    .foregroundColor(resultsModel.resultsFoundInNote ? .accent : UIColor.secondaryLabel.color)
                                    .font(UIFont.preferredCustomFont(forTextStyle: .caption1, weight: .bold).font)
                                    .padding(7)
                                    .background(
                                        VStack {
                                            if resultsModel.resultsFoundInNote {
                                                Color.accent
                                                    .opacity(0.1)
                                            } else {
                                                UIColor.label.color
                                                    .opacity(0.1)
                                            }
                                        }
                                        .cornerRadius(6, corners: .bottomLeft)
                                    ),
                                
                                alignment: .topTrailing
                            )
                            .background(UIColor.secondarySystemBackground.color)
                            .cornerRadius(10)
                            .frame(height: PhotosResultsCellConstants.noteHeight)
                    }
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
        .padding(12)
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
