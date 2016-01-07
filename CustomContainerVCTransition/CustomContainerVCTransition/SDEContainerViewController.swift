//
//  SDEUpTabBarViewController.swift
//  CustomContainerVCTransition
//
//  Created by seedante on 15/12/25.
//  Copyright © 2015年 seedante. All rights reserved.
//

import UIKit

class SDEContainerViewController: UIViewController{
    //MARK: Normal Property
    private let kButtonSlotWidth: CGFloat = 64
    private let kButtonSlotHeight: CGFloat = 44
    private let privateContainerView = UIView()
    let buttonTabBar = UIView()
    private var buttonTitles: [String] = []
    
    //MARK: Property for Transition
    var interactive = false
    weak var containerTransitionDelegate: ContainerViewControllerDelegate?
    private var containerTransitionContext: ContainerTransitionContext?
    //MARK: Property like UITabBarController
    //set viewControllers need more code and test, so keep this private in this demo.
    private(set) var viewControllers: [UIViewController]?
    private var shouldReserve = false
    private var priorSelectedIndex: Int = NSNotFound
    var selectedIndex: Int = NSNotFound{
        willSet{
            if shouldReserve{
                shouldReserve = false
            }else{
                transitionViewControllerFromIndex(selectedIndex, toIndex: newValue)
            }
        }
    }
    
    var selectedViewController: UIViewController?{
        get{
            if self.viewControllers == nil || selectedIndex < 0 || selectedIndex >= viewControllers!.count{
                return nil
            }
            return self.viewControllers![selectedIndex]
        }
        set{
            if viewControllers == nil{
                return
            }
            if let index = viewControllers!.indexOf(selectedViewController!){
                selectedIndex = index
            }else{
                print("The view controller is not in the viewControllers")
            }
        }
    }
    
    //MARK: Class Life Method
    init(viewControllers: [UIViewController]){
        assert(viewControllers.count > 0, "can't init with 0 child VC")
        super.init(nibName: nil, bundle: nil)

        self.viewControllers = viewControllers
        for childVC in viewControllers{
            let title = childVC.title != nil ? childVC.title! : "Lazy"
            buttonTitles.append(title)
            //适应屏幕旋转的最简单的办法，在转场开始前设置子 view 的尺寸为容器视图的尺寸。
            childVC.view.translatesAutoresizingMaskIntoConstraints = true
            childVC.view.autoresizingMask = [UIViewAutoresizing.FlexibleWidth, UIViewAutoresizing.FlexibleHeight]
        }
        
        NSNotificationCenter.defaultCenter().addObserverForName(SDEContainerTransitionEndNotification, object: nil, queue: nil, usingBlock: { _ in
            self.containerTransitionContext = nil
            self.buttonTabBar.userInteractionEnabled = true
        })
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("Don't support init from storyboar in this demo")
        //super.init(coder: aDecoder)
    }
    
