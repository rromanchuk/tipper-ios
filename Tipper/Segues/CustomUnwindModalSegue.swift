//
//  CustomUnwindModalSegue.swift
//  Tipper
//
//  Created by Ryan Romanchuk on 9/2/15.
//  Copyright (c) 2015 Ryan Romanchuk. All rights reserved.
//

import UIKit

class CustomUnwindModalSegue: UIStoryboardSegue {
    let className = "CustomUnwindModalSegue"

    override func perform() {
        print("\(className)::\(__FUNCTION__) source: \(self.sourceViewController) destination: \(self.destinationViewController) ")
        // Assign the source and destination views to local variables.
        let viewOnScreen = self.sourceViewController.view as UIView!
        let viewAfterUnwind = self.destinationViewController.view as UIView!
        
        let controllerOnScreen = self.sourceViewController as? CustomSegueable
        //let controllerAfterUnwind =
        
        let screenHeight = UIScreen.mainScreen().bounds.size.height
        let screenWidth = UIScreen.mainScreen().bounds.size.width
        let window = UIApplication.sharedApplication().keyWindow
        
        //sourceViewController.view?.superview?.insertSubview(destinationViewController.view!, atIndex: 0)
        
        //sourceViewController.view!!.insertSubview(destinationViewController.view, atIndex: 0)
        if let source = sourceViewController as? UIViewController, destination = destinationViewController as? UIViewController {
            source.view.superview?.insertSubview(destination.view, atIndex: 0)
        }
        //(self.sourceViewController as! UIViewController).view.superview?.insertSubview(self.destinationViewController, atIndex: <#Int#>)
        
        //viewAfterUnwind.frame = CGRectMake(0.0, 0.0, screenWidth, screenHeight)
        //window?.insertSubview(viewAfterUnwind, be: viewOnScreen)
        //window?.insertSubview(viewAfterUnwind, belowSubview: viewOnScreen)
        
        print("viewOnScreen: \(NSStringFromCGRect(viewOnScreen.frame))")
        print("viewAfterUnwind: \(NSStringFromCGRect(viewAfterUnwind.frame))")
        controllerOnScreen?.prepareForSegueAnimation()
        
        
        // Animate the transition.
        UIView.animateWithDuration(0.4, animations: { () -> Void in
            viewOnScreen.frame = CGRectOffset(viewOnScreen.frame, 0.0, screenHeight)
            //secondVCView.frame = CGRectOffset(secondVCView.frame, 0.0, screenHeight)
            
            }) { (Finished) -> Void in
                
                self.sourceViewController.dismissViewControllerAnimated(false, completion: nil)
        }
    }
}
