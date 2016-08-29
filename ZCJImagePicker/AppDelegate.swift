//
//  AppDelegate.swift
//  ZCJImagePicker
//
//  Created by zhoucj on 16/8/27.
//  Copyright © 2016年 zhoucj. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.
        // 创建窗口
        window = UIWindow(frame: UIScreen.mainScreen().bounds)
        let nvc = UINavigationController(rootViewController: RootViewController())
        window?.rootViewController = nvc
        window?.makeKeyAndVisible()
        return true
    }
}

