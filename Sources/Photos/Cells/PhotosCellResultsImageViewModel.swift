//
//  PhotosCellResultsImageViewModel.swift
//  Find
//
//  Created by A. Zheng (github.com/aheze) on 5/28/22.
//  Copyright © 2022 A. Zheng. All rights reserved.
//
    
import UIKit

class PhotosCellResultsImageViewModel: ObservableObject {
    @Published var findPhoto: FindPhoto?
    @Published var resultsText = ""
    @Published var text = ""
    @Published var resultsFoundInText = false
    @Published var note: String?
    @Published var resultsFoundInNote = false
    
    var getImageFrame: (() -> CGRect)?
    
    @Published var imageSize: CGSize?
    
    init() {
        getImageFrame = { [weak self] in
            guard let self = self else { return .zero }
            let imageSize = self.imageSize ?? .zero
            let frame = CGRect(
                x: 12,
                y: 12,
                width: imageSize.width,
                height: imageSize.height
            )
            
            return frame
        }
    }
}
