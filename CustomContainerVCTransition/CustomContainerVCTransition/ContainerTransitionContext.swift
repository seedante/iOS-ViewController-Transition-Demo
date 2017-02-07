//
//  PrivateTransitionContext.swift
//  CustomContainerVCTransition
//
//  Created by seedante on 15/12/26.
//  Copyright © 2015年 seedante. All rights reserved.
//

import UIKit

let SDEContainerTransitionEndNotification = "Notification.ContainerTransitionEnd.seedante"
let SDEInteractionEndNotification = "Notification.InteractionEnd.seedante"

class ContainerTransitionContext: NSObject, UIViewControllerContextTransitioning {
    //MARK: Protocol Method - Accessing the Transition Objects
    public var containerView: UIView {
        return privateContainerView
    }
    
    public func viewController(forKey key: UITransitionContextViewControllerKey) -> UIViewController?{
        switch key{
        case UITransitionContextViewControllerKey.from:
            return privateFromViewController
        case UITransitionContextViewControllerKey.to:
            return privateToViewController
        default: return nil
        }
    }
    
    @objc @available(iOS 8.0, *)
    public func view(forKey key: UITransitionContextViewKey) -> UIView?{
        switch key{
        case UITransitionContextViewKey.from:
            return privateFromViewController.view
        case UITransitionContextViewKey.to:
            return privateToViewController.view
        default: return nil
        }
    }
    
    //MARK: Protocol Method - Getting the Transition Frame Rectangles
    public func initialFrame(for vc: UIViewController) -> CGRect {
        return CGRect.zero
    }
    
    public func finalFrame(for vc: UIViewController) -> CGRect {
        return vc.view.frame
    }

    //MARK: Protocol Method - Getting the Transition Behaviors
    public var presentationStyle: UIModalPresentationStyle{
        return .custom
    }
    
    //MARK: Protocol Method - Reporting the Transition Progress
    func completeTransition(_ didComplete: Bool) {
        if didComplete{
            privateToViewController.didMove(toParentViewController: privateContainerViewController)
            
            privateFromViewController.willMove(toParentViewController: nil)
            privateFromViewController.view.removeFromSuperview()
            privateFromViewController.removeFromParentViewController()
        }else{
            privateToViewController.didMove(toParentViewController: privateContainerViewController)
            
            privateToViewController.willMove(toParentViewController: nil)
            privateToViewController.view.removeFromSuperview()
            privateToViewController.removeFromParentViewController()
        }
        
        transitionEnd()
    }
    
    func updateInteractiveTransition(_ percentComplete: CGFloat) {
        if animationController != nil && isInteractive == true{
            transitionPercent = percentComplete
            privateContainerView.layer.timeOffset = CFTimeInterval(percentComplete) * transitionDuration
            privateContainerViewController.graduallyChangeTabButtonAppearWith(fromIndex, toIndex: toIndex, percent: percentComplete)
        }
    }
    
