//
//  UIImage+Extension.swift
//  ZCJImagePicker
//
//  Created by zhoucj on 16/8/31.
//  Copyright © 2016年 zhoucj. All rights reserved.
//

import UIKit
extension UIImage{
    /**
     根据传入的高度生成一张图片
     按照图片的宽高比来压缩以前的图片
     - parameter width: 宽度
     - returns: 新的Image
     */
    func imageWithScale(width: CGFloat) -> UIImage{
        //根据宽高比算出高度
        let _height = width * size.height/size.width
        //按尺寸生成图片
        let currentSize = CGSize(width: width, height: _height)
        UIGraphicsBeginImageContext(currentSize)
        drawInRect(CGRect(origin: CGPointZero, size: currentSize))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage
    }
}

