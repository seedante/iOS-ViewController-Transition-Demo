//
//  OverlayPresentationController.swift
//  CustomPresentationTransition
//
//  Created by seedante on 15/12/17.
//  Copyright © 2015年 seedante. All rights reserved.
//

import UIKit

class OverlayPresentationController: UIPresentationController {
    let dimmingView = UIView()
    
    override func presentationTransitionWillBegin() {
        containerView?.addSubview(dimmingView)
        
        let dimmingViewInitailWidth = containerView!.frame.width * 2 / 3, dimmingViewInitailHeight = containerView!.frame.height * 2 / 3
        dimmingView.backgroundColor = UIColor(white: 0.0, alpha: 0.5)
        dimmingView.center = containerView!.center
        dimmingView.bounds = CGRect(x: 0, y: 0, width: dimmingViewInitailWidth , height: dimmingViewInitailHeight)
        
        _ = presentedViewController.transitionCoordinator?.animate(alongsideTransition: {
            _ in
            self.dimmingView.bounds = self.containerView!.bounds
            }, completion: nil)
    }
    
    override func dismissalTransitionWillBegin() {
        _ = presentedViewController.transitionCoordinator?.animate(alongsideTransition: { _ in
            self.dimmingView.alpha = 0.0
            }, completion: nil)
    }
    
    override func containerViewWillLayoutSubviews(){
        dimmingView.center = containerView!.center
        dimmingView.bounds = containerView!.bounds
        
        let width = containerView!.frame.width * 2 / 3, height = containerView!.frame.height * 2 / 3
        presentedView?.center = containerView!.center
        presentedView?.bounds = CGRect(x: 0, y: 0, width: width, height: height)
    }
}
