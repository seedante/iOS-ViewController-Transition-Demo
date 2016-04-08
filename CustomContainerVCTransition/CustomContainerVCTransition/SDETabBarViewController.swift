//
//  SDETabBarViewController.swift
//  CustomContainerVCTransition
//
//  Created by seedante on 15/12/29.
//  Copyright © 2015年 seedante. All rights reserved.
//

import UIKit

class SDETabBarViewController: SDEContainerViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //Configure Interactive Transiton
        let pangesture = UIPanGestureRecognizer(target: self, action: #selector(SDETabBarViewController.handlePan(_:)))
        view.addGestureRecognizer(pangesture)
    }
    
    func handlePan(gesture: UIPanGestureRecognizer){
        if viewControllers == nil || viewControllers?.count < 2 || containerTransitionDelegate == nil || !(containerTransitionDelegate is SDEContainerViewControllerDelegate) {
            return
        }
        
        let delegate = containerTransitionDelegate as! SDEContainerViewControllerDelegate
        
        let translationX =  gesture.translationInView(view).x
        let translationAbs = translationX > 0 ? translationX : -translationX
        let progress = translationAbs / view.frame.width
        switch gesture.state{
        case .Began:
            interactive = true
            let velocityX = gesture.velocityInView(view).x
            if velocityX < 0{
                if selectedIndex < viewControllers!.count - 1{
                    selectedIndex += 1
                }
            }else{
                if selectedIndex > 0{
                    selectedIndex -= 1
                }
            }
        case .Changed:
            delegate.interactionController.updateInteractiveTransition(progress)
        case .Cancelled, .Ended:
            interactive = false
            if progress > 0.6{
                delegate.interactionController.finishInteractiveTransition()
            }else{
                delegate.interactionController.cancelInteractiveTransition()
            }
        default: break
        }
    }
}
