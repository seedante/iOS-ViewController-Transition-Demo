//
//  PresentTransitionDelegate.swift
//  CustomPresentationTransition
//
//  Created by seedante on 15/12/17.
//  Copyright © 2015年 seedante. All rights reserved.
//

import UIKit

class SDEModalTransitionDelegate: NSObject, UIViewControllerTransitioningDelegate {

    func animationControllerForPresentedController(presented: UIViewController, presentingController presenting: UIViewController, sourceController source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return OverlayAnimationController()
        //Or
//        let transitionType = SDETransitionType.modalTransition(.presentation)
//        return SlideAnimationController(type: transitionType)
    }
    
    func animationControllerForDismissedController(dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return OverlayAnimationController()
        //Or
//        let transitionType = SDETransitionType.modalTransition(.dismissal)
//        return SlideAnimationController(type: transitionType)
    }
    
    @available(iOS 8.0, *)
    func presentationControllerForPresentedViewController(presented: UIViewController, presentingViewController presenting: UIViewController, sourceViewController source: UIViewController) -> UIPresentationController? {
        return OverlayPresentationController(presentedViewController: presented, presenting: presenting)
    }
}
