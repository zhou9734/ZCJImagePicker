//
//  PreviewCollectionCell.swift
//  图片选择器
//
//  Created by zhoucj on 16/8/25.
//  Copyright © 2016年 zhoucj. All rights reserved.
//

import UIKit

class PreviewCollectionCell: UICollectionViewCell, UIScrollViewDelegate {
    weak var delegate: PhotoLibraryCellDelegate?
    var assentModel: ALAssentModel?{
        didSet{
            //重置scrollView和imageView
            resetView()
            //fullResolutionImage().takeUnretainedValue()
            let image = UIImage(CGImage: assentModel!.alsseet!.defaultRepresentation().fullScreenImage().takeUnretainedValue())
            imageView.image = image
            let screenWidth = UIScreen.mainScreen().bounds.width
            let screenHeight = UIScreen.mainScreen().bounds.height
            //图片宽高比
            let scale = image.size.height/image.size.width
            //利用宽高比计算图片的高度
            let imageHeight = scale * screenWidth
            //设置图片的frame
            self.imageView.frame = CGRect(origin: CGPointZero, size: CGSize(width: screenWidth, height: imageHeight))
            //判断当前是长图还是短图
            if imageHeight < screenHeight{
                // 短图
                // 计算顶部和底部内边距
                let offsetY = (screenHeight - imageHeight) * 0.5
                // 设置内边距
                self.scrollView.contentInset = UIEdgeInsets(top: offsetY, left: 0, bottom: offsetY, right: 0)
            }else{
                self.scrollView.contentSize = CGSize(width: screenWidth, height: imageHeight)
            }
            checkButton.selected = assentModel!.isChecked
        }
    }
    var index: Int = -1
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    private func setupUI(){
        scrollView.addSubview(imageView)
        contentView.addSubview(scrollView)
        contentView.addSubview(checkButton)
        scrollView.frame =  UIScreen.mainScreen().bounds //self.frame
        
        checkButton.translatesAutoresizingMaskIntoConstraints = false
        let dict = ["checkButton": checkButton]
        var cons = NSLayoutConstraint.constraintsWithVisualFormat("H:[checkButton(30)]-25-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: dict)
        cons += NSLayoutConstraint.constraintsWithVisualFormat("V:|-85-[checkButton(30)]", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: dict)
        contentView.addConstraints(cons)
    }
    private func resetView(){
        scrollView.contentSize = CGSizeZero
        scrollView.contentInset = UIEdgeInsetsZero
        scrollView.contentOffset = CGPointZero
        imageView.transform = CGAffineTransformIdentity
    }
    //scrollView
    private lazy var scrollView : UIScrollView = {
        let sc = UIScrollView()
        sc.maximumZoomScale = 2.0
        sc.minimumZoomScale = 1
        sc.delegate = self
        return sc
    }()
    //图片
    lazy var imageView = UIImageView()

    private lazy var checkButton: UIButton = {
        let btn = UIButton()
        btn.setBackgroundImage(UIImage(named: "compose_guide_check_box_default"), forState: .Normal)
        btn.setBackgroundImage(UIImage(named: "compose_guide_check_box_right"), forState: .Selected)
        btn.addTarget(self, action: Selector("previewSelectPhoto"), forControlEvents: .TouchUpInside)
        btn.layer.cornerRadius = 15
        btn.layer.masksToBounds = true
        return btn
    }()
    //添加或勾选图片
    @objc private func previewSelectPhoto(){
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
            checkButton.transform = CGAffineTransformMakeScale(0, 0)
            UIView.animateWithDuration(0.5, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 10, options: UIViewAnimationOptions(rawValue: 0), animations: { () -> Void in
                self.checkButton.transform = CGAffineTransformIdentity
                }, completion: nil)
        }
        checkButton.selected = !checkButton.selected
    }
    // MARK: - UIScrollViewDelegate
    // 告诉系统需要缩放哪一个控件
    func viewForZoomingInScrollView(scrollView: UIScrollView) -> UIView? {
        return imageView
    }
    // 缩放的过程中会不断调用
    func scrollViewDidZoom(scrollView: UIScrollView) {
        // 1.计算上下内边距
        let bounds = UIScreen.mainScreen().bounds
        var offsetY = (bounds.height - imageView.frame.height) * 0.5
        // 2.计算左右内边距
        var offsetX = (bounds.width - imageView.frame.width) * 0.5
        offsetY = (offsetY < 0) ? 0 : offsetY
        offsetX = (offsetX < 0) ? 0 : offsetX
        scrollView.contentInset = UIEdgeInsets(top: offsetY, left: offsetX, bottom: offsetY, right: offsetX)
    }

}
