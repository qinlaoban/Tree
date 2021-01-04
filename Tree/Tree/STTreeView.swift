//
//  STTreeView.swift
//  ProjectBuild
//
//  Created by xc on 2019/12/4.
//  Copyright © 2019 四川隧唐科技股份有限公司. All rights reserved.
//

import UIKit
import SnapKit

class STTreeView: UIView {
    
    var tableView: UITableView!
    //是否需要选中状态
    var isSelect = false
    var selectGroup: TreeModel?
    //点击节点回调
    var didSelectGroupCallback: ((TreeModel)->())?
    
    
    private var multipleSelect = false
    
    init(frame: CGRect, multipleSelect: Bool = false) {
        super.init(frame: frame)
        self.multipleSelect = multipleSelect
        setupSubviews()
        queryNetworkData()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //列表展示的数据
    var staffDataList = [TreeModel]()
    
    var sumCount: Int = 0
    
    private func setupSubviews(){
        tableView = UITableView(frame: .zero, style: .grouped)
        tableView.backgroundColor = UIColor.white
        tableView.separatorStyle = .none
        tableView.delegate = self
        tableView.dataSource = self
        tableView.estimatedRowHeight = 40
        tableView.estimatedSectionFooterHeight = 1
        tableView.estimatedSectionHeaderHeight = 1
        tableView.showsVerticalScrollIndicator = false
        tableView.register(UINib.init(nibName: "STStaffGroupCell", bundle: nil), forCellReuseIdentifier: "STStaffGroupCell")
        tableView.register(STStaffGroupCell.self, forCellReuseIdentifier: "STStaffGroupCell")
        addSubview(tableView)
        
        tableView.snp.makeConstraints { (maker) in
            maker.left.right.top.bottom.equalTo(0)
        }
        
    }

    
    
    func queryNetworkData(){
        guard let array = readJson() else{return}
        
        
        
        recursionData(array)
        staffDataList.removeAll()
        loadStaffData(array)
        tableView.reloadData()
    }
    
    func readJson() -> [TreeModel]?{
        let path = Bundle.main.path(forResource: "data", ofType: "json")!
        if let data = try? NSData(contentsOfFile: path) as Data{
            if let json = try? JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String : Any]{
                if let array = json["result"] as? [Any]{
                    let arr = [TreeModel].deserialize(from: array) as? [TreeModel]
                    return arr
                }
            }
        }
        return nil
    }
    
    func makeData(_ array:[TreeModel]){
        var arr = [TreeModel]()
        for item in array{
            if item.pid == "0"{
                arr.append(item)
            }
        }
        
    }
    
    
    
    func recursionData(_ data: [TreeModel], level: Int = 0) {
        
        for item in data {
            item.level = level
            recursionData(item.leaves, level: level + 1)
        }
    }
    
    //展开
    func loadStaffData(_ data: [TreeModel]) {
        
        for item in data {
            item.isUnfold = true
            staffDataList.append(item)
            if item.leaves.count > 0 {
                loadStaffData(item.leaves)
            }
        }
    }
    
}

extension STTreeView: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return staffDataList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "STStaffGroupCell", for: indexPath) as! STStaffGroupCell
        cell.selectionStyle = .none
        let group = staffDataList[indexPath.row]
        cell.setupGroupInfo(group, select: isSelect, multiple: multipleSelect)
        cell.delegate = self
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.1
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0.1
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        isUnfold(indexPath: indexPath)
    }
    
    
    //递归求出应该移除的数量
    private func recursionSum(_ group: TreeModel){
        
        for item in group.leaves {
            if item.isUnfold {
                sumCount = sumCount + item.leaves.count
                item.isUnfold = false
                recursionSum(item)
            }
        }
    }
    
}

//MARK: - STStaffGroupCellDelegate
extension STTreeView: STStaffGroupCellDelegate{
    func groupIndicatiorButtonClick(_ cell: STStaffGroupCell) {
        if let indexPath = tableView.indexPath(for: cell) {
            
            isUnfold(indexPath: indexPath)
        }
    }
    
    private func isUnfold(indexPath: IndexPath) {
        let group = staffDataList[indexPath.row]
        if group.isUnfold {
            
            //已经是展开状态，执行收缩操作
            if group.leaves.count > 0 {
                group.isUnfold = false
                sumCount = group.leaves.count
                recursionSum(group)
                
                let range = Range(NSMakeRange(indexPath.row + 1, sumCount))!
                staffDataList.removeSubrange(range)
                tableView.reloadData()
            }
        } else {
            //收缩状态，执行展开操作
            if group.leaves.count > 0 {
                group.isUnfold = true
                staffDataList.insert(contentsOf: group.leaves, at: indexPath.row + 1)
                tableView.reloadData()
            }
        }
    }
    
