//
//  PushAndPopAnimationController.swift
//  NavigationControllerTransitionDemo
//
//  Created by seedante on 15/12/9.
//  Copyright © 2015年 seedante. All rights reserved.
//

import UIKit

enum SDETransitionType{
    case navigationTransition(UINavigationControllerOperation)
    case tabTransition(TabOperationDirection)
    case modalTransition(ModalOperation)
}

enum TabOperationDirection{
    case left, right
}

enum ModalOperation{
    case presentation, dismissal
}

class SlideAnimationController: NSObject, UIViewControllerAnimatedTransitioning {

    fileprivate var transitionType: SDETransitionType

    init(type: SDETransitionType) {
        transitionType = type
        super.init()
    }

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
        
        var translation = containerView.frame.width
        var toViewTransform = CGAffineTransform.identity
        var fromViewTransform = CGAffineTransform.identity
        
        switch transitionType{
        case .navigationTransition(let operation):
            translation = operation == .push ? translation : -translation
            toViewTransform = CGAffineTransform(translationX: translation, y: 0)
            fromViewTransform = CGAffineTransform(translationX: -translation, y: 0)
        case .tabTransition(let direction):
            translation = direction == .left ? translation : -translation
            fromViewTransform = CGAffineTransform(translationX: translation, y: 0)
            toViewTransform = CGAffineTransform(translationX: -translation, y: 0)
        case .modalTransition(let operation):
            translation =  containerView.frame.height
            toViewTransform = CGAffineTransform(translationX: 0, y: (operation == .presentation ? translation : 0))
            fromViewTransform = CGAffineTransform(translationX: 0, y: (operation == .presentation ? 0 : translation))
        }

        switch transitionType{
        case .modalTransition(let operation):
            switch operation{
            case .presentation: containerView.addSubview(toView!)
            case .dismissal: break
            }
        default: containerView.addSubview(toView!)
        }
        
        toView?.transform = toViewTransform
        UIView.animate(withDuration: transitionDuration(using: transitionContext), animations: {
            fromView?.transform = fromViewTransform
            toView?.transform = CGAffineTransform.identity
            }, completion: { finished in
                fromView?.transform = CGAffineTransform.identity
                toView?.transform = CGAffineTransform.identity
                transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
        })
    }
    
    /*
    下面这段被注释的代码是使用 Core Animation 来实现转场，在非交互转场时没有问题，在交互转场下会有点瑕疵，要达到完美要麻烦一点。
    
    交互转场必须用 UIView Animtion API 才能实现完美的控制，其实并不是 Core Animation 做不到，
    毕竟 UIView Animation 是基于 Core Animation 的，那为什么苹果的工程师在 WWDC 上说必须使用前者呢。
    因为使用 Core Animation 来实现成本高啊，在转场中做到与 UIView Animation 同样的事情配置麻烦些，估计很多人都不会配置，
    而且在交互转场中会比较麻烦，本来转场 API 已经分裂得够复杂了，老老实实用高级 API 吧。
    
    上面说的 UIView Animation API 指的是带 completion 闭包的 API，使用 Core Animation 来实现这个闭包需要配置
    CATransaction，这就是麻烦的地方，还是用高级的 API 吧。
    
    在自定义的容器控制器转场中，交互部分需要我们自己动手实现控制动画的进度，此时 使用 Core Animation 或 UIView Animation
    区别不大，重点在于在手势中如何控制动画。
    */

//    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
//        let containerView = transitionContext.containerView
//        guard let fromVC = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.from), let toVC = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.to) else{
//            return
//        }
//
//        
//        let fromView = fromVC.view
//        let toView = toVC.view
//        
//        var translation = containerView.frame.width
//        var toViewTransform = CATransform3DIdentity
//        var fromViewTransform = CATransform3DIdentity
//        
//        switch transitionType{
//        case .navigationTransition(let operation):
//            translation = operation == .push ? translation : -translation
//            toViewTransform = CATransform3DMakeTranslation(translation, 0, 0)
//            fromViewTransform = CATransform3DMakeTranslation(-translation, 0, 0)
//        case .tabTransition(let direction):
//            translation = direction == .left ? translation : -translation
//            fromViewTransform = CATransform3DMakeTranslation(translation, 0, 0)
//            toViewTransform = CATransform3DMakeTranslation(-translation, 0, 0)
//        case .modalTransition(let operation):
//            translation =  containerView.frame.height
//            toViewTransform = CATransform3DMakeTranslation(0, (operation == .presentation ? translation : 0), 0)
//            fromViewTransform = CATransform3DMakeTranslation(0, (operation == .presentation ? 0 : translation), 0)
//        }
//        
//        switch transitionType{
//        case .modalTransition(let operation):
//            switch operation{
//            case .presentation: containerView.addSubview(toView!)
//                //在 dismissal 转场中，不要添加 toView，否则黑屏
//            case .dismissal: break
//            }
//        default: containerView.addSubview(toView!)
//        }
//        
//        let duration = transitionDuration(using: transitionContext)
//        CATransaction.setCompletionBlock({
//            fromView?.layer.transform = CATransform3DIdentity
//            toView?.layer.transform = CATransform3DIdentity
//            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
//        })
//        
//        CATransaction.setAnimationDuration(duration)
//        CATransaction.begin()
//        
//        let toViewAnimation = CABasicAnimation(keyPath: "transform")
//        toViewAnimation.fromValue = NSValue.init(caTransform3D: toViewTransform)
//        toViewAnimation.toValue = NSValue.init(caTransform3D: CATransform3DIdentity)
//        toViewAnimation.duration = duration
//        toView?.layer.add(toViewAnimation, forKey: "move")
//        
//        let fromViewAnimation = CABasicAnimation(keyPath: "transform")
//        fromViewAnimation.fromValue = NSValue.init(caTransform3D: CATransform3DIdentity)
//        fromViewAnimation.toValue = NSValue.init(caTransform3D: fromViewTransform)
//        fromViewAnimation.duration = duration
//        fromView?.layer.add(fromViewAnimation, forKey: "move")
//        
//        CATransaction.commit()
//    }

}

