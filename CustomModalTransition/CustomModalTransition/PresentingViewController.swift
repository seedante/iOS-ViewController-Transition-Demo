//
//  PresentingViewController.swift
//  CustomPresentationTransition
//
//  Created by seedante on 15/12/15.
//  Copyright © 2015年 seedante. All rights reserved.
//

import UIKit

class PresentingViewController: UIViewController{

    let presentTransitionDelegate = SDEModalTransitionDelegate()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    /*
    .FullScreen 的时候，presentingView 的移除和添加由 UIKit 负责，在 presentation 转场结束后被移除，dismissal 转场结束时重新回到原来的位置；
    .Custom 的时候，presentingView 依然由 UIKit 负责，但 presentation 转场结束后不会被移除。
    */

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        let toVC = segue.destination as! PresentedViewController
        toVC.transitioningDelegate = presentTransitionDelegate
        toVC.modalPresentationStyle = .custom
    }
}
