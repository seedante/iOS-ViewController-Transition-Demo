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
    func containerController(_ containerController: SDEContainerViewController, animationControllerForTransitionFromViewController fromVC: UIViewController, toViewController toVC: UIViewController) -> UIViewControllerAnimatedTransitioning?
    @objc optional func containerController(_ containerController: SDEContainerViewController, interactionControllerForAnimation animationController: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning?
}

class SDEContainerViewControllerDelegate: NSObject, ContainerViewControllerDelegate {
    
    var interactionController = SDEPercentDrivenInteractiveTransition()
    
    func containerController(_ containerController: SDEContainerViewController, animationControllerForTransitionFromViewController fromVC: UIViewController, toViewController toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        let fromIndex = containerController.viewControllers!.index(of: fromVC)!
        let toIndex = containerController.viewControllers!.index(of: toVC)!
        let tabChangeDirection: TabOperationDirection = toIndex < fromIndex ? TabOperationDirection.left : TabOperationDirection.right
        let transitionType = SDETransitionType.tabTransition(tabChangeDirection)
        let slideAnimationController = SlideAnimationController(type: transitionType)
        return slideAnimationController
    }
    
    func containerController(_ containerController: SDEContainerViewController, interactionControllerForAnimation animationController: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        return interactionController
    }
}
