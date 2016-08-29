//
//  SelectedPhotoCell.swift
//  ZCJImagePicker
//
//  Created by zhoucj on 16/8/28.
//  Copyright © 2016年 zhoucj. All rights reserved.
//

import UIKit
import AssetsLibrary
protocol SelectedPhotoCellDelegate: NSObjectProtocol{
    func deletePhoto(cell: SelectedPhotoCell)
}
class SelectedPhotoCell: UICollectionViewCell {
    var delegate: SelectedPhotoCellDelegate?
    var alsseet: ALAsset?{
        didSet{
            imageView.image = UIImage(CGImage: alsseet!.thumbnail().takeUnretainedValue())
        }
    }
    var isLast = false{
        didSet{
            if isLast{
                imageView.image = UIImage(named: "compose_pic_add")
            }
            deleteBtn.hidden = isLast
        }
    }
    var image: UIImage?{
        didSet{
            imageView.image = image
        }
    }
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    private func setupUI(){
        contentView.addSubview(imageView)
        contentView.addSubview(deleteBtn)
    }
    private lazy var imageView = UIImageView()
    private lazy var deleteBtn: UIButton = {
        let btn = UIButton()
        btn.setBackgroundImage(UIImage(named: "camera_tag_delete_right"), forState: .Normal)
        btn.addTarget(self, action: Selector("selectPhoto"), forControlEvents: .TouchUpInside)
        return btn
    }()
    @objc private func selectPhoto(){
        delegate?.deletePhoto(self)
    }
    override func layoutSubviews() {
        imageView.translatesAutoresizingMaskIntoConstraints = false
        deleteBtn.translatesAutoresizingMaskIntoConstraints = false
        let dict = ["imageView": imageView, "deleteBtn": deleteBtn]
        var cons = NSLayoutConstraint.constraintsWithVisualFormat("H:|-0-[imageView]-0-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: dict)
        cons += NSLayoutConstraint.constraintsWithVisualFormat("V:|-0-[imageView]-0-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: dict)
        cons += NSLayoutConstraint.constraintsWithVisualFormat("H:[deleteBtn(30)]-0-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: dict)
        cons += NSLayoutConstraint.constraintsWithVisualFormat("V:|-0-[deleteBtn(30)]", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: dict)
        contentView.addConstraints(cons)
    }
}
