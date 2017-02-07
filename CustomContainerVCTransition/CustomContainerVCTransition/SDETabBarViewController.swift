//
//  SDETabBarViewController.swift
//  CustomContainerVCTransition
//
//  Created by seedante on 15/12/29.
//  Copyright © 2015年 seedante. All rights reserved.
//

import UIKit
// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}


class SDETabBarViewController: SDEContainerViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //Configure Interactive Transiton
        let pangesture = UIPanGestureRecognizer(target: self, action: #selector(SDETabBarViewController.handlePan(_:)))
        view.addGestureRecognizer(pangesture)
    }
    
    func handlePan(_ gesture: UIPanGestureRecognizer){
        if viewControllers == nil || viewControllers?.count < 2 || containerTransitionDelegate == nil || !(containerTransitionDelegate is SDEContainerViewControllerDelegate) {
            return
        }
        
        let delegate = containerTransitionDelegate as! SDEContainerViewControllerDelegate
        
        let translationX =  gesture.translation(in: view).x
        let translationAbs = translationX > 0 ? translationX : -translationX
        let progress = translationAbs / view.frame.width
        switch gesture.state{
        case .began:
            interactive = true
            let velocityX = gesture.velocity(in: view).x
            if velocityX < 0{
                if selectedIndex < viewControllers!.count - 1{
                    selectedIndex += 1
                }
            }else{
                if selectedIndex > 0{
                    selectedIndex -= 1
                }
            }
        case .changed:
            delegate.interactionController.updateInteractiveTransition(progress)
        case .cancelled, .ended:
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
