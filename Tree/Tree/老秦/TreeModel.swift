//
//  TreeModel.swift
//  Tree
//
//  Created by Alan on 2021/1/4.
//  Copyright © 2021 1111. All rights reserved.
//

import UIKit

class TreeModel: BaseModel {
    ///是否最后一级
    var finalFlag = false
    var id = ""
    ///父Id, 为0视为根节点
    var pid = ""
    var title = ""
    ///层级
    var layer = 0
    
    var leaves = [TreeModel]()
    
    var level = 0
    
    var isUnfold = false
    
    var selected = false
}
