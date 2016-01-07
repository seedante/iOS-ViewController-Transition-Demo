//
//  PopViewController.swift
//  NavigationControllerTransitionDemo
//
//  Created by seedante on 15/12/9.
//  Copyright © 2015年 seedante. All rights reserved.
//

import UIKit

class PopViewController: UIViewController {
    
    let edgePanGesture = UIScreenEdgePanGestureRecognizer()
    var navigationDelegate: SDENavigationDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "StackTop"
        // Do any additional setup after loading the view.
        edgePanGesture.edges = .Left
        edgePanGesture.addTarget(self, action: "handleEdgePanGesture:")
        view.addGestureRecognizer(edgePanGesture)
    }
        
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
        
    func handleEdgePanGesture(gesture: UIScreenEdgePanGestureRecognizer){
        let translationX =  gesture.translationInView(view).x
        let translationBase: CGFloat = view.frame.width / 3
        let translationAbs = translationX > 0 ? translationX : -translationX
        let percent = translationAbs > translationBase ? 1.0 : translationAbs / translationBase
        switch gesture.state{
        case .Began:
            navigationDelegate = self.navigationController?.delegate as? SDENavigationDelegate
            navigationDelegate?.interactive = true
            self.navigationController?.popViewControllerAnimated(true)
        case .Changed:
            navigationDelegate?.interactionController.updateInteractiveTransition(percent)
        case .Cancelled, .Ended:
            if percent > 0.5{
                navigationDelegate?.interactionController.finishInteractiveTransition()
            }else{
                navigationDelegate?.interactionController.cancelInteractiveTransition()
            }
            navigationDelegate?.interactive = false
        default: break
        }
    }
    
    @IBAction func popMe(sender: AnyObject) {
        print(self.navigationController!.view)
        self.navigationController?.popViewControllerAnimated(true)
    }

    deinit{
        edgePanGesture.removeTarget(self, action: "handleEdgePanGesture:")
    }

}
