//
//  InterruptibleNavigationController.swift
//  iOS10PushPop
//
//  Created by seedante on 16/6/28.
//  Copyright © 2016年 seedante. All rights reserved.
//

import UIKit


@available(iOS 10.0, *)
class InterruptibleNavigationController: UINavigationController
{

    var pan = UIPanGestureRecognizer()
    var tap = UITapGestureRecognizer()
    var navigationDelegate: SDENavigationDelegate = SDENavigationDelegate()
    var fractionComplete: CGFloat = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        pan.addTarget(self, action: #selector(InterruptibleNavigationController.handlePan(gesture:)))
        tap.addTarget(self, action: #selector(InterruptibleNavigationController.handleTap(gesture:)))
        view.addGestureRecognizer(pan)
        view.addGestureRecognizer(tap)
        
        delegate = navigationDelegate
    }
    
    func handleTap(gesture: UITapGestureRecognizer){
        let animator = navigationDelegate.transitionAnimator
        
        switch gesture.state {
        case .ended, .cancelled:
            switch animator.state {
            case .active:
                animator.pauseAnimation()
                animator.isReversed = !(animator.isReversed)
                animator.startAnimation()
            default:break
            }
        default:break
        }
    }
    
    
    func handlePan(gesture: UIPanGestureRecognizer){
        let animator = navigationDelegate.transitionAnimator
        
        let translationX =  gesture.translation(in: view).x
        let operation: UINavigationControllerOperation = translationX > 0 ? .pop : .push
        let translationBase: CGFloat = view.frame.width
        let translationAbs = translationX > 0 ? translationX : -translationX
        let percent = translationAbs > translationBase ? 1.0 : translationX / translationBase

        switch gesture.state{
        case .began:
            if animator.isRunning == false{
                switch operation {
                case .pop:
                    if viewControllers.count == 2{
                        popViewController(animated: true)
                    }
                case .push:
                    if viewControllers.count == 1{
                        let nextVC = self.storyboard?.instantiateViewController(withIdentifier: "BlueVC")
                        pushViewController(nextVC!, animated: true)
                    }
                default:break
                }
            }else{
                animator.pauseAnimation()
                fractionComplete = animator.fractionComplete
            }
        case .changed:
            if animator.isRunning{
                animator.pauseAnimation()
                fractionComplete = animator.fractionComplete
            }else if animator.state == .active{
                if operation == navigationDelegate.operation{
                    animator.fractionComplete = abs(percent) + fractionComplete
                }else{
                    animator.fractionComplete = fractionComplete - abs(percent)
                }
            }
        case .cancelled, .ended:
            if animator.state == .active{
                if animator.fractionComplete < 0.3{
                    animator.isReversed = true
                }
                let velocityX = abs(gesture.velocity(in: view).x) / (view.frame.width * (1 - animator.fractionComplete))
                let initialVelocity = CGVector(dx: velocityX, dy: 0)
                animator.continueAnimation(withTimingParameters: UISpringTimingParameters(dampingRatio: 0.9, initialVelocity: initialVelocity), durationFactor: 0)
            }
        default: break
        }
    }
    
}
