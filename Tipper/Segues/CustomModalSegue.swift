//
//  CustomModalSegue.swift
//  Tipper
//
//  Created by Ryan Romanchuk on 9/2/15.
//  Copyright (c) 2015 Ryan Romanchuk. All rights reserved.
//

import Foundation

class CustomModalSegue: UIStoryboardSegue {
    let className = "CustomModalSegue"

    override func perform() {
        println("\(className)::\(__FUNCTION__)")
        // Assign the source and destination views to local variables.
        var firstVCView = self.sourceViewController.view as UIView!
        var secondVCView = self.destinationViewController.view as UIView!
        
        let sourceVc = self.sourceViewController as? HomeController
        let destinationVc =  self.destinationViewController as? CustomModable
        
        
        
        destinationVc?.prepareForSegueAnimation()
        
        // Get the screen width and height.
        let screenWidth = UIScreen.mainScreen().bounds.size.width
        let screenHeight = UIScreen.mainScreen().bounds.size.height
        
        // Specify the initial position of the destination view.
        secondVCView.frame = CGRectMake(0.0, screenHeight, screenWidth, screenHeight)
        
        
        // Access the app's key window and insert the destination view above the current (source) one.
        let window = UIApplication.sharedApplication().keyWindow
        window?.insertSubview(secondVCView, aboveSubview: firstVCView)
        
        if identifier == "DidTapNotifications" {
            sourceVc?.headerContainerController.setHeaderTitle("Notifications")
        } else if identifier == "DidTapAccountSegue" {
            sourceVc?.headerContainerController.setHeaderTitle("Account")
        }
        
        
        // Animate the transition.
        UIView.animateWithDuration(0.4, animations: { () -> Void in
            //firstVCView.frame = CGRectOffset(firstVCView.frame, 0.0, -screenHeight)
            secondVCView.frame = CGRectOffset(secondVCView.frame, 0.0, -screenHeight)
            

            }) { (Finished) -> Void in
                destinationVc?.segueAnimationComplete()
                self.sourceViewController.presentViewController(self.destinationViewController as! UIViewController,
                    animated: false,
                    completion: nil)
        }
    }
}

protocol CustomModable:class {
    func prepareForSegueAnimation()
    func segueAnimationComplete()
    
//    func prepareForUnwindSegue()
//    func segueUnwindComplete()
}