    func groupNameButtonClick(_ cell: STStaffGroupCell) {
        if let indexPath = tableView.indexPath(for: cell) {
            
            let group = staffDataList[indexPath.row]
            
            if isSelect {
                if multipleSelect {
                    group.selected = !group.selected
                } else {
                    if selectGroup != nil {
                        selectGroup!.selected = false
                    }
                    group.selected = true
                    selectGroup = group
                }
                tableView.reloadData()
            }
            if didSelectGroupCallback != nil {
                didSelectGroupCallback?(group)
            }
        }
    }
}

class STStaffGroupCell: UITableViewCell {
    
    var indicatorButton: UIButton!
    var groupName: UILabel!
    weak var delegate: STStaffGroupCellDelegate?
    
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupSubviews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupSubviews(){
        let image = UIImage(named: "icon_open")!
        let selectImage = UIImage(named: "icon_open_pre")!
        
        indicatorButton = UIButton(type: .custom)
        indicatorButton.setImage(image, for: .normal)
        indicatorButton.setImage(selectImage, for: .selected)
        indicatorButton.addTarget(self, action: #selector(indicatorButtonClick), for: .touchUpInside)
        indicatorButton.imageEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 10)
        contentView.addSubview(indicatorButton)
        indicatorButton.snp.makeConstraints { (maker) in
            maker.left.equalTo(0)
            maker.size.equalTo(CGSize(width: image.size.width + 10, height: image.size.height + 10))
            maker.centerY.equalToSuperview()
        }
        
        groupName = UILabel()
        groupName.font = UIFont.systemFont(ofSize: 15)
        groupName.numberOfLines = 0
        groupName.textColor = UIColor.black
        groupName.isUserInteractionEnabled = true
        contentView.addSubview(groupName)
        groupName.snp.makeConstraints { (maker) in
            maker.left.equalTo(indicatorButton.snp.right).offset(8)
            maker.right.lessThanOrEqualTo(-8)
            maker.height.greaterThanOrEqualTo(20)
            maker.top.equalTo(6)
            maker.bottom.equalTo(-6)
        }
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(groupNameClick))
        groupName.addGestureRecognizer(tapGesture)
        
        
    }
    
    func setupGroupInfo(_ group: TreeModel, select: Bool, multiple: Bool){
        
        groupName.text = group.title
        if group.selected {
            groupName.backgroundColor = UIColor.lightGray
            groupName.textColor = .white
        } else {
            groupName.backgroundColor = UIColor.clear
            groupName.textColor = UIColor.blue
        }
        
        
        let image = UIImage(named: "icon_open")!
        if group.leaves.count == 0 {
            indicatorButton.isHidden = true
            groupName.snp.remakeConstraints { (maker) in
                maker.left.equalTo(CGFloat(group.level) * (image.size.width + 10))
                maker.right.lessThanOrEqualTo(-8)
                maker.height.greaterThanOrEqualTo(20)
                maker.top.equalTo(6)
                maker.bottom.equalTo(-6)
            }
            
        } else {
            indicatorButton.isHidden = false
            indicatorButton.isSelected = group.isUnfold
            indicatorButton.snp.remakeConstraints { (maker) in
                maker.left.equalTo(CGFloat(group.level) * (image.size.width + 10))
                maker.size.equalTo(CGSize(width: image.size.width + 10, height: image.size.height + 10))
                maker.centerY.equalToSuperview()
            }
            
            groupName.snp.remakeConstraints { (maker) in
                maker.left.equalTo(indicatorButton.snp.right)
                maker.right.lessThanOrEqualTo(-8)
                maker.height.greaterThanOrEqualTo(20)
                maker.top.equalTo(6)
                maker.bottom.equalTo(-6)
            }
        }
    }
    
    @objc func groupNameClick(){
        delegate?.groupNameButtonClick(self)
    }
    
    @objc func indicatorButtonClick(){
        delegate?.groupIndicatiorButtonClick(self)
    }
    
    
}

protocol STStaffGroupCellDelegate: class {
    func groupIndicatiorButtonClick(_ cell: STStaffGroupCell)
    func groupNameButtonClick(_ cell: STStaffGroupCell)
}