    func finishInteractiveTransition() {
        isInteractive = false
        let pausedTime = privateContainerView.layer.timeOffset
        privateContainerView.layer.speed = 1.0
        privateContainerView.layer.timeOffset = 0.0
        privateContainerView.layer.beginTime = 0.0
        let timeSincePause = privateContainerView.layer.convertTime(CACurrentMediaTime(), from: nil) - pausedTime
        privateContainerView.layer.beginTime = timeSincePause
        
        let displayLink = CADisplayLink(target: self, selector: #selector(ContainerTransitionContext.finishChangeButtonAppear(_:)))
        displayLink.add(to: RunLoop.main, forMode: RunLoopMode.defaultRunLoopMode)
        
        //当 SDETabBarViewController 作为一个子 VC 内嵌在其他容器 VC 内，比如 NavigationController 里时，在 SDETabBarViewController 内完成一次交互转场后
        //在外层的 NavigationController push 其他 VC 然后 pop 返回时，且仅限于交互控制，会出现 containerView 不见的情况，pop 完成后就恢复了。
        //根源在于此时 beginTime 被修改了，在转场结束后恢复为 0 就可以了。解决灵感来自于如果没有一次完成了交互转场而全部是中途取消的话就不会出现这个 Bug。
        //感谢简书用户@dasehng__ 反馈这个 Bug。
        let remainingTime = CFTimeInterval(1 - transitionPercent) * transitionDuration
        perform(#selector(ContainerTransitionContext.fixBeginTimeBug), with: nil, afterDelay: remainingTime)
        
    }
    
    func cancelInteractiveTransition() {
        isInteractive = false
        isCancelled = true
        let displayLink = CADisplayLink(target: self, selector: #selector(ContainerTransitionContext.reverseCurrentAnimation(_:)))
        displayLink.add(to: RunLoop.main, forMode: RunLoopMode.defaultRunLoopMode)
        NotificationCenter.default.post(name: Notification.Name(rawValue: SDEInteractionEndNotification), object: self)
    }

    public var transitionWasCancelled: Bool{
        return isCancelled
    }

    //MARK: Protocol Method - Getting the Rotation Factor
    @available(iOS 8.0, *)
    public var targetTransform: CGAffineTransform{
        return CGAffineTransform.identity
    }

    //MARK: Protocol Method - Pause Transition
    @available(iOS 10.0, *)
    public func pauseInteractiveTransition() {
        
    }
    
    //MARK: Addtive Property
    fileprivate var animationController: UIViewControllerAnimatedTransitioning?
    //MARK: Private Property for Protocol Need
    unowned fileprivate var privateFromViewController: UIViewController
    unowned fileprivate var privateToViewController: UIViewController
    unowned fileprivate var privateContainerViewController: SDEContainerViewController
    unowned fileprivate var privateContainerView: UIView
    //MARK: Property for Transition State
    public var isAnimated: Bool{
        if animationController != nil{
            return true
        }
        return false
    }
    public var isInteractive = false
    fileprivate var isCancelled = false
    fileprivate var fromIndex: Int = 0
    fileprivate var toIndex: Int = 0
    fileprivate var transitionDuration: CFTimeInterval = 0
    fileprivate var transitionPercent: CGFloat = 0
    
    //MARK: Public Custom Method
    init(containerViewController: SDEContainerViewController, containerView: UIView, fromViewController fromVC: UIViewController, toViewController toVC: UIViewController){
        privateContainerViewController = containerViewController
        privateContainerView = containerView
        privateFromViewController = fromVC
        privateToViewController = toVC
        fromIndex = containerViewController.viewControllers!.index(of: fromVC)!
        toIndex = containerViewController.viewControllers!.index(of: toVC)!
        super.init()
        //每次转场开始前都会生成这个对象，调整 toView 的尺寸适用屏幕
        privateToViewController.view.frame = privateContainerView.bounds
    }
    
    func startInteractiveTranstionWith(_ delegate: ContainerViewControllerDelegate){
        animationController = delegate.containerController(privateContainerViewController, animationControllerForTransitionFromViewController: privateFromViewController, toViewController: privateToViewController)
        transitionDuration = animationController!.transitionDuration(using: self)
        if privateContainerViewController.interactive == true{
            if let interactionController = delegate.containerController?(privateContainerViewController, interactionControllerForAnimation: animationController!){
                interactionController.startInteractiveTransition(self)
            }else{
                fatalError("Need for interaction controller for interactive transition.")
            }
        }else{
            fatalError("ContainerTransitionContext's Property 'interactive' must be true before starting interactive transiton")
        }
    }
    
    func startNonInteractiveTransitionWith(_ delegate: ContainerViewControllerDelegate){
        animationController = delegate.containerController(privateContainerViewController, animationControllerForTransitionFromViewController: privateFromViewController, toViewController: privateToViewController)
        transitionDuration = animationController!.transitionDuration(using: self)
        activateNonInteractiveTransition()
    }
    
    //InteractionController's startInteractiveTransition: will call this method
    func activateInteractiveTransition(){
        isInteractive = true
        isCancelled = false
        privateContainerViewController.addChildViewController(privateToViewController)
        privateContainerView.layer.speed = 0
        animationController?.animateTransition(using: self)
    }
    
    //MARK: Private Helper Method
    fileprivate func activateNonInteractiveTransition(){
        isInteractive = false
        isCancelled = false
        privateContainerViewController.addChildViewController(privateToViewController)
        animationController?.animateTransition(using: self)
    }
    
    fileprivate func transitionEnd(){
        if animationController != nil && animationController!.responds(to: #selector(UIViewControllerAnimatedTransitioning.animationEnded(_:))) == true{
            animationController!.animationEnded!(!isCancelled)
        }
        //If transition is cancelled, recovery data.
        if isCancelled{
            privateContainerViewController.restoreSelectedIndex()
            isCancelled = false
        }
        
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: SDEContainerTransitionEndNotification), object: self)
    }
    
    //修复内嵌在其他容器 VC 交互返回的转场中 containerView 消失并且的转场结束后自动恢复的 Bug。
    @objc fileprivate func fixBeginTimeBug(){
        privateContainerView.layer.beginTime = 0.0
    }

    
    @objc fileprivate func reverseCurrentAnimation(_ displayLink: CADisplayLink){
        let timeOffset = privateContainerView.layer.timeOffset - displayLink.duration
        if timeOffset > 0{
            privateContainerView.layer.timeOffset = timeOffset
            transitionPercent = CGFloat(timeOffset / transitionDuration)
            privateContainerViewController.graduallyChangeTabButtonAppearWith(fromIndex, toIndex: toIndex, percent: transitionPercent)
        }else{
            displayLink.invalidate()
            privateContainerView.layer.timeOffset = 0
            privateContainerView.layer.speed = 1
            privateContainerViewController.graduallyChangeTabButtonAppearWith(fromIndex, toIndex: toIndex, percent: 0)
            
            //修复闪屏Bug: speed 恢复为1后，动画会立即跳转到它的最终状态，而 fromView 的最终状态是移动到了屏幕之外，因此在这里添加一个假的掩人耳目。
            //为何不等 completion block 中恢复 fromView 的状态后再恢复 containerView.layer.speed，事实上那样做无效，原因未知。
            let fakeFromView = privateFromViewController.view.snapshotView(afterScreenUpdates: false)
            privateContainerView.addSubview(fakeFromView!)
            perform(#selector(ContainerTransitionContext.removeFakeFromView(_:)), with: fakeFromView, afterDelay: 1/60)
        }
    }
    
    @objc fileprivate func removeFakeFromView(_ fakeView: UIView){
        fakeView.removeFromSuperview()
    }
    
    @objc fileprivate func finishChangeButtonAppear(_ displayLink: CADisplayLink){
        let percentFrame = 1 / (transitionDuration * 60)
        transitionPercent += CGFloat(percentFrame)
        if transitionPercent < 1.0{
            privateContainerViewController.graduallyChangeTabButtonAppearWith(fromIndex, toIndex: toIndex, percent: transitionPercent)
        }else{
            privateContainerViewController.graduallyChangeTabButtonAppearWith(fromIndex, toIndex: toIndex, percent: 1)
            displayLink.invalidate()
        }
    }
    
    
    
    
}
