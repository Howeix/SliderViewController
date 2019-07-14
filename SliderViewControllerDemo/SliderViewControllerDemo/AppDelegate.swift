//
//  AppDelegate.swift
//  SliderViewControllerDemo
//
//  Created by Jack on 2019/6/14.
//  Copyright © 2019 Howeix. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        let vcStrArr = ["新闻","娱乐"]
        var vcArr = [UIViewController]()
        for _ in 0 ..< vcStrArr.count {
            let vc = UIViewController()
            vc.view.backgroundColor = UIColor(red: CGFloat(arc4random_uniform(UInt32(255.0))) / 255.0, green: CGFloat(arc4random_uniform(UInt32(255.0))) / 255.0, blue: CGFloat(arc4random_uniform(UInt32(255.0))) / 255.0, alpha: 1.0)
            vcArr.append(vc)
        }
        let sliderVC = SliderViewController(titles: vcStrArr, viewControllers: vcArr, titleSelColor: UIColor.magenta)
        let navvc = UINavigationController(rootViewController: sliderVC)
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.rootViewController = navvc
        window?.makeKeyAndVisible()
        return true
    }

}

