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
    fileprivate let kButtonSlotWidth: CGFloat = 64
    fileprivate let kButtonSlotHeight: CGFloat = 44
    fileprivate let privateContainerView = UIView()
    let buttonTabBar = UIView()
    fileprivate var buttonTitles: [String] = []
    
    //MARK: Property for Transition
    var interactive = false
    weak var containerTransitionDelegate: ContainerViewControllerDelegate?
    fileprivate var containerTransitionContext: ContainerTransitionContext?
    //MARK: Property like UITabBarController
    //set viewControllers need more code and test, so keep this private in this demo.
    fileprivate(set) var viewControllers: [UIViewController]?
    fileprivate var shouldReserve = false
    fileprivate var priorSelectedIndex: Int = NSNotFound
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
            if let index = viewControllers!.index(of: selectedViewController!){
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
            childVC.view.autoresizingMask = [UIViewAutoresizing.flexibleWidth, UIViewAutoresizing.flexibleHeight]
        }
        
        NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: SDEContainerTransitionEndNotification), object: nil, queue: nil, using: { _ in
            self.containerTransitionContext = nil
            self.buttonTabBar.isUserInteractionEnabled = true
        })
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("Don't support init from storyboar in this demo")
        //super.init(coder: aDecoder)
    }
    
    override func loadView() {
        let rootView = UIView()
        rootView.backgroundColor = UIColor.black
        rootView.isOpaque = true
        
        self.view = rootView
        
        privateContainerView.translatesAutoresizingMaskIntoConstraints = false
        privateContainerView.backgroundColor = UIColor.black
        privateContainerView.isOpaque = true
        rootView.addSubview(privateContainerView)
        
        rootView.addConstraint(NSLayoutConstraint(item: privateContainerView, attribute: .width, relatedBy: .equal, toItem: rootView, attribute: .width, multiplier: 1, constant: 0))
        rootView.addConstraint(NSLayoutConstraint(item: privateContainerView, attribute: .height, relatedBy: .equal, toItem: rootView, attribute: .height, multiplier: 1, constant: 0))
        rootView.addConstraint(NSLayoutConstraint(item: privateContainerView, attribute: .left, relatedBy: .equal, toItem: rootView, attribute: .left, multiplier: 1, constant: 0))
        rootView.addConstraint(NSLayoutConstraint(item: privateContainerView, attribute: .top, relatedBy: .equal, toItem: rootView, attribute: .top, multiplier: 1, constant: 0))
        
        buttonTabBar.translatesAutoresizingMaskIntoConstraints = false
        buttonTabBar.backgroundColor = UIColor.clear
        buttonTabBar.tintColor = UIColor(white: 1, alpha: 0.75)
        rootView.addSubview(buttonTabBar)
        
        let count = viewControllers != nil ? viewControllers!.count : 0
        rootView.addConstraint(NSLayoutConstraint(item: buttonTabBar, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: CGFloat(count) * kButtonSlotWidth))
        rootView.addConstraint(NSLayoutConstraint(item: buttonTabBar, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: kButtonSlotHeight))
        rootView.addConstraint(NSLayoutConstraint(item: buttonTabBar, attribute: .centerX, relatedBy: .equal, toItem: privateContainerView, attribute: .centerX, multiplier: 1, constant: 0))
        rootView.addConstraint(NSLayoutConstraint(item: buttonTabBar, attribute: .centerY, relatedBy: .equal, toItem: privateContainerView, attribute: .centerY, multiplier: 0.2, constant: 0))
        
        addChildViewControllerButtons()
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        //Setting this property in other method before this one will make a bug: when you go back to this initial selectedIndex, no transition animation.
        if viewControllers != nil && viewControllers!.count > 0 && selectedIndex == NSNotFound{
            selectedIndex = 0
        }
    }
    
    deinit{
        NotificationCenter.default.removeObserver(self)
    }

    //MARK: Restore data and change button appear
    func restoreSelectedIndex(){
        shouldReserve = true
        selectedIndex = priorSelectedIndex
    }
    
    
    //Only work in interactive transition
    func graduallyChangeTabButtonAppearWith(_ fromIndex: Int, toIndex: Int, percent: CGFloat){
        let fromButton = buttonTabBar.subviews[fromIndex] as! UIButton
        let toButton = buttonTabBar.subviews[toIndex] as! UIButton
        
        fromButton.setTitleColor(UIColor(red: 1, green: percent, blue: percent, alpha: 1), for: UIControlState())
        toButton.setTitleColor(UIColor(red: 1, green: 1 - percent, blue: 1 - percent, alpha: 1), for: UIControlState())
    }
    
    //MARK: Private Helper Method
    fileprivate func addChildViewControllerButtons(){
        for (index, vcTitle) in buttonTitles.enumerated(){
            let button = UIButton(frame: CGRect(x: 0, y: 0, width: kButtonSlotWidth, height: kButtonSlotHeight))
            button.backgroundColor = UIColor.clear
            button.setTitle(vcTitle, for: UIControlState())
            button.translatesAutoresizingMaskIntoConstraints = false
            button.addTarget(self, action: #selector(SDEContainerViewController.TabButtonTapped(_:)), for: .touchUpInside)
            
            buttonTabBar.addSubview(button)
            buttonTabBar.addConstraint(NSLayoutConstraint(item: button, attribute: .centerX, relatedBy: .equal, toItem: buttonTabBar, attribute: .leading, multiplier: 1, constant: (CGFloat(index) + 0.5) * kButtonSlotWidth))
            buttonTabBar.addConstraint(NSLayoutConstraint(item: button, attribute: .centerY, relatedBy: .equal, toItem: buttonTabBar, attribute: .centerY, multiplier: 1, constant: 0))
        }
    }
    
    @objc
    fileprivate func TabButtonTapped(_ button: UIButton){
        if let tappedIndex = buttonTabBar.subviews.index(of: button), tappedIndex != selectedIndex{
            selectedIndex = tappedIndex
        }
    }
    
    fileprivate func changeTabButtonAppearAtIndex(_ selectedIndex: Int){
        for (index, subView) in buttonTabBar.subviews.enumerated(){
            let button = subView as! UIButton
            if index != selectedIndex{
                button.setTitleColor(UIColor.white, for: UIControlState())
            }else{
                button.setTitleColor(UIColor.red, for: UIControlState())
            }
        }
    }
    
    fileprivate func transitionViewControllerFromIndex(_ fromIndex: Int, toIndex: Int){
        if viewControllers == nil || fromIndex == toIndex || fromIndex < 0 || toIndex < 0 || toIndex >= viewControllers!.count || (fromIndex >= viewControllers!.count && fromIndex != NSNotFound){
            return
        }
        //called when init
        if fromIndex == NSNotFound{
            let selectedVC = viewControllers![toIndex]
            addChildViewController(selectedVC)
            privateContainerView.addSubview(selectedVC.view)
            selectedVC.didMove(toParentViewController: self)
            changeTabButtonAppearAtIndex(toIndex)
            return
        }
        
        if containerTransitionDelegate != nil{
            buttonTabBar.isUserInteractionEnabled = false
            
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
            priorSelectedVC.willMove(toParentViewController: nil)
            priorSelectedVC.view.removeFromSuperview()
            priorSelectedVC.removeFromParentViewController()
            
            let newSelectedVC = viewControllers![toIndex]
            addChildViewController(newSelectedVC)
            privateContainerView.addSubview(newSelectedVC.view)
            newSelectedVC.didMove(toParentViewController: self)
            
            changeTabButtonAppearAtIndex(toIndex)
        }
    }
    
    
}
