//
//  PhotoLibraryModel.swift
//  图片选择器
//
//  Created by zhoucj on 16/8/25.
//  Copyright © 2016年 zhoucj. All rights reserved.
//

import UIKit
import AssetsLibrary
class ALAssentModel: NSObject {
    var alsseet: ALAsset?
    var isChecked = false
    var isFirst = false
    var orginIndex = -1
    var takePhtoto: UIImage?
    var currentIndex = -1
    init(alsseet: ALAsset?) {
        super.init()
        self.alsseet = alsseet
    }
}
