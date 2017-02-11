//
//  SDETabBarControllerDelegate.swift
//  ScrollTabBarController
//
//  Created by seedante on 15/12/20.
//  Copyright © 2015年 seedante. All rights reserved.
//

import UIKit

class SDETabBarVCDelegate: NSObject, UITabBarControllerDelegate {
    
    var interactive = false
    let interactionController = UIPercentDrivenInteractiveTransition()
    
    func tabBarController(_ tabBarController: UITabBarController, animationControllerForTransitionFrom fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning?{
        let fromIndex = tabBarController.viewControllers!.index(of: fromVC)!
        let toIndex = tabBarController.viewControllers!.index(of: toVC)!
        
        let tabChangeDirection: TabOperationDirection = toIndex < fromIndex ? TabOperationDirection.left : TabOperationDirection.right
        let transitionType = SDETransitionType.tabTransition(tabChangeDirection)
        let slideAnimationController = SlideAnimationController(type: transitionType)
        return slideAnimationController
    }
   
    func tabBarController(_ tabBarController: UITabBarController, interactionControllerFor animationController: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning?{
        return interactive ? interactionController : nil
    }
}
