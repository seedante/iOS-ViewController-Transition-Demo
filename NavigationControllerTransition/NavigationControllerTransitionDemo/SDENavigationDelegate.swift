//
//  NavigationControllerDelegate.swift
//  NavigationControllerTransitionDemo
//
//  Created by seedante on 15/12/9.
//  Copyright © 2015年 seedante. All rights reserved.
//

import UIKit

class SDENavigationDelegate: NSObject, UINavigationControllerDelegate {
    
    var interactive = false
    let interactionController = UIPercentDrivenInteractiveTransition()
    
    func navigationController(_ navigationController: UINavigationController, animationControllerFor operation: UINavigationControllerOperation, from fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        let transitionType = SDETransitionType.navigationTransition(operation)
        return SlideAnimationController(type: transitionType)
    }
    
    func navigationController(_ navigationController: UINavigationController, interactionControllerFor animationController: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning?{
        return interactive ? self.interactionController : nil
    }    
}
