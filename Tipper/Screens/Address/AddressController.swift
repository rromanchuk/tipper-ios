//
//  AddressController.swift
//  Tipper
//
//  Created by Ryan Romanchuk on 3/25/15.
//  Copyright (c) 2015 Ryan Romanchuk. All rights reserved.
//

import UIKit
import QRCode


class AddressController: GAITrackedViewController {

    var managedObjectContext: NSManagedObjectContext?
    var currentUser: CurrentUser!
    var market: Market!

    @IBOutlet weak var copyToCliboardButton: UIButton!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var qrImageView: UIImageView!


    override func viewDidLoad() {
        super.viewDidLoad()
        self.addressLabel.text = currentUser.bitcoinAddress
        let qrCode = QRCode(currentUser.bitcoinAddress!)
        qrImageView.image = qrCode?.image
        addressLabel.text = currentUser.bitcoinAddress
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

    @IBAction func didCopy(sender: UIButton) {
        let pb = UIPasteboard.generalPasteboard()
        pb.string = currentUser.bitcoinAddress!
    }
    @IBAction func didClose(sender: UIButton) {
        performSegueWithIdentifier("AddressDone", sender: self)
    }
}
