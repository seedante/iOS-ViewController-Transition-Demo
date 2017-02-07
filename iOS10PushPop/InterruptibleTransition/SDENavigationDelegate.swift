//
//  SDENavigationDelegate.swift
//  iOS10PushPop
//
//  Created by seedante on 15/12/9.
//  Copyright © 2015年 seedante. All rights reserved.
//

import UIKit

extension UIViewAnimatingPosition{
    var description: String{
        switch self {
        case .end:
            return "end"
        case .current:
            return "current"
        case .start:
            return "start"
        }
    }
}

@available(iOS 10.0, *)
class SDENavigationDelegate: NSObject, UINavigationControllerDelegate, UIViewControllerAnimatedTransitioning {
    
    var operation: UINavigationControllerOperation = .push
    let duration: TimeInterval = 1
    
    // MARK: UINavigationControllerDelegate
    func navigationController(_ navigationController: UINavigationController, animationControllerFor operation: UINavigationControllerOperation, from fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        self.operation = operation
        return self
    }
    
    // MARK: UIViewControllerAnimatedTransitioning
    /// If you change any of 'duration', keep two 'duration' same.
    var transitionAnimator: UIViewPropertyAnimator = UIViewPropertyAnimator(duration: 1, timingParameters: UISpringTimingParameters(dampingRatio: 1, initialVelocity: CGVector(dx: 1, dy: 0)))
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return duration
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning){
        let containerView = transitionContext.containerView
        guard let fromView = transitionContext.view(forKey: UITransitionContextViewKey.from),
              let toView = transitionContext.view(forKey: UITransitionContextViewKey.to)
        else {
            return
        }
        
        var translation = containerView.frame.width
        translation = operation == .push ? translation : -translation
        containerView.addSubview(toView)
        toView.center.x += translation
        
        transitionAnimator.addAnimations({
            fromView.center.x -= translation
            toView.center.x -= translation
        })
        
        transitionAnimator.addCompletion({ position in
            fromView.center.x = containerView.center.x
            toView.center.x = containerView.center.x
            
            let completed = position == .end ? true : false
            transitionContext.completeTransition(completed)
            print("TransitionAnimation complete at position: \(position.description)")
        })
        transitionAnimator.startAnimation()
        print("Transition did start")
    }
}
