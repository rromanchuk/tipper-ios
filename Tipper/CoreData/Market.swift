
import Foundation
import CoreData


class Market: NSManagedObject {

    @NSManaged var amount: String?
    @NSManaged var updatedAt: NSDate

    class func market() -> Market {
        return (UIApplication.sharedApplication().delegate as! AppDelegate).market
    }

    func update(completion: (() ->Void)) {
        API.sharedInstance.market { (json, error) -> Void in
            self.amount = json["amount"].stringValue
            self.updatedAt = NSDate()
        }
    }
}