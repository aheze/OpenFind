//
//  SettingsMVC+Listen.swift
//  Find
//
//  Created by A. Zheng (github.com/aheze) on 4/4/22.
//  Copyright © 2022 A. Zheng. All rights reserved.
//
    

import UIKit

extension SettingsMainViewController {
    func listen() {
        searchViewModel.fieldsChanged = { [weak self] textChanged in
            guard let self = self else { return }
            
            UIView.animate(withDuration: 0.2) {
                if self.searchViewModel.isEmpty {
                    self.showResults(false)
                } else {
                    self.showResults(true)
                }
            }
        
            if textChanged {

            } else {
                
            }
        }
        
        
    }
}
