//
//  ViewController.swift
//  ZCJImagePicker
//
//  Created by zhoucj on 16/8/28.
//  Copyright © 2016年 zhoucj. All rights reserved.
//

import UIKit
let SelectedPhotoIdentifier = "SelectedPhotoIdentifier"
let SelectedPhotoDone = "SelectedPhotoDone"
class RootViewController: UIViewController {
    var alassetModels = [ALAssentModel]()
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(collectionView)
        view.backgroundColor = UIColor.whiteColor()
//        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: rightBtn)
        navigationItem.title = "图片选择器"
        collectionView.translatesAutoresizingMaskIntoConstraints = false

        var cons = NSLayoutConstraint.constraintsWithVisualFormat("H:|-0-[collectionView]-0-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["collectionView": collectionView])
        cons += NSLayoutConstraint.constraintsWithVisualFormat("V:|-0-[collectionView]-0-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["collectionView": collectionView])
        view.addConstraints(cons)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("selectedPhotoDown:"), name: SelectedPhotoDone, object: nil)
        alassetModels.append(ALAssentModel(alsseet: nil))
    }
    private lazy var collectionView: UICollectionView = {
        let flowLayout = UICollectionViewFlowLayout()
        let width = (UIScreen.mainScreen().bounds.size.width - 4) / 3
        flowLayout.itemSize = CGSize(width: width, height: width)
        flowLayout.minimumLineSpacing = 2
        flowLayout.minimumInteritemSpacing = 2

        let clv = UICollectionView(frame: CGRectZero, collectionViewLayout: flowLayout)
        clv.registerClass(SelectedPhotoCell.self, forCellWithReuseIdentifier: SelectedPhotoIdentifier)
        clv.backgroundColor = UIColor(red: 234.0/255.0, green: 234.0/255.0, blue: 241.0/255.0, alpha: 1)
        clv.dataSource = self
        clv.delegate = self
        clv.alwaysBounceVertical = true
        return clv

    }()

    @objc private func selectPhotoClick(){
        navigationController?.pushViewController(PhotoViewController(selectedAlassennt: alassetModels), animated: true)
    }

    @objc private func selectedPhotoDown(notice: NSNotification){
        guard let models = notice.userInfo!["alassentModels"] as? [ALAssentModel] else{
            return
        }
        alassetModels = models
        let aModel = ALAssentModel(alsseet: nil)
        alassetModels.append(aModel)
        collectionView.reloadData()
    }
    deinit{
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
}
extension RootViewController: UICollectionViewDataSource{
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return alassetModels.count ?? 0
    }
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(SelectedPhotoIdentifier, forIndexPath: indexPath) as! SelectedPhotoCell
        if let assent = alassetModels[indexPath.item].alsseet{
            cell.alsseet = assent
            cell.isLast = false
        }else{
            cell.isLast = true
        }
        if let image = alassetModels[indexPath.item].takePhtoto{
            cell.image = image
        }
        cell.delegate = self
        return cell
    }
}
extension RootViewController: UICollectionViewDelegate{
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        let cell = collectionView.cellForItemAtIndexPath(indexPath) as! SelectedPhotoCell
        if cell.isLast{
            selectPhotoClick()
        }
    }
}
extension RootViewController: SelectedPhotoCellDelegate{
    func deletePhoto(cell: SelectedPhotoCell) {
        let indexPath = collectionView.indexPathForCell(cell)
        alassetModels.removeAtIndex(indexPath!.item)
        collectionView.reloadData()
    }
}