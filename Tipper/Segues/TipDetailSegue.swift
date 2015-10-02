//
//  TipDetailSegue.swift
//  Tipper
//
//  Created by Ryan Romanchuk on 10/2/15.
//  Copyright © 2015 Ryan Romanchuk. All rights reserved.
//

import UIKit

class TipDetailSegue: UIStoryboardSegue {
    let className = "TipDetailSegue"

    override func perform() {
        log.verbose("")
        // Assign the source and destination views to local variables.
        let firstVCView = self.sourceViewController.view as UIView!
        let secondVCView = self.destinationViewController.view as UIView!

        let sourceVc = self.sourceViewController as? HomeController
        let destinationVc =  self.destinationViewController as? CustomSegueable



        destinationVc?.prepareForSegueAnimation()

        // Get the screen width and height.
        let screenWidth = UIScreen.mainScreen().bounds.size.width
        let screenHeight = UIScreen.mainScreen().bounds.size.height

        // Specify the initial position of the destination view.
        secondVCView.frame = CGRectMake(screenWidth, 0.0, screenWidth, screenHeight)


        // Access the app's key window and insert the destination view above the current (source) one.
        let window = UIApplication.sharedApplication().keyWindow
        window?.insertSubview(secondVCView, aboveSubview: firstVCView)


        // Animate the transition.
        UIView.animateWithDuration(0.3, animations: { () -> Void in
            //firstVCView.frame = CGRectOffset(firstVCView.frame, 0.0, -screenHeight)
            secondVCView.frame = CGRectOffset(secondVCView.frame, -screenWidth, 0.0)


            }) { (Finished) -> Void in
                destinationVc?.segueAnimationComplete()
                self.sourceViewController.presentViewController(self.destinationViewController ,
                    animated: false,
                    completion: nil)
        }
    }

}

class TipDetailUnwindSegue: UIStoryboardSegue {
    let className = "TipDetailUnwindSegue"

    override func perform() {
        log.verbose("source: \(self.sourceViewController) destination: \(self.destinationViewController) ")
        // Assign the source and destination views to local variables.
        let viewOnScreen = self.sourceViewController.view as UIView!
        let viewAfterUnwind = self.destinationViewController.view as UIView!

        let controllerOnScreen = self.sourceViewController as? CustomSegueable

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

        log.verbose("viewOnScreen: \(NSStringFromCGRect(viewOnScreen.frame))")
        log.verbose("viewAfterUnwind: \(NSStringFromCGRect(viewAfterUnwind.frame))")
        controllerOnScreen?.prepareForSegueAnimation()


        // Animate the transition.
        UIView.animateWithDuration(0.4, animations: { () -> Void in
            viewOnScreen.frame = CGRectOffset(viewOnScreen.frame, screenWidth, 0.0)
            //secondVCView.frame = CGRectOffset(secondVCView.frame, 0.0, screenHeight)

            }) { (Finished) -> Void in

                self.sourceViewController.dismissViewControllerAnimated(false, completion: nil)
        }
    }
}

