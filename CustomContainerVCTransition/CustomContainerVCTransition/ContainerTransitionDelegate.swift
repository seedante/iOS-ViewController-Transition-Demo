//
//  ContainerTransitionDelegate.swift
//  CustomContainerVCTransition
//
//  Created by seedante on 15/12/26.
//  Copyright © 2015年 seedante. All rights reserved.
//
import UIKit

@objc protocol ContainerViewControllerDelegate{
    //Swift don't support protocol object in protocol now. if you want to support interactive transition, set SDEContainerViewController's containerTransitionDelegate to class 'SDEContainerViewControllerDelegate', not protocol 'ContainerViewControllerDelegate'
    //var interactionController: UIViewControllerInteractiveTransitioning?
    func containerController(containerController: SDEContainerViewController, animationControllerForTransitionFromViewController fromVC: UIViewController, toViewController toVC: UIViewController) -> UIViewControllerAnimatedTransitioning?
    optional func containerController(containerController: SDEContainerViewController, interactionControllerForAnimation animationController: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning?
}

class SDEContainerViewControllerDelegate: NSObject, ContainerViewControllerDelegate {
    
    var interactionController = SDEPercentDrivenInteractiveTransition()
    
    func containerController(containerController: SDEContainerViewController, animationControllerForTransitionFromViewController fromVC: UIViewController, toViewController toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        let fromIndex = containerController.viewControllers!.indexOf(fromVC)!
        let toIndex = containerController.viewControllers!.indexOf(toVC)!
        let tabChangeDirection: TabOperationDirection = toIndex < fromIndex ? .Left : .Right
        let transitionType = SDETransitionType.TabTransition(tabChangeDirection)
        let slideAnimationController = SlideAnimationController(type: transitionType)
        return slideAnimationController
    }
    
    func containerController(containerController: SDEContainerViewController, interactionControllerForAnimation animationController: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        return interactionController
    }
}