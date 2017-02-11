//
//  OverlayAnimationController.swift
//  CustomPresentationTransition
//
//  Created by seedante on 15/12/20.
//  Copyright © 2015年 seedante. All rights reserved.
//

import UIKit

class OverlayAnimationController: NSObject, UIViewControllerAnimatedTransitioning {
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.3
    }

    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        let containerView = transitionContext.containerView
        guard let fromVC = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.from), let toVC = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.to) else{
            return
        }
                
        let fromView = fromVC.view
        let toView = toVC.view
        let duration = self.transitionDuration(using: transitionContext)
        
        if toVC.isBeingPresented{
            containerView.addSubview(toView!)
            let toViewWidth = containerView.frame.width * 2 / 3, toViewHeight = containerView.frame.height * 2 / 3
            toView?.center = containerView.center
            toView?.bounds = CGRect(x: 0, y: 0, width: 1, height: toViewHeight)

            if #available(iOS 8, *){
                UIView.animate(withDuration: duration, delay: 0, options: .curveEaseInOut, animations: {
                    toView?.bounds = CGRect(x: 0, y: 0, width: toViewWidth, height: toViewHeight)
                    }, completion: {_ in
                        transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
                })
            }else{
                // 文章里的示范代码是基于 iOS 7 以上的系统的，但是升级到 Swift 3.0 后，这段代码就没用了，仅对应文章里的旧代码。
                // 这段代码给 toView 添加了一个半透明的背景，在 iOS 8 中，这个背景由 OverlayPresentationController.swift 去添加。
                let dimmingView = UIView()
                containerView.insertSubview(dimmingView, belowSubview: toView!)
                dimmingView.backgroundColor = UIColor(white: 0.0, alpha: 0.5)
                dimmingView.center = containerView.center
                dimmingView.bounds = CGRect(x: 0, y: 0, width: toViewWidth, height: toViewHeight)
                UIView.animate(withDuration: duration, delay: 0, options: .curveEaseOut, animations: {
                    dimmingView.bounds = containerView.bounds
                    toView?.bounds = CGRect(x: 0, y: 0, width: toViewWidth, height: toViewHeight)
                    }, completion: { _ in
                        transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
                })

            }
        }
        //Dismissal 转场中不要将 toView 添加到 containerView
        if fromVC.isBeingDismissed{
            let fromViewHeight = fromView?.frame.height
            UIView.animate(withDuration: duration, animations: {
                fromView?.bounds = CGRect(x: 0, y: 0, width: 1, height: fromViewHeight!)
                }, completion: { _ in
                    transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
            })
        }
    }
}
