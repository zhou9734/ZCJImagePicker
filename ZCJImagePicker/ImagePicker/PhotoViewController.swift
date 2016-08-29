//
//  ImagePickerViewController.swift
//  图片选择器
//
//  Created by zhoucj on 16/8/24.
//  Copyright © 2016年 zhoucj. All rights reserved.
//

import UIKit
import AssetsLibrary

let NextSetp = "NextSetp"
let ClosePopoverView = "ClosePopoverView"
let SwitchPhotoGroup = "SwitchPhotoGroup"
let RreviewPhotoDone = "RreviewPhotoDone"
class PhotoViewController: UIViewController {
    //从选择图片视图传来的已经选择的图片
    var selectedAlassentModel:[ALAssentModel]?
    var previewPresentAnimator = PreviewPresentAnimator()
    var previewDismissAnimator = PreviewDismisssAnimator()
    private let PhotoIdentifier = "PhotoLibraryCell"
    var countPhoto = 0
    var popoverView: PPopoverView?
    var alassetModels = [ALAssentModel]()
    var alassentGroups = [ALAssetsGroup]()
    let types: [UInt32] = [ALAssetsGroupSavedPhotos,ALAssetsGroupLibrary, ALAssetsGroupAlbum, ALAssetsGroupPhotoStream, ALAssetsGroupEvent,ALAssetsGroupFaces]
    static let assetsLibrary = ALAssetsLibrary()
    var selectAssetsGroup: ALAssetsGroup?{
        didSet{
            var groupName = selectAssetsGroup!.valueForProperty(ALAssetsGroupPropertyName) as! String
            if groupName == "Camera Roll"{
                groupName = "相机胶卷"
            }else if groupName == "Photo Library"{
                 groupName = "照片图库"
            }else if groupName == "My Photo Stream"{
                groupName = "我的照片流"
            }
            self.titleButton.setTitle(groupName, forState: .Normal)
            self.titleButton.sizeToFit()
            loadAllAssetsForGroups()
        }
    }
    init(selectedAlassennt: [ALAssentModel]){
        super.init(nibName: nil, bundle: nil)
        self.selectedAlassentModel = selectedAlassennt
    }
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("nextStepBtnClick:"), name: NextSetp, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("unSelectTitleBtn"), name: ClosePopoverView, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("switchGroup:"), name: SwitchPhotoGroup, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("previewPhotoDone:"), name: RreviewPhotoDone, object: nil)
    }
    //MARK: - UI组件
    private func setupUI(){
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: leftButton)
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: rightButton)
        navigationItem.titleView = titleButton
        view.addSubview(collectionView)
        view.addSubview(toolView)
        previewBtn.enabled = false
        rightButton.enabled = false
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        toolView.translatesAutoresizingMaskIntoConstraints = false
        previewBtn.translatesAutoresizingMaskIntoConstraints = false
        originalBtn.translatesAutoresizingMaskIntoConstraints = false
        //设置toolView内的按钮约束
        let toolViewdict = ["previewBtn": previewBtn, "originalBtn": originalBtn]
        var t_cons = NSLayoutConstraint.constraintsWithVisualFormat("H:|-15-[previewBtn(65)]-15-[originalBtn(80)]", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: toolViewdict)
        t_cons += NSLayoutConstraint.constraintsWithVisualFormat("V:|-10-[previewBtn(35)]", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: toolViewdict)
        t_cons += NSLayoutConstraint.constraintsWithVisualFormat("V:|-10-[originalBtn(35)]", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: toolViewdict)
        toolView.addConstraints(t_cons)

        //设置toolView约束
        let dict = ["collectionView": collectionView, "toolView": toolView]
        var cons = NSLayoutConstraint.constraintsWithVisualFormat("H:|-0-[collectionView]-0-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: dict)
        cons += NSLayoutConstraint.constraintsWithVisualFormat("V:|-0-[collectionView]-0-[toolView(55)]-0-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: dict)
        cons += NSLayoutConstraint.constraintsWithVisualFormat("H:|-0-[toolView]-0-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: dict)
        view.addConstraints(cons)
        loadAssetsGroups()
    }
    //collectionView
    private lazy var collectionView: UICollectionView = {
        let flowLayout = UICollectionViewFlowLayout()
        let width = (UIScreen.mainScreen().bounds.size.width - 4) / 3
        flowLayout.itemSize = CGSize(width: width, height: width)
        flowLayout.minimumLineSpacing = 2
        flowLayout.minimumInteritemSpacing = 2

        let clv = UICollectionView(frame: CGRectZero, collectionViewLayout: flowLayout)
        clv.registerClass(PhotoLibraryCell.self, forCellWithReuseIdentifier: self.PhotoIdentifier)
        clv.backgroundColor = UIColor(red: 234.0/255.0, green: 234.0/255.0, blue: 241.0/255.0, alpha: 1)
        clv.dataSource = self
        clv.delegate = self
        clv.alwaysBounceVertical = true
        return clv
    }()
    //取消按钮
    private lazy var leftButton: UIButton = {
        let btn = UIButton()
        btn.setTitle("取消", forState: .Normal)
        btn.addTarget(self, action: Selector("cancelBtnClick"), forControlEvents: .TouchUpInside)
        btn.setTitleColor(UIColor.grayColor(), forState: .Normal)
        btn.titleLabel?.font = UIFont.systemFontOfSize(16)
        btn.frame.size = CGSize(width: 60, height: 40)
        btn.sizeToFit()
        return btn
    }()
    //下一步按钮
    private lazy var rightButton: UIButton = {
        let btn = UIButton()
        btn.setTitle("下一步", forState: .Normal)
        btn.addTarget(self, action: Selector("nextStepBtnClick2"), forControlEvents: .TouchUpInside)
        btn.setBackgroundImage(UIImage(named: "tabbar_compose_below_button"), forState: .Normal)
        btn.setBackgroundImage(UIImage(named: "common_button_big_orange"), forState: .Selected)
        btn.setTitleColor(UIColor.grayColor(), forState: .Normal)
        btn.setTitleColor(UIColor.whiteColor(), forState: .Selected)
        btn.frame.size = CGSize(width: 70, height: 28)
        btn.titleLabel?.font = UIFont.systemFontOfSize(15)
        return btn
    }()
    //标题按钮
    private lazy var titleButton: HeadButton = {
        let btn = HeadButton()
        btn.setTitle("", forState: .Normal)
        btn.addTarget(self, action: Selector("titleButtonClick:"), forControlEvents: .TouchUpInside)
        return btn
    }()
    //底部按钮
    private lazy var toolView : UIView = {
        let _view = UIView()
        _view.addSubview(self.previewBtn)
        _view.addSubview(self.originalBtn)
        _view.backgroundColor = UIColor(red: 234.0/255.0, green: 234.0/255.0, blue: 241.0/255.0, alpha: 1)
        return _view
    }()
    //预览按钮
    private lazy var previewBtn: UIButton = {
        let btn = UIButton()
        btn.setTitle("预览", forState: .Normal)
        btn.addTarget(self, action: Selector("previewBtnClick"), forControlEvents: .TouchUpInside)
        btn.setBackgroundImage(UIImage(named: "tabbar_compose_below_background"), forState: .Normal)
        btn.setTitleColor(UIColor.grayColor(), forState: .Normal)
        btn.setTitleColor(UIColor.darkGrayColor(), forState: .Selected)
        btn.titleLabel?.font = UIFont.systemFontOfSize(15)
        btn.enabled = false
        return btn
    }()
    //原图按钮
    private lazy var originalBtn: UIButton = {
        let btn = UIButton()
        btn.setTitle("  原图", forState: .Normal)
        btn.addTarget(self, action: Selector("originalBtnClick"), forControlEvents: .TouchUpInside)
        btn.setBackgroundImage(UIImage(named: "compose_photo_original"), forState: .Normal)
        btn.setBackgroundImage(UIImage(named: "compose_photo_original"), forState: .Highlighted)
        btn.setBackgroundImage(UIImage(named: "compose_photo_original_highlighted"), forState: .Selected)
        btn.setTitleColor(UIColor.darkGrayColor(), forState: .Normal)
        btn.titleLabel?.font = UIFont.systemFontOfSize(15)
        return btn
    }()
    //MARK: - 预览点击事件
    @objc private func previewBtnClick(){
        var selectedAlassetModels = [ALAssentModel]()
        var index = 0
        var isFrist = true
        var fristIndex = -1
        for model in alassetModels{
            if model.isChecked{
                if isFrist{
                    fristIndex = model.orginIndex
                    isFrist = false
                }
                selectedAlassetModels.append(model)
            }
            index = index + 1
        }
        let indexPath = NSIndexPath(forItem: fristIndex, inSection: 0)
        let cell = collectionView.cellForItemAtIndexPath(indexPath) as! PhotoLibraryCell
        openBrowser(cell, indexPath: NSIndexPath(forItem: 0, inSection: 0), models: selectedAlassetModels)
    }
    //MARK: - 原图点击事件
    @objc private func originalBtnClick(){
        originalBtn.selected = !originalBtn.selected
    }
    //取消
    @objc private func cancelBtnClick(){
//        dismissViewControllerAnimated(true, completion: nil)
        navigationController?.popViewControllerAnimated(true)
    }
    //MARK: - 下一步
    @objc private func nextStepBtnClick(notice: NSNotification){
        guard let previewModel = notice.userInfo!["alassetModels"] as? [ALAssentModel] else{
            return
        }
        doNextStep(previewModel)
    }
    @objc private func nextStepBtnClick2(){
        doNextStep(alassetModels)
    }
    private func doNextStep(models: [ALAssentModel]){
        var selectedPhoto = [ALAssentModel]()
        for aModel in models{
            if aModel.isChecked{
                selectedPhoto.append(aModel)
            }
        }
        NSNotificationCenter.defaultCenter().postNotificationName(SelectedPhotoDone, object: self, userInfo: ["alassentModels" : selectedPhoto])
        navigationController?.popViewControllerAnimated(true)
    }
    //MARK: - 标题按钮点击事件
    @objc private func titleButtonClick(btn: UIButton){
        if btn.selected{
            popoverView?.hide()
            btn.selected = false
        }else{
            popoverView?.showInView(view)
            btn.selected = true
        }
    }
    @objc private func unSelectTitleBtn(){
        titleButton.selected = false
    }
    private func calculateImageRect(image: UIImage)-> CGRect{
        //图片宽高比
        let scale = image.size.height/image.size.width
        let screenWidth = UIScreen.mainScreen().bounds.width
        let screenHeight = UIScreen.mainScreen().bounds.height
        //利用宽高比计算图片的高度
        let imageHeight = scale * screenWidth
        //判断当前是长图还是短图
        var offsetY: CGFloat = 0
        if imageHeight < screenHeight{
            // 短图
            // 计算顶部和底部内边距
            offsetY = (screenHeight - imageHeight) * 0.5
        }
        let rect = CGRect(x: 0, y: offsetY, width: screenWidth, height: imageHeight)
        return rect
    }
    //MARK: - 打开图片浏览器
    private func openBrowser(cell: PhotoLibraryCell, indexPath: NSIndexPath, models: [ALAssentModel]){
        //用collectionView转换cell的位置
        let cellRect = collectionView.convertRect(cell.frame, toView: nil)
        let imageRect = calculateImageRect(cell.imageView.image!)
        let pvc = PreviewViewController(alassetModels: models, countPhoto: countPhoto, indexPath: indexPath)
        pvc.transitioningDelegate = self
        previewPresentAnimator.originFrame = cellRect
        previewPresentAnimator.image = cell.imageView.image!
        previewPresentAnimator.lastRect = imageRect
        previewDismissAnimator.lastRect = imageRect
        previewDismissAnimator.originFrame = cellRect
        previewDismissAnimator.photoClv = collectionView
        presentViewController(pvc, animated: true, completion: nil)
    }
    //MARK: - 切换分组照片
    @objc private func switchGroup(notice: NSNotification){
        //注意: 但凡通过网络或者通知获取到的数据,都需要进行安全校验
        guard let gTypeStr = notice.userInfo!["gType"] as? String else{
            return
        }
        dealGroupData(gTypeStr)
    }
    private func dealGroupData(gType: String){
        //TODO
        alassetModels = [ALAssentModel]()
        var _index = 0
        for groupM in alassentGroups{
            if gType == "\(groupM.valueForProperty(ALAssetsGroupPropertyType))" {
                selectAssetsGroup = alassentGroups[_index]
                break
            }
            _index = _index + 1
        }
    }
    //MARK: - 拍照
    private func fromPhotograph(){
        //创建图片控制器
        let picker = UIImagePickerController()
        picker.delegate = self
        //设置来源
        picker.sourceType = .Camera
        //默认后置
        picker.cameraDevice = .Rear
        //设置闪光灯
        picker.cameraFlashMode = .Off
        //允许编辑
        picker.allowsEditing = false
        //打开相机
        presentViewController(picker, animated: true, completion: nil)
    }
    //MARK: - 选中传过来的图片
    private func dealSelectAlassent(){
        guard var _selectedAlassent = selectedAlassentModel where selectedAlassentModel!.count > 0 else{
            return
        }
        _selectedAlassent.removeLast()
        var selectedCount = 0
        for _alm in alassetModels {
            for _m in _selectedAlassent{
                if _alm.orginIndex == _m.orginIndex{
                    _alm.isChecked = true
                    selectedCount = selectedCount + 1
                    continue
                }
            }
        }
        countPhoto = selectedCount
        dealCountPhoto()
    }
    //MARK: - 预览图片结束
    @objc private func previewPhotoDone(notice: NSNotification){
        guard let previewModels = notice.userInfo!["alassetModels"] as? [ALAssentModel] else{
            return
        }
        var count = 0
        for _m in alassetModels{
            for _p in previewModels{
                if _m.orginIndex == _p.orginIndex{
                    _m.isChecked = _p.isChecked
                    if _m.isChecked{
                        count = count + 1
                    }
                }
            }
        }
        countPhoto = count
        dealCountPhoto()
        collectionView.reloadData()
    }
    deinit{
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
}
//MARK: - UICollectionViewDataSource代理
extension PhotoViewController: UICollectionViewDataSource{
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return alassetModels.count ?? 0
    }
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(PhotoIdentifier, forIndexPath: indexPath) as! PhotoLibraryCell
        cell.delegate = self
        cell.assent = alassetModels[indexPath.item]
        cell.index = indexPath.item
        return cell
    }
}
//MARK: - UICollectionViewDelegate代理
extension PhotoViewController: UICollectionViewDelegate{
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        let cell = collectionView.cellForItemAtIndexPath(indexPath) as! PhotoLibraryCell
        if alassetModels[indexPath.item].isFirst {
            fromPhotograph()
            return
        }
        let currentIndexPath = NSIndexPath(forItem: indexPath.item - 1, inSection: indexPath.section)
        openBrowser(cell, indexPath: currentIndexPath, models: alassetModels)
    }
}
//MARK: - PhotoLibraryCellDelegate代理
extension PhotoViewController: PhotoLibraryCellDelegate{
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
            previewBtn.enabled = true
        }else{
            rightButton.frame.size = CGSize(width: 70, height: 28)
            rightButton.setTitle("下一步", forState: .Normal)
            rightButton.selected = false
            rightButton.enabled = false
            previewBtn.enabled = false
        }
    }
}
//MARK: - UIViewControllerTransitioningDelegate代理
extension PhotoViewController: UIViewControllerTransitioningDelegate{
    func animationControllerForPresentedController(presented: UIViewController, presentingController presenting: UIViewController, sourceController source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return previewPresentAnimator
    }
    func animationControllerForDismissedController(dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return previewDismissAnimator
    }
}
//MARK: - UIImagePickerControllerDelegate代理
extension PhotoViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage, editingInfo: [String : AnyObject]?) {
        //TODO 待完善
        var _selectedPhoto = [ALAssentModel]()
        let aModel = ALAssentModel(alsseet: nil)
        aModel.takePhtoto = image
        _selectedPhoto.append(aModel)
        NSNotificationCenter.defaultCenter().postNotificationName(SelectedPhotoDone, object: self, userInfo: ["alassentModels" : _selectedPhoto])
        picker.dismissViewControllerAnimated(true, completion: nil)
        navigationController?.popViewControllerAnimated(true)
    }
}
//MARK: - 读取相册
extension PhotoViewController {
    func loadAssetsGroups(){
        loadAssetsGroupsWithTypes(types) { [unowned self] (groups) -> () in
            if groups.count > 0{
                self.titleButton.enabled = true
                self.selectAssetsGroup = groups.first
                self.alassentGroups = groups
                self.popoverView = PPopoverView(alasentGroupModels: groups)
            }else{
                self.titleButton.enabled = false
            }
        }
    }
    //MARK: - 读取所有组
    func loadAssetsGroupsWithTypes(types:[UInt32], completion: (groups: [ALAssetsGroup])->()){
        var assentGroups = [ALAssetsGroup]()
        var numberOfFinishedTypes = 0

        for _type in types{
            PhotoViewController.assetsLibrary.enumerateGroupsWithTypes(_type, usingBlock: { (assentGroup, stop) -> Void in

                    if let _group = assentGroup {
                        _group.setAssetsFilter(ALAssetsFilter.allPhotos())
                        if (_group.numberOfAssets() > 0) {
                            assentGroups.append(_group)
                        }
                    }else{
                        numberOfFinishedTypes++
                    }
                    if (numberOfFinishedTypes == self.types.count) {
                        completion(groups: assentGroups)
                    }
                }, failureBlock: { (error) -> Void in
                    print(error.description)
            })
        }

    }
    //MARK: - 读取组的所有图片
    func loadAllAssetsForGroups(){
        //alassetModels   ALAssentModel
        //TODO
        self.alassetModels = [ALAssentModel]()
        let assentCount = selectAssetsGroup!.numberOfAssets()
        selectAssetsGroup!.enumerateAssetsUsingBlock({ (result, index, stop) -> Void in
            if let assent = result {
                let assentModel = ALAssentModel(alsseet: assent)
                self.alassetModels.append(assentModel)
            }
            if  index == (assentCount - 1){
                self.alassetModels = self.alassetModels.reverse()
                var _index = 1
                for aModel in self.alassetModels{
                    aModel.orginIndex = _index
                    _index = _index + 1
                }
                //添加一条空数据
                let alassentModel = ALAssentModel(alsseet: nil)
                alassentModel.isFirst = true
                self.alassetModels.insert(alassentModel, atIndex: 0)
                //处理已经选中的图片
                self.dealSelectAlassent()
                self.collectionView.reloadData()
                stop
            }
        })

    }
}
//MARK: - 标题按钮
class HeadButton: UIButton {
    //通过纯代码调用
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    //通过xib/storyboard调用
    required init?(coder aDecoder: NSCoder) {
        //系统对initWithCoder的默认实现是报一个致命错误
        //        fatalError("init(coder:) has not been implemented")
        super.init(coder: aDecoder)
        setupUI()
    }

    private func setupUI(){
        setImage(UIImage(named: "navigationbar_arrow_down"), forState: .Normal)
        setImage(UIImage(named: "navigationbar_arrow_up"), forState: .Selected)
        setTitleColor(UIColor.grayColor(), forState: .Normal)
        sizeToFit()

    }
    override func setTitle(title: String?, forState state: UIControlState) {
        super.setTitle((title ?? "") + "   ", forState: state)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        /*
        //offsetInPlace用于控制控件移位(有时候可能不对,系统肯能会调用多次layoutSubviews)
        titleLabel?.frame.offsetInPlace(dx: -imageView!.frame.width, dy: 0)
        imageView?.frame.offsetInPlace(dx: titleLabel!.frame.width, dy: 0)
        */
        titleLabel?.frame.origin.x = 0
        imageView?.frame.origin.x = titleLabel!.frame.width
    }
}