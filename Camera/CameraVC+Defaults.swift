//
//  CameraVC+Defaults.swift
//  Find
//
//  Created by A. Zheng (github.com/aheze) on 4/12/22.
//  Copyright © 2022 A. Zheng. All rights reserved.
//

import UIKit

extension CameraViewController {
    func listenToDefaults() {
        self.listen(to: RealmModelData.findingPrimaryRecognitionLanguage.key, selector: #selector(self.findingPrimaryRecognitionLanguageChanged))
        self.listen(to: RealmModelData.findingSecondaryRecognitionLanguage.key, selector: #selector(self.findingSecondaryRecognitionLanguageChanged))
    }

    @objc func findingPrimaryRecognitionLanguageChanged() {
        
    }
    
    @objc func findingSecondaryRecognitionLanguageChanged() {
        
    }
}
