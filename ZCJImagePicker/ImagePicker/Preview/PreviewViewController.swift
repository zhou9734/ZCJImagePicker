//
//  PreviewViewController.swift
//  图片选择器
//
//  Created by zhoucj on 16/8/25.
//  Copyright © 2016年 zhoucj. All rights reserved.
//

import UIKit
let PreviewReuseIdentifier = "PreviewReuseIdentifier"
class PreviewViewController: UIViewController {
    var alassetModels = [ALAssentModel]()
    var countPhoto = 0
    var _currentImageIndex: Int = -1
    var indexPath: NSIndexPath?
    init(alassetModels: [ALAssentModel], countPhoto: Int, indexPath: NSIndexPath){
        self.alassetModels = alassetModels
        self.countPhoto = countPhoto
        self.indexPath = indexPath
        if let alassetModel = self.alassetModels.first where alassetModel.isFirst {
            self.alassetModels.removeFirst()
        }
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    private func setupUI(){
        view.addSubview(collectionView)
        view.addSubview(naviBar)
        collectionView.frame = self.view.frame
        //转到点击到的图片
        if let tempIndex = indexPath {
            countLbl.text =  "\(tempIndex.item + 1)" + "/" + "\(alassetModels.count)"
            collectionView.scrollToItemAtIndexPath(tempIndex, atScrollPosition: .Left, animated: true)
        }
        naviBar.translatesAutoresizingMaskIntoConstraints = false
        let dict = ["naviBar": naviBar]
        var cons = NSLayoutConstraint.constraintsWithVisualFormat("H:|-0-[naviBar]-0-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: dict)
        cons += NSLayoutConstraint.constraintsWithVisualFormat("V:|-0-[naviBar(64)]", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: dict)
        view.addConstraints(cons)
        dealCountPhoto()
    }
    //导航栏
    private lazy var naviBar: UINavigationBar = {
        let nvBar = UINavigationBar()
        nvBar.barStyle = .Default
        let nvBarItem = UINavigationItem()
        nvBarItem.leftBarButtonItem = UIBarButtonItem(customView: self.leftButton)
        nvBarItem.rightBarButtonItem = UIBarButtonItem(customView: self.rightButton)
        nvBarItem.titleView = self.countLbl
        nvBar.items = [nvBarItem]
        return nvBar
    }()
    //图片浏览
    lazy var collectionView: UICollectionView = {
        let clv = UICollectionView(frame: CGRectZero, collectionViewLayout: PreviewFlowLayout())
        clv.registerClass(PreviewCollectionCell.self, forCellWithReuseIdentifier: PreviewReuseIdentifier)
        clv.dataSource = self
        clv.delegate = self
        clv.backgroundColor = UIColor.whiteColor()
        return clv
    }()
    //标签
    private lazy var countLbl: UILabel  = {
        let lbl = UILabel()
        lbl.text = "0/0"
        lbl.textAlignment = .Center
        lbl.font = UIFont.systemFontOfSize(20)
        lbl.bounds = CGRectMake(0, 0, 100, 40)
        return lbl
    }()
    //返回按钮
    private lazy var leftButton: UIButton = {
        let btn = UIButton()
        btn.setTitle("返回", forState: .Normal)
        btn.setTitleColor(UIColor.grayColor(), forState: .Normal)
        btn.titleLabel?.font = UIFont.systemFontOfSize(16)
        btn.addTarget(self, action: Selector("backBtnClick"), forControlEvents: .TouchUpInside)
        btn.frame.size = CGSize(width: 50, height: 35)
        return btn
    }()
    //下一步按钮
    private lazy var rightButton: UIButton = {
        let btn = UIButton()
        btn.setTitle("下一步", forState: .Normal)
        btn.addTarget(self, action: Selector("nextStepClick"), forControlEvents: .TouchUpInside)
        btn.setBackgroundImage(UIImage(named: "tabbar_compose_below_button"), forState: .Normal)
        btn.setBackgroundImage(UIImage(named: "common_button_big_orange"), forState: .Selected)
        btn.setTitleColor(UIColor.grayColor(), forState: .Normal)
        btn.setTitleColor(UIColor.whiteColor(), forState: .Selected)
        btn.frame.size = CGSize(width: 70, height: 28)
        btn.titleLabel?.font = UIFont.systemFontOfSize(15)
        return btn
    }()
    @objc private func backBtnClick(){
        NSNotificationCenter.defaultCenter().postNotificationName(RreviewPhotoDone, object: self, userInfo: ["alassetModels": alassetModels])
        dismissViewControllerAnimated(true, completion: nil)
    }
    @objc private func nextStepClick(){
        NSNotificationCenter.defaultCenter().postNotificationName(NextSetp, object: self, userInfo: ["alassetModels": alassetModels])
        dismissViewControllerAnimated(true, completion: nil)
    }

}
//MARK: - UICollectionViewDataSource代理
extension PreviewViewController: UICollectionViewDataSource{
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return alassetModels.count
    }
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(PreviewReuseIdentifier, forIndexPath: indexPath) as! PreviewCollectionCell
        cell.delegate = self
        cell.assentModel = alassetModels[indexPath.item]
        cell.index = indexPath.item
        return cell
    }
}
//MARK: - UICollectionViewDelegate代理
extension PreviewViewController: UICollectionViewDelegate{
    func scrollViewDidScroll(scrollView: UIScrollView) {
        let temIndex = Int((scrollView.contentOffset.x + scrollView.bounds.size.width) / scrollView.bounds.size.width)
        countLbl.text =  "\(temIndex)" + "/" + "\(alassetModels.count)"
        _currentImageIndex = alassetModels[temIndex - 1].orginIndex
    }
}
//MARK: - PhotoLibraryCellDelegate代理
extension PreviewViewController: PhotoLibraryCellDelegate{
    func countCanSelected() -> Bool {
        return countPhoto < 9 ? true : false
    }
    func doSelectedPhoto(index: Int, checked: Bool) {
        if checked{
            countPhoto = countPhoto + 1
            alassetModels[index].isChecked = true
        }else{
            countPhoto = countPhoto - 1
            alassetModels[index].isChecked = false
        }
        dealCountPhoto()
    }
    func dealCountPhoto(){
        if countPhoto > 0{
            rightButton.setTitle("下一步(\(countPhoto))", forState: .Normal)
            rightButton.frame.size = CGSize(width: 90, height: 28)
            rightButton.selected = true
            rightButton.enabled = true
        }else{
            rightButton.frame.size = CGSize(width: 70, height: 28)
            rightButton.setTitle("下一步", forState: .Normal)
            rightButton.selected = false
            rightButton.enabled = false
        }
    }
}
//MARK: - 自定义布局
class PreviewFlowLayout: UICollectionViewFlowLayout{
    override func prepareLayout() {
        //设置每个cell尺寸
        let screenSize = UIScreen.mainScreen().bounds.size
//        itemSize = CGSizeMake(screenSize.width, screenSize.height - 64)
        itemSize = screenSize
        // 最小的行距
        minimumLineSpacing = 0
        // 最小的列距
        minimumInteritemSpacing = 0
        // collectionView的滚动方向
        scrollDirection =  .Horizontal // default .Vertical
        //设置分页
        collectionView?.pagingEnabled = true
        //禁用回弹
        collectionView?.bounces = false
        //去除滚动条
        collectionView?.showsHorizontalScrollIndicator = false
        collectionView?.showsVerticalScrollIndicator = false
    }
}