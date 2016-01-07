//
//  ScrollTabBarController.swift
//  ScrollTabBarController
//
//  Created by seedante on 15/12/9.
//  Copyright © 2015年 seedante. All rights reserved.
//

import UIKit

class ScrollTabBarController: UITabBarController {

    private var panGesture: UIPanGestureRecognizer = UIPanGestureRecognizer()
    private let tabBarVCDelegate = SDETabBarVCDelegate()
    private var subViewControllerCount: Int{
        let count = viewControllers != nil ? viewControllers!.count : 0
        return count
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        delegate = tabBarVCDelegate
        self.tabBar.tintColor = UIColor.greenColor()
        
        panGesture.addTarget(self, action: "handlePan:")
        view.addGestureRecognizer(panGesture)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func handlePan(panGesture: UIPanGestureRecognizer){
        let translationX =  panGesture.translationInView(view).x
        let translationAbs = translationX > 0 ? translationX : -translationX
        let progress = translationAbs / view.frame.width
        switch panGesture.state{
        case .Began:
            tabBarVCDelegate.interactive = true
            let velocityX = panGesture.velocityInView(view).x
            if velocityX < 0{
                if selectedIndex < subViewControllerCount - 1{
                    selectedIndex += 1
                }
            }else {
                if selectedIndex > 0{
                    selectedIndex -= 1
                }
            }
        case .Changed:
            tabBarVCDelegate.interactionController.updateInteractiveTransition(progress)
        case .Cancelled, .Ended:
            if progress > 0.3{
                tabBarVCDelegate.interactionController.finishInteractiveTransition()
            }else{
                //转场取消后，UITabBarController 自动恢复了 selectedIndex 的值，不需要我们手动恢复
                tabBarVCDelegate.interactionController.cancelInteractiveTransition()
            }
            tabBarVCDelegate.interactive = false
        default: break
        }
    }
    
}
