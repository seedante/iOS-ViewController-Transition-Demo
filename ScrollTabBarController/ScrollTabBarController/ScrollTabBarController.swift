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
        self.tabBar.tintColor = UIColor.green
        
        panGesture.addTarget(self, action: #selector(ScrollTabBarController.handlePan(panGesture:)))
        view.addGestureRecognizer(panGesture)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func handlePan(panGesture: UIPanGestureRecognizer){
        let translationX =  panGesture.translation(in: view).x
        let translationAbs = translationX > 0 ? translationX : -translationX
        let progress = translationAbs / view.frame.width
        switch panGesture.state{
        case .began:
            tabBarVCDelegate.interactive = true
            let velocityX = panGesture.velocity(in: view).x
            if velocityX < 0{
                if selectedIndex < subViewControllerCount - 1{
                    selectedIndex += 1
                }
            }else {
                if selectedIndex > 0{
                    selectedIndex -= 1
                }
            }
        case .changed:
            tabBarVCDelegate.interactionController.update(progress)
        case .cancelled, .ended:
            /*这里有个小问题，转场结束或是取消时有很大几率出现动画不正常的问题。在8.1以上版本的模拟器中都有发现，7.x 由于缺乏条件尚未测试，
              但在我的 iOS 9.2 的真机设备上没有发现，而且似乎只在 UITabBarController 的交互转场中发现了这个问题。在 NavigationController 暂且没发现这个问题，
              Modal 转场尚未测试，因为我在 Demo 里没给它添加交互控制功能。
              
              测试不完整，具体原因也未知，不过解决手段找到了。多谢 @llwenDeng 发现这个 Bug 并且找到了解决手段。
              解决手段是修改交互控制器的 completionSpeed 为1以下的数值，这个属性用来控制动画速度，我猜测是内部实现在边界判断上有问题。
              这里其修改为0.99，既解决了 Bug 同时尽可能贴近原来的动画设定。
            */
            if progress > 0.3{
                tabBarVCDelegate.interactionController.completionSpeed = 0.99
                tabBarVCDelegate.interactionController.finish()
            }else{
                //转场取消后，UITabBarController 自动恢复了 selectedIndex 的值，不需要我们手动恢复。
                tabBarVCDelegate.interactionController.completionSpeed = 0.99
                tabBarVCDelegate.interactionController.cancel()
            }
            tabBarVCDelegate.interactive = false
        default: break
        }
    }
    
}
