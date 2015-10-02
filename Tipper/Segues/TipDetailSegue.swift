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
        print("\(className)::\(__FUNCTION__)")
        // Assign the source and destination views to local variables.
        let firstVCView = self.sourceViewController.view as UIView!
        let secondVCView = self.destinationViewController.view as UIView!

        let sourceVc = self.sourceViewController as? HomeController
        let destinationVc =  self.destinationViewController as? CustomModable



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
