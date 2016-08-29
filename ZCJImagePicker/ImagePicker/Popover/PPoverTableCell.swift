
//
//  PPoverTableCell.swift
//  图片选择器
//
//  Created by zhoucj on 16/8/26.
//  Copyright © 2016年 zhoucj. All rights reserved.
//

import UIKit
import AssetsLibrary

class PPoverTableCell: UITableViewCell {
    var groupModel: ALAssetsGroup?{
        didSet{
            if groupModel!.numberOfAssets() <= 0 {
                return
            }
            iconImageView.image = UIImage(CGImage: groupModel!.posterImage().takeUnretainedValue())
            var groupName = "\(groupModel!.valueForProperty(ALAssetsGroupPropertyName))"
            if groupName == "Camera Roll"{
                groupName = "相机胶卷"
            }else if groupName == "Photo Library"{
                groupName = "照片图库"
            }else if groupName == "My Photo Stream"{
                groupName = "我的照片流"
            }
            groupNameLbl.text = groupName
            countLbl.text = "\(groupModel!.numberOfAssets())"
        }
    }

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI(){
        contentView.addSubview(iconImageView)
        contentView.addSubview(groupNameLbl)
        contentView.addSubview(countLbl)
        groupNameLbl.translatesAutoresizingMaskIntoConstraints = false
        iconImageView.translatesAutoresizingMaskIntoConstraints = false
        countLbl.translatesAutoresizingMaskIntoConstraints = false
        let dict = ["iconImageView": iconImageView, "groupNameLbl": groupNameLbl, "countLbl": countLbl]
        var cons = NSLayoutConstraint.constraintsWithVisualFormat("H:|-10-[iconImageView(50)]-8-[groupNameLbl]-5-[countLbl]", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: dict)
        cons += NSLayoutConstraint.constraintsWithVisualFormat("V:|-5-[iconImageView(50)]", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: dict)
        cons += NSLayoutConstraint.constraintsWithVisualFormat("V:|-20-[groupNameLbl]", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: dict)
        cons += NSLayoutConstraint.constraintsWithVisualFormat("V:|-25-[countLbl]", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: dict)
        contentView.addConstraints(cons)
    }
    /// 图标
    private lazy var iconImageView = UIImageView()
    //分组名称
    private lazy var groupNameLbl: UILabel = {
        let lbl = UILabel()
        lbl.font = UIFont.systemFontOfSize(18)
        return lbl
    }()
    private lazy var countLbl: UILabel = {
        let lbl = UILabel()
        lbl.text = ""
        lbl.font = UIFont.systemFontOfSize(13)
        return lbl
    }()
}
