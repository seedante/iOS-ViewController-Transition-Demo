//
//  PushAndPopAnimationController.swift
//  NavigationControllerTransitionDemo
//
//  Created by seedante on 15/12/9.
//  Copyright © 2015年 seedante. All rights reserved.
//

import UIKit

enum SDETransitionType{
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

    private var transitionType: SDETransitionType

    init(type: SDETransitionType) {
        transitionType = type
        super.init()
    }

    /*
    在 UITabBarController 的转场里，如果你在动画控制器里实现了 animationEnded: 方法，这个方法会被调用2次。
    而在 NavigationController 和 Modal 转场里没有这种问题，观察函数帧栈也发现比前两种转场多了一次私有函数调用：
    [UITabBarController transitionFromViewController:toViewController:transition:shouldSetSelected:]
    该方法和 UIViewController 的 transitionFromViewController:toViewController:duration:options:animations:completion: 
    方法应该是一脉相承的，用于控制器的转换，我在文章里实现自定义容器控制器转场时也用过这个方法来实现自定义转场，不过由于测试不完整我在文章里将这块删掉了。
    
    最后，还没办法解决这个问题。再次感谢 @llwenDeng 发现这个问题。
    */
//    func animationEnded(transitionCompleted: Bool) {
//        print("animationEnded: \(transitionCompleted)")
//    }

    
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