//
//  PhotoLibraryCell.swift
//  图片选择器
//
//  Created by zhoucj on 16/8/25.
//  Copyright © 2016年 zhoucj. All rights reserved.
//

import UIKit
protocol PhotoLibraryCellDelegate: NSObjectProtocol{
    func countCanSelected() -> Bool
    func doSelectedPhoto(index: Int, checked: Bool)
}

class PhotoLibraryCell: UICollectionViewCell {
    weak var delegate: PhotoLibraryCellDelegate?
    var assent: ALAssentModel?{
        didSet{
            if assent!.isFirst{
                imageView.image = UIImage(named: "compose_photo_photograph")
                imageView.contentMode = .Center
                checkButton.hidden = true
            }else{
                imageView.image = UIImage(CGImage: assent!.alsseet!.thumbnail().takeUnretainedValue())
                imageView.contentMode = .ScaleToFill
                checkButton.hidden = false
                checkButton.selected = assent!.isChecked
            }

        }
    }
    var index: Int = -1
    var isFrist = false
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    private func setupUI(){
        backgroundColor = UIColor(red: 234.0/255.0, green: 234.0/255.0, blue: 241.0/255.0, alpha: 1)
        contentView.addSubview(imageView)
        contentView.addSubview(checkButton)
    }
    //注意: cell的布局要重写layoutSubviews方法,如果在init中布局会卡顿!!!
    override func layoutSubviews() {
        imageView.translatesAutoresizingMaskIntoConstraints = false
        checkButton.translatesAutoresizingMaskIntoConstraints = false
        let dict = ["imageView": imageView, "checkButton": checkButton]
        var cons = NSLayoutConstraint.constraintsWithVisualFormat("H:|-0-[imageView]-0-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: dict)
        cons += NSLayoutConstraint.constraintsWithVisualFormat("V:|-0-[imageView]-0-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: dict)
        cons += NSLayoutConstraint.constraintsWithVisualFormat("H:[checkButton(30)]-0-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: dict)
        cons += NSLayoutConstraint.constraintsWithVisualFormat("V:|-0-[checkButton(30)]", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: dict)
        contentView.addConstraints(cons)
    }

    lazy var imageView = UIImageView()
    private lazy var checkButton: UIButton = {
        let btn = UIButton()
        btn.setBackgroundImage(UIImage(named: "compose_guide_check_box_default"), forState: .Normal)
        btn.setBackgroundImage(UIImage(named: "compose_guide_check_box_right"), forState: .Selected)
        btn.addTarget(self, action: Selector("selectPhoto"), forControlEvents: .TouchUpInside)
        btn.layer.cornerRadius = 15
        btn.layer.masksToBounds = true
        return btn
    }()

    //MARK: - 选择照片
    @objc private func selectPhoto(){
        guard let canSelect = delegate?.countCanSelected() else{
            return
        }
        if !canSelect  && !checkButton.selected{
            let alertView = UIAlertView(title: nil, message: "最多只能选取9张照片", delegate: nil, cancelButtonTitle: "确定")
            alertView.show()
            return
        }
        if checkButton.selected{
            delegate?.doSelectedPhoto(index, checked: false)
        }else{
            delegate?.doSelectedPhoto(index, checked: true)
            //放大动画
            checkButton.transform = CGAffineTransformMakeScale(0, 0)
            UIView.animateWithDuration(0.5, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 10, options: UIViewAnimationOptions(rawValue: 0), animations: { () -> Void in
                self.checkButton.transform = CGAffineTransformIdentity
                }, completion: nil)

        }
        checkButton.selected = !checkButton.selected
    }
}
