//
//  PhotoSlidesVC+NavBar.swift
//  Find
//
//  Created by Zheng on 1/21/21.
//  Copyright © 2021 Andrew. All rights reserved.
//

import UIKit
import SnapKit

extension PhotoSlidesViewController {
    func setNavigationBar() {
//        self.title = "Photo"
        
//        let uiView = UIView()
//        uiView.backgroundColor = .gray
//
//        navigationItem.titleView = uiView
//
////        let height = self.navigationController?.navigationBar.frame.size.height ?? 2
////        print("heig: \(height)")
//        uiView.snp.makeConstraints { (make) in
//            make.width.equalTo(80)
//            make.height.equalTo(44)
//        }
        
        
        makeTitleView()
        
        
        
        navigationItem.largeTitleDisplayMode = .never
        
        findButton = UIBarButtonItem(title: "Find", style: .plain, target: self, action: #selector(findPressed(sender:)))
        
        findButton.tintColor = UIColor(named: "TabIconPhotosMain")
        
        navigationItem.rightBarButtonItems = [findButton]
    }
    func makeTitleView() {
        let baseView = UIView()
        
        let contentView = UIView()
        let titleLabel = UILabel()
        let subtitleLabel = UILabel()
        
        baseView.addSubview(contentView)
        contentView.addSubview(titleLabel)
        contentView.addSubview(subtitleLabel)
        
//        baseView.snp.makeConstraints { (make) in
//
//        }
        contentView.backgroundColor = .clear
        
        baseView.backgroundColor = .gray
        
        titleLabel.font = UIFont.systemFont(ofSize: 15, weight: .regular)
        subtitleLabel.font = UIFont.systemFont(ofSize: 11, weight: .regular)
        
        titleLabel.text = "January 14"
        subtitleLabel.text = "8:29 PM"
        
        
        
        titleLabel.snp.makeConstraints { (make) in
            make.top.equalTo(contentView.snp.top)
            make.left.equalToSuperview()
            make.right.equalToSuperview()
            make.bottom.equalTo(subtitleLabel.snp.top)
        }
        
        subtitleLabel.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.bottom.equalTo(contentView.snp.bottom)
        }
        
        contentView.snp.makeConstraints { (make) in
            make.center.equalToSuperview()
        }
        
        navigationItem.titleView = baseView
//        self.navigationController?.navigationBar.backgroundColor = .red
//        print("bounds? \(self.navigationController?.navigationBar.bounds)")
        
//        baseView.snp.makeConstraints { (make) in
//            make.top.equalToSuperview()
//            make.bottom.equalToSuperview()
//        }
    }
}
