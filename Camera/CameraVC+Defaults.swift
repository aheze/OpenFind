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
        self.listen(to: RealmModelData.cameraStabilizationMode.key, selector: #selector(self.cameraStabilizationModeChanged))
    }

    @objc func findingPrimaryRecognitionLanguageChanged() {}
    
    @objc func findingSecondaryRecognitionLanguageChanged() {}
    
    @objc func cameraStabilizationModeChanged() {
        if let cameraStabilizationMode = Settings.Values.StabilizationMode(rawValue: realmModel.cameraStabilizationMode) {
            livePreviewViewController?.livePreviewView.videoPreviewLayer.connection?.preferredVideoStabilizationMode = cameraStabilizationMode.getAVCaptureVideoStabilizationMode()
        }
    }
}
