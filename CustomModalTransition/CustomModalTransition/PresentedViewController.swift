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
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        let widthContraint = inputTextField.constraints.filter({constraint in
            constraint.identifier == "Width"
            }).first
        widthContraint?.constant = view.frame.width * 2 / 3
        
        UIView.animate(withDuration: 0.3, animations: {
            self.dismissButton.alpha = 1
            self.view.layoutIfNeeded()
        })
    }
    
    @IBAction func dismiss(_ sender: AnyObject) {
        var applyTransform = CGAffineTransform( rotationAngle: 3 * CGFloat(M_PI))
        applyTransform = applyTransform.scaledBy(x: 0.1, y: 0.1)

        let widthContraint = inputTextField.constraints.filter({constraint in
            constraint.identifier == "Width"
        }).first
        widthContraint?.constant = 0
        
        UIView.animate(withDuration: 0.4, animations: {
            self.dismissButton.transform = applyTransform
            self.view.layoutIfNeeded()
            }, completion: { _ in
                self.dismiss(animated: true, completion: nil)
        })
        
    }

}

