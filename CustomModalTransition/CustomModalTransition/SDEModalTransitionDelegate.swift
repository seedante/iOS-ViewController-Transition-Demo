//
//  PresentTransitionDelegate.swift
//  CustomPresentationTransition
//
//  Created by seedante on 15/12/17.
//  Copyright © 2015年 seedante. All rights reserved.
//

import UIKit

class SDEModalTransitionDelegate: NSObject, UIViewControllerTransitioningDelegate {

    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return OverlayAnimationController()
        //Or
//        let transitionType = SDETransitionType.modalTransition(.presentation)
//        return SlideAnimationController(type: transitionType)
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return OverlayAnimationController()
        //Or
//        let transitionType = SDETransitionType.modalTransition(.dismissal)
//        return SlideAnimationController(type: transitionType)
    }
    
    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        return OverlayPresentationController(presentedViewController: presented, presenting: presenting)
    }
}
