//
//  Animator.swift
//  LHCustomTransition
//
//  Created by huangwenchen on 16/4/19.
//  Copyright © 2016年 WenchenHuang. All rights reserved.
//

import Foundation
import UIKit

class PreviewPresentAnimator: NSObject,UIViewControllerAnimatedTransitioning{
    var originFrame = CGRectZero
    var lastRect = CGRectZero
    var image = UIImage()
    func transitionDuration(transitionContext: UIViewControllerContextTransitioning?) -> NSTimeInterval {
        return 0.3
    }

    func animateTransition(transitionContext: UIViewControllerContextTransitioning) {
        let containView = transitionContext.containerView()
        guard let toView = transitionContext.viewControllerForKey(UITransitionContextToViewControllerKey)?.view else{
            return
        }
        let imageView = UIImageView(image: image)
        //设置图片的frame
        imageView.frame = originFrame

        containView?.addSubview(imageView)
        UIView.animateWithDuration(transitionDuration(transitionContext), animations: { () -> Void in
            imageView.frame = self.lastRect
            }) { (_) -> Void in
                // 移除自己添加的UIImageView
                imageView.removeFromSuperview()
                // 显示图片浏览器
                transitionContext.containerView()?.addSubview(toView)
                // 告诉系统动画执行完毕
                transitionContext.completeTransition(true)
        }
    }
}
protocol PreviewDismisssDelegate: NSObjectProtocol{
    func getLastCellRect(indexPath: NSIndexPath) -> CGRect
}
class PreviewDismisssAnimator: NSObject,UIViewControllerAnimatedTransitioning{
    var originFrame = CGRectZero
    var lastRect = CGRectZero
    var photoClv: UICollectionView?
//    var delegate: PreviewDismisssDelegate?
    func transitionDuration(transitionContext: UIViewControllerContextTransitioning?) -> NSTimeInterval {
        return 0.3
    }

    func animateTransition(transitionContext: UIViewControllerContextTransitioning) {
        let containView = transitionContext.containerView()
        //Collection View
        guard let toView = transitionContext.viewControllerForKey(UITransitionContextToViewControllerKey)?.view else {
            return
        }
        guard let fromViewCtl = transitionContext.viewControllerForKey(UITransitionContextFromViewControllerKey) as? PreviewViewController else{
            return
        }
        // PreviewViewController
        let indexPath = NSIndexPath(forItem: fromViewCtl._currentImageIndex, inSection: 0)
        //获得最后显示图片的坐标
        //collectionView的Return Value
        //The cell object at the corresponding index path or nil if the cell is not visible or indexPath is out of range.
        photoClv!.layoutIfNeeded()
        if let cell = photoClv!.cellForItemAtIndexPath(indexPath){
            originFrame = photoClv!.convertRect(cell.frame, toView: toView)
        }

        let fromView = fromViewCtl.view
        let xScale = originFrame.size.width/toView.frame.size.width
        let yScale = originFrame.size.height/toView.frame.size.height
        containView?.addSubview(toView)
        containView?.bringSubviewToFront(fromView)
        UIView.animateWithDuration(transitionDuration(transitionContext), animations: { () -> Void in
            fromView.center = CGPointMake(CGRectGetMidX(self.originFrame), CGRectGetMidY(self.originFrame))
            fromView.transform = CGAffineTransformMakeScale(xScale, yScale)
            }) { (finished) -> Void in
                // 告诉系统动画执行完毕
                transitionContext.completeTransition(true)
        }

    }
}