//
//  OverlayAnimationController.swift
//  CustomPresentationTransition
//
//  Created by seedante on 15/12/20.
//  Copyright © 2015年 seedante. All rights reserved.
//

import UIKit

class OverlayAnimationController: NSObject, UIViewControllerAnimatedTransitioning {
    
    func transitionDuration(transitionContext: UIViewControllerContextTransitioning?) -> NSTimeInterval {
        return 0.3
    }

    func animateTransition(transitionContext: UIViewControllerContextTransitioning) {
        guard let fromVC = transitionContext.viewControllerForKey(UITransitionContextFromViewControllerKey), let toVC = transitionContext.viewControllerForKey(UITransitionContextToViewControllerKey) else{
            return
        }
        
        guard let containerView = transitionContext.containerView() else{
            return
        }
        
        let fromView = fromVC.view
        let toView = toVC.view
        let duration = self.transitionDuration(transitionContext)
        
        if toVC.isBeingPresented(){
            containerView.addSubview(toView)
            let toViewWidth = containerView.frame.width * 2 / 3, toViewHeight = containerView.frame.height * 2 / 3
            toView.center = containerView.center
            toView.bounds = CGRect(x: 0, y: 0, width: 1, height: toViewHeight)

            if #available(iOS 8, *){
                UIView.animateWithDuration(duration, delay: 0, options: .CurveEaseInOut, animations: {
                    toView.bounds = CGRect(x: 0, y: 0, width: toViewWidth, height: toViewHeight)
                    }, completion: {_ in
                        let isCancelled = transitionContext.transitionWasCancelled()
                        transitionContext.completeTransition(!isCancelled)
                })
            }else{
                let dimmingView = UIView()
                containerView.insertSubview(dimmingView, belowSubview: toView)
                dimmingView.backgroundColor = UIColor(white: 0.0, alpha: 0.5)
                dimmingView.center = containerView.center
                dimmingView.bounds = CGRect(x: 0, y: 0, width: toViewWidth, height: toViewHeight)
                UIView.animateWithDuration(duration, delay: 0, options: .CurveEaseOut, animations: {
                    dimmingView.bounds = containerView.bounds
                    toView.bounds = CGRect(x: 0, y: 0, width: toViewWidth, height: toViewHeight)
                    }, completion: { _ in
                        let isCancelled = transitionContext.transitionWasCancelled()
                        transitionContext.completeTransition(!isCancelled)
                })

            }
        }
        //Dismissal 转场中不要将 toView 添加到 containerView
        if fromVC.isBeingDismissed(){
            let fromViewHeight = fromView.frame.height
            UIView.animateWithDuration(duration, animations: {
                fromView.bounds = CGRect(x: 0, y: 0, width: 1, height: fromViewHeight)
                }, completion: { _ in
                    let isCancelled = transitionContext.transitionWasCancelled()
                    transitionContext.completeTransition(!isCancelled)
            })
        }
    }
}
