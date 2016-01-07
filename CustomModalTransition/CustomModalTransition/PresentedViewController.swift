//
//  ViewController.swift
//  CustomPresentationTransition
//
//  Created by seedante on 15/12/15.
//  Copyright © 2015年 seedante. All rights reserved.
//

import UIKit

class PresentedViewController: UIViewController{

    let presentTransitionDelegate = SDEModalTransitionDelegate()
    @IBOutlet weak var dismissButton: UIButton!
    @IBOutlet weak var inputTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        dismissButton.alpha = 0
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        let widthContraint = inputTextField.constraints.filter({constraint in
            constraint.identifier == "Width"
            }).first
        widthContraint?.constant = view.frame.width * 2 / 3
        
        UIView.animateWithDuration(0.3, animations: {
            self.dismissButton.alpha = 1
            self.inputTextField.layoutIfNeeded()
        })
    }
    
    @IBAction func dismiss(sender: AnyObject) {
        var applyTransform = CGAffineTransformMakeRotation( 3 * CGFloat(M_PI))
        applyTransform = CGAffineTransformScale(applyTransform, 0.1, 0.1)

        let widthContraint = inputTextField.constraints.filter({constraint in
            constraint.identifier == "Width"
        }).first
        widthContraint?.constant = 0
        
        UIView.animateWithDuration(0.4, animations: {
            self.dismissButton.transform = applyTransform
            self.inputTextField.layoutIfNeeded()
            }, completion: { _ in
                self.dismissViewControllerAnimated(true, completion: nil)
        })
        
    }

}