    override func loadView() {
        let rootView = UIView()
        rootView.backgroundColor = UIColor.blackColor()
        rootView.opaque = true
        
        self.view = rootView
        
        privateContainerView.translatesAutoresizingMaskIntoConstraints = false
        privateContainerView.backgroundColor = UIColor.blackColor()
        privateContainerView.opaque = true
        rootView.addSubview(privateContainerView)
        
        rootView.addConstraint(NSLayoutConstraint(item: privateContainerView, attribute: .Width, relatedBy: .Equal, toItem: rootView, attribute: .Width, multiplier: 1, constant: 0))
        rootView.addConstraint(NSLayoutConstraint(item: privateContainerView, attribute: .Height, relatedBy: .Equal, toItem: rootView, attribute: .Height, multiplier: 1, constant: 0))
        rootView.addConstraint(NSLayoutConstraint(item: privateContainerView, attribute: .Left, relatedBy: .Equal, toItem: rootView, attribute: .Left, multiplier: 1, constant: 0))
        rootView.addConstraint(NSLayoutConstraint(item: privateContainerView, attribute: .Top, relatedBy: .Equal, toItem: rootView, attribute: .Top, multiplier: 1, constant: 0))
        
        buttonTabBar.translatesAutoresizingMaskIntoConstraints = false
        buttonTabBar.backgroundColor = UIColor.clearColor()
        buttonTabBar.tintColor = UIColor(white: 1, alpha: 0.75)
        rootView.addSubview(buttonTabBar)
        
        let count = viewControllers != nil ? viewControllers!.count : 0
        rootView.addConstraint(NSLayoutConstraint(item: buttonTabBar, attribute: .Width, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1, constant: CGFloat(count) * kButtonSlotWidth))
        rootView.addConstraint(NSLayoutConstraint(item: buttonTabBar, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1, constant: kButtonSlotHeight))
        rootView.addConstraint(NSLayoutConstraint(item: buttonTabBar, attribute: .CenterX, relatedBy: .Equal, toItem: privateContainerView, attribute: .CenterX, multiplier: 1, constant: 0))
        rootView.addConstraint(NSLayoutConstraint(item: buttonTabBar, attribute: .CenterY, relatedBy: .Equal, toItem: privateContainerView, attribute: .CenterY, multiplier: 0.2, constant: 0))
        
        addChildViewControllerButtons()
    }
    
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        //Setting this property in other method before this one will make a bug: when you go back to this initial selectedIndex, no transition animation.
        if viewControllers != nil && viewControllers!.count > 0 && selectedIndex == NSNotFound{
            selectedIndex = 0
        }
    }
    
    deinit{
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }

    //MARK: Restore data and change button appear
    func restoreSelectedIndex(){
        shouldReserve = true
        selectedIndex = priorSelectedIndex
    }
    
    
    //Only work in interactive transition
    func graduallyChangeTabButtonAppearWith(fromIndex: Int, toIndex: Int, percent: CGFloat){
        let fromButton = buttonTabBar.subviews[fromIndex] as! UIButton
        let toButton = buttonTabBar.subviews[toIndex] as! UIButton
        
        fromButton.setTitleColor(UIColor(red: 1, green: percent, blue: percent, alpha: 1), forState: .Normal)
        toButton.setTitleColor(UIColor(red: 1, green: 1 - percent, blue: 1 - percent, alpha: 1), forState: .Normal)
    }
    
    //MARK: Private Helper Method
    private func addChildViewControllerButtons(){
        for (index, vcTitle) in buttonTitles.enumerate(){
            let button = UIButton(frame: CGRect(x: 0, y: 0, width: kButtonSlotWidth, height: kButtonSlotHeight))
            button.backgroundColor = UIColor.clearColor()
            button.setTitle(vcTitle, forState: .Normal)
            button.translatesAutoresizingMaskIntoConstraints = false
            button.addTarget(self, action: "TabButtonTapped:", forControlEvents: .TouchUpInside)
            
            buttonTabBar.addSubview(button)
            buttonTabBar.addConstraint(NSLayoutConstraint(item: button, attribute: .CenterX, relatedBy: .Equal, toItem: buttonTabBar, attribute: .Leading, multiplier: 1, constant: (CGFloat(index) + 0.5) * kButtonSlotWidth))
            buttonTabBar.addConstraint(NSLayoutConstraint(item: button, attribute: .CenterY, relatedBy: .Equal, toItem: buttonTabBar, attribute: .CenterY, multiplier: 1, constant: 0))
        }
    }
    
    @objc
    private func TabButtonTapped(button: UIButton){
        if let tappedIndex = buttonTabBar.subviews.indexOf(button) where tappedIndex != selectedIndex{
            selectedIndex = tappedIndex
        }
    }
    
    private func changeTabButtonAppearAtIndex(selectedIndex: Int){
        for (index, subView) in buttonTabBar.subviews.enumerate(){
            let button = subView as! UIButton
            if index != selectedIndex{
                button.setTitleColor(UIColor.whiteColor(), forState: .Normal)
            }else{
                button.setTitleColor(UIColor.redColor(), forState: .Normal)
            }
        }
    }
    
    private func transitionViewControllerFromIndex(fromIndex: Int, toIndex: Int){
        if viewControllers == nil || fromIndex == toIndex || fromIndex < 0 || toIndex < 0 || toIndex >= viewControllers!.count || (fromIndex >= viewControllers!.count && fromIndex != NSNotFound){
            return
        }
        //called when init
        if fromIndex == NSNotFound{
            let selectedVC = viewControllers![toIndex]
            addChildViewController(selectedVC)
            privateContainerView.addSubview(selectedVC.view)
            selectedVC.didMoveToParentViewController(self)
            changeTabButtonAppearAtIndex(toIndex)
            return
        }
        
        if containerTransitionDelegate != nil{
            buttonTabBar.userInteractionEnabled = false
            
            let fromVC = viewControllers![fromIndex]
            let toVC = viewControllers![toIndex]
            containerTransitionContext = ContainerTransitionContext(containerViewController: self, containerView: privateContainerView, fromViewController: fromVC, toViewController: toVC)
            
            if interactive{
                priorSelectedIndex = fromIndex
                containerTransitionContext?.startInteractiveTranstionWith(containerTransitionDelegate!)
            }else{
                containerTransitionContext?.startNonInteractiveTransitionWith(containerTransitionDelegate!)
                changeTabButtonAppearAtIndex(toIndex)
            }
        }else{
            //Transition Without Animation
            let priorSelectedVC = viewControllers![fromIndex]
            priorSelectedVC.willMoveToParentViewController(nil)
            priorSelectedVC.view.removeFromSuperview()
            priorSelectedVC.removeFromParentViewController()
            
            let newSelectedVC = viewControllers![toIndex]
            addChildViewController(newSelectedVC)
            privateContainerView.addSubview(newSelectedVC.view)
            newSelectedVC.didMoveToParentViewController(self)
            
            changeTabButtonAppearAtIndex(toIndex)
        }
    }
    
    
}
