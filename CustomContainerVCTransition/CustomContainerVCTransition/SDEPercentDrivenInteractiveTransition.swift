//
//  SDEPercentDrivenInteractiveTransition.swift
//  CustomContainerVCTransition
//
//  Created by seedante on 15/12/27.
//  Copyright © 2015年 seedante. All rights reserved.
//

import UIKit

class SDEPercentDrivenInteractiveTransition: NSObject, UIViewControllerInteractiveTransitioning {
    
    weak var containerTransitionContext: ContainerTransitionContext?
    
    func startInteractiveTransition(_ transitionContext: UIViewControllerContextTransitioning) {
        if let context = transitionContext as? ContainerTransitionContext{
            containerTransitionContext = context
            containerTransitionContext?.activateInteractiveTransition()
        }else{
            fatalError("\(transitionContext) is not class or subclass of ContainerTransitionContext")
        }
    }
    
    func updateInteractiveTransition(_ percentComplete: CGFloat){
        containerTransitionContext?.updateInteractiveTransition(percentComplete)
    }
    
    func cancelInteractiveTransition(){
        containerTransitionContext?.cancelInteractiveTransition()
    }
    
    func finishInteractiveTransition(){
        containerTransitionContext?.finishInteractiveTransition()
    }
    
}
