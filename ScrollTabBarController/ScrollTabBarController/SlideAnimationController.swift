//
//  PushAndPopAnimationController.swift
//  NavigationControllerTransitionDemo
//
//  Created by seedante on 15/12/9.
//  Copyright © 2015年 seedante. All rights reserved.
//

import UIKit

enum SDETransitionTye{
    case NavigationTransition(UINavigationControllerOperation)
    case TabTransition(TabOperationDirection)
    case ModalTransition(ModalOperation)
}

enum TabOperationDirection{
    case Left, Right
}

enum ModalOperation{
    case Presentation, Dismissal
}

class SlideAnimationController: NSObject, UIViewControllerAnimatedTransitioning {

    private var transitionType: SDETransitionTye

    init(type: SDETransitionTye) {
        transitionType = type
        super.init()
    }

    func transitionDuration(transitionContext: UIViewControllerContextTransitioning?) -> NSTimeInterval {
        return 0.3
    }
    
    func animateTransition(transitionContext: UIViewControllerContextTransitioning) {
        guard let containerView = transitionContext.containerView(), fromVC = transitionContext.viewControllerForKey(UITransitionContextFromViewControllerKey), toVC = transitionContext.viewControllerForKey(UITransitionContextToViewControllerKey) else{
            return  
        }
        
        let fromView = fromVC.view
        let toView = toVC.view
        
        var translation = containerView.frame.width
        var toViewTransform = CGAffineTransformIdentity
        var fromViewTransform = CGAffineTransformIdentity
        
        switch transitionType{
        case .NavigationTransition(let operation):
            translation = operation == .Push ? translation : -translation
            toViewTransform = CGAffineTransformMakeTranslation(translation, 0)
            fromViewTransform = CGAffineTransformMakeTranslation(-translation, 0)
        case .TabTransition(let direction):
            translation = direction == .Left ? translation : -translation
            fromViewTransform = CGAffineTransformMakeTranslation(translation, 0)
            toViewTransform = CGAffineTransformMakeTranslation(-translation, 0)
        case .ModalTransition(let operation):
            translation =  containerView.frame.height
            toViewTransform = CGAffineTransformMakeTranslation(0, (operation == .Presentation ? translation : 0))
            fromViewTransform = CGAffineTransformMakeTranslation(0, (operation == .Presentation ? 0 : translation))
        }

        switch transitionType{
        case .ModalTransition(let operation):
            switch operation{
            case .Presentation: containerView.addSubview(toView)
                //在 dismissal 转场中，不要添加 toView，否则黑屏
            case .Dismissal: break
            }
        default: containerView.addSubview(toView)
        }
        
        toView.transform = toViewTransform
        
        UIView.animateWithDuration(transitionDuration(transitionContext), animations: {
            fromView.transform = fromViewTransform
            toView.transform = CGAffineTransformIdentity
            }, completion: { finished in
                fromView.transform = CGAffineTransformIdentity
                toView.transform = CGAffineTransformIdentity
                
                let isCancelled = transitionContext.transitionWasCancelled()
                transitionContext.completeTransition(!isCancelled)
        })
    }

//    //使用 Core Animation 的话，交互中止时动画直接跳转到最终状态，应该使用 UIView 动画。
//    func animateTransition(transitionContext: UIViewControllerContextTransitioning) {
//        guard let containerView = transitionContext.containerView(), fromVC = transitionContext.viewControllerForKey(UITransitionContextFromViewControllerKey), toVC = transitionContext.viewControllerForKey(UITransitionContextToViewControllerKey) else{
//            return
//        }
//        
//        let fromView = fromVC.view
//        let toView = toVC.view
//        
//        var translation = containerView.frame.width
//        var toViewTransform = CATransform3DIdentity
//        var fromViewTransform = CATransform3DIdentity
//        
//        switch transitionType{
//        case .NavigationTransition(let operation):
//            translation = operation == .Push ? translation : -translation
//            toViewTransform = CATransform3DMakeTranslation(translation, 0, 0)
//            fromViewTransform = CATransform3DMakeTranslation(-translation, 0, 0)
//        case .TabTransition(let direction):
//            translation = direction == .Left ? translation : -translation
//            fromViewTransform = CATransform3DMakeTranslation(translation, 0, 0)
//            toViewTransform = CATransform3DMakeTranslation(-translation, 0, 0)
//        case .ModalTransition(let operation):
//            translation =  containerView.frame.height
//            toViewTransform = CATransform3DMakeTranslation(0, (operation == .Presentation ? translation : 0), 0)
//            fromViewTransform = CATransform3DMakeTranslation(0, (operation == .Presentation ? 0 : translation), 0)
//        }
//        
//        switch transitionType{
//        case .ModalTransition(let operation):
//            switch operation{
//            case .Presentation: containerView.addSubview(toView)
//                //在 dismissal 转场中，不要添加 toView，否则黑屏
//            case .Dismissal: break
//            }
//        default: containerView.addSubview(toView)
//        }
//        
//        let duration = transitionDuration(transitionContext)
//        CATransaction.setCompletionBlock({
//            fromView.layer.transform = CATransform3DIdentity
//            toView.layer.transform = CATransform3DIdentity
//            
//            let isCancelled = transitionContext.transitionWasCancelled()
//            transitionContext.completeTransition(!isCancelled)
//        })
//        
//        CATransaction.setAnimationDuration(duration)
//        CATransaction.begin()
//        
//        let toViewAnimation = CABasicAnimation(keyPath: "transform")
//        toViewAnimation.fromValue = NSValue.init(CATransform3D: toViewTransform)
//        toViewAnimation.toValue = NSValue.init(CATransform3D: CATransform3DIdentity)
//        toViewAnimation.duration = duration
//        toView.layer.addAnimation(toViewAnimation, forKey: "move")
//        
//        let fromViewAnimation = CABasicAnimation(keyPath: "transform")
//        fromViewAnimation.fromValue = NSValue.init(CATransform3D: CATransform3DIdentity)
//        fromViewAnimation.toValue = NSValue.init(CATransform3D: fromViewTransform)
//        fromViewAnimation.duration = duration
//        fromView.layer.addAnimation(fromViewAnimation, forKey: "move")
//        
//        CATransaction.commit()
//    }
    
}