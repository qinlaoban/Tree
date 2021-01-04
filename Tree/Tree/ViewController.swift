//
//  ViewController.swift
//  Tree
//
//  Created by Alan on 2019/10/29.
//  Copyright © 2019 1111. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupSubviews()
    }
    
    func setupSubviews(){
        
        self.navigationItem.title = "人员组织架构"
        let groupView = STTreeView.init(frame: .zero, multipleSelect: true)
        groupView.isSelect = true
        view.addSubview(groupView)
        groupView.snp.makeConstraints { (maker) in
            maker.left.top.equalTo(12)
            maker.right.bottom.equalTo(-12)
        }
        
    }
}


