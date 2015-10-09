
import Foundation
import CoreData
import SwiftyJSON

class Market: NSManagedObject, CoreDataUpdatable, ModelCoredataMapable {

    @NSManaged var amount: String?
    @NSManaged var subtotalAmount: String?
    @NSManaged var btc: String?
    @NSManaged var updatedAt: NSDate

    class var className: String {
        get {
            return "Market"
        }
    }

    var className: String {
        return Favorite.className
    }

    static func lookupProperty() -> String {
        return Market.lookupProperty()
    }

    func lookupProperty() -> String {
        return "btc"
    }

    func lookupValue() -> String {
        return self.btc!
    }

    func updateEntityWithModel(model: Any) {
        if let market = model as? TIPPERMarket {
            self.subtotalAmount = market.subtotalAmount
            self.amount = market.amount
            self.btc = market.btc
            self.updatedAt = NSDate()
        }
    }

    class func market() -> Market {
        return (UIApplication.sharedApplication().delegate as! AppDelegate).market
    }

    func update(completion: () ->Void) {
        log.verbose("")
        TIPPERTipperClient.defaultClient().marketGet("0.02").continueWithExecutor(AWSExecutor.mainThreadExecutor(), withBlock: { (task) -> AnyObject! in
            if let market = task.result as? TIPPERMarket {
                self.updateEntityWithModel(market)
            }
            return nil
        })
    }
}