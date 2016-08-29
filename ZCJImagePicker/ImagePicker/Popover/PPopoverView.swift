//
//  PPopoverView.swift
//  图片选择器
//
//  Created by zhoucj on 16/8/26.
//  Copyright © 2016年 zhoucj. All rights reserved.
//

import UIKit
import AssetsLibrary
let PPopoverReuseIdentifier = "PPopoverReuseIdentifier"
class PPopoverView: UIView {
    var alasentGroupModels = [ALAssetsGroup]()
    var containerBtn: UIButton?
    init(alasentGroupModels: [ALAssetsGroup]) {
        super.init(frame: CGRectZero)
        var tempGroupModel = [ALAssetsGroup]()
        //过滤空组
        for gModel in alasentGroupModels{
            if gModel.numberOfAssets() > 0{
                tempGroupModel.append(gModel)
            }
        }
        self.alasentGroupModels = tempGroupModel
        setupUI()
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    private func setupUI(){
        containerBtn = UIButton()
        containerBtn!.backgroundColor = UIColor(white: 0.2, alpha: 0.3)
        containerBtn!.addTarget(self, action: Selector("dismissViewClick"), forControlEvents: .TouchUpInside)
        containerBtn!.alpha = 1
        containerBtn!.addSubview(tableView)
        //必须把tableView放到最前面不然tableView不会响应点击事件
        containerBtn!.bringSubviewToFront(tableView)
    }
    //MARK: - tableView
    private lazy var tableView: UITableView = {
        let tbv = UITableView(frame: CGRectZero, style: .Plain)
        tbv.registerClass(PPoverTableCell.self, forCellReuseIdentifier: PPopoverReuseIdentifier)
        tbv.dataSource = self
        tbv.delegate = self
        //设置分割符
        tbv.separatorStyle = .None
        //禁用滚动
        tbv.scrollEnabled = false
        tbv.delaysContentTouches = false
        return tbv
    }()
    //展示
    func showInView(_view: UIView){
        containerBtn!.frame = _view.bounds
        frame = _view.bounds
        addSubview(containerBtn!)
        _view.addSubview(self)
        let _height = CGFloat(alasentGroupModels.count * 60)
        let _width = UIScreen.mainScreen().bounds.width
        tableView.frame = CGRectMake(0, (0 - _height), _width, _height)
        UIView.animateWithDuration(0.5) { () -> Void in
            self.tableView.transform = CGAffineTransformMakeTranslation(0, (_height + 64))
        }
    }
    //隐藏
    func hide(){
        dismissViewClick()
    }
    @objc private func dismissViewClick(){
        UIView.animateWithDuration(0.5, animations: {
            self.tableView.transform = CGAffineTransformMakeTranslation(0, 0)
            }, completion: { (Bool) -> Void in
                self.removeFromSuperview()
                NSNotificationCenter.defaultCenter().postNotificationName(ClosePopoverView, object: self)
        })
    }
}
//MARK: - UITableViewDataSource代理
extension PPopoverView: UITableViewDataSource{
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return alasentGroupModels.count
    }
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(PPopoverReuseIdentifier, forIndexPath: indexPath) as! PPoverTableCell
        cell.backgroundColor = UIColor(white: 0.95, alpha: 0.8)
        cell.groupModel = alasentGroupModels[indexPath.item]
        return cell
    }
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 60
    }
}
//MARK: - UITableViewDelegate代理
extension PPopoverView: UITableViewDelegate{
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let gType = alasentGroupModels[indexPath.item].valueForProperty(ALAssetsGroupPropertyType)
        hide()
        NSNotificationCenter.defaultCenter().postNotificationName(SwitchPhotoGroup, object: self, userInfo: ["gType" : String(gType)])
    }
}
