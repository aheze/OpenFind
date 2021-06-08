//
//  EmptyListView.swift
//  Find
//
//  Created by Zheng on 6/7/21.
//  Copyright © 2021 Andrew. All rights reserved.
//

import SwiftUI

struct EmptyListView: View {
    
    @ObservedObject var model: PhotosEmptyViewModel
    
    var body: some View {
        
        VStack(alignment: .leading, spacing: 2) {
            ScrollView {
                VStack(spacing: 16) {
                    ForEach(model.cards) { card in
                        HStack(alignment: .top, spacing: 10) {
                            Image(card.type.getName().0)
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 80)
                            
                            VStack(alignment: .leading, spacing: 4) {
                                HStack {
                                    Text(card.type.getName().1)
                                        .font(.system(size: 19, weight: .medium))
                                    Spacer()
                                }
                                
                                Text(card.type.getName().2)
                                    .fixedSize(horizontal: false, vertical: true)
                                    .font(.system(size: 16, weight: .regular))
                                    .foregroundColor(Color(.secondaryLabel))
                                    .multilineTextAlignment(.leading)
                                
                                
                                if card.type != .screenshots {
                                    Button(action: {
                                    }) {
                                        Text("Show me how")
                                            .foregroundColor(Color(card.type.getColor()))
                                    }
                                }
                            }
                            
                        }
                        .transition(AnyTransition.scale.combined(with: .opacity))
                        .padding()
                        
                        .background(Color(.secondarySystemBackground))
                        
                        .cornerRadius(16)
                    }
                }
                .padding(.horizontal, 20)
                
            }
        }
    }
}

struct PhotoTutorialCard: Identifiable {
    let id = UUID()
    var type: PhotoTutorialType
}
enum PhotoTutorialType {
    case starred
    case cached
    case local
    case screenshots
    case all
    
    func getName() -> (String, String, String) {
        switch self {
        case .starred:
            return ("StarredPhotos", "Starred", "Star the photos that you view the most")
        case .cached:
            return ("CachedPhotos", "Cached", "Results will appear instantly for those that are cached")
        case .local:
            return ("LocalPhotos", "Local", "Photos saved from Find will appear here")
        case .screenshots:
            return ("ScreenshotPhotos", "Screenshots", "You screenshots will appear here")
        case .all:
            return ("", "", "")
        }
    }
    
    func getColor() -> (UIColor) {
        switch self {
        case .starred:
            return UIColor(named: "Gold")!
        case .cached:
            return UIColor(named: "100Blue")!
        case .local:
            return UIColor(named: "100DarkBlue")!
        case .screenshots:
            return UIColor(named: "100Purple")!
        case .all:
            return UIColor(named: "TabIconPhotosMain")!
        }
    }
}
