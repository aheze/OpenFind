//
//  SearchVC+Defaults.swift
//  Find
//
//  Created by A. Zheng (github.com/aheze) on 4/12/22.
//  Copyright © 2022 A. Zheng. All rights reserved.
//
    
import UIKit

extension SearchViewController {
    func listenToDefaults() {
        self.listen(
            to: RealmModelData.findingKeepWhitespace.key,
            selector: #selector(self.findingKeepWhitespaceChanged)
        )
        self.listen(
            to: RealmModelData.findingMatchAccents.key,
            selector: #selector(self.findingMatchAccentsChanged)
        )
        self.listen(
            to: RealmModelData.findingMatchCase.key,
            selector: #selector(self.findingMatchCaseChanged)
        )
        self.listen(
            to: RealmModelData.findingFilterLists.key,
            selector: #selector(self.findingFilterListsChanged)
        )
    }

    @objc func findingKeepWhitespaceChanged() {}
    
    @objc func findingMatchAccentsChanged() {}
    
    @objc func findingMatchCaseChanged() {}
    
    @objc func findingFilterListsChanged() {}
}
