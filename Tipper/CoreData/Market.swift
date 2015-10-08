
import Foundation
import CoreData
import SwiftyJSON

class Market: NSManagedObject, CoreDataUpdatable, ModelCoredataMapable {

    @NSManaged var amount: String?
    @NSManaged var amountCents: String?
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
        if let json = model as? JSON {
            self.subtotalAmount = json["subtotal"].dictionaryValue["amount"]!.stringValue
            self.amount = json["total"].dictionaryValue["amount"]!.stringValue
            self.btc = json["btc"].dictionaryValue["amount"]!.stringValue
            self.updatedAt = NSDate()
        }
    }

    class func market() -> Market {
        return (UIApplication.sharedApplication().delegate as! AppDelegate).market
    }

    func update(completion: () ->Void) {
        API.sharedInstance.market("0.02") { (json, error) -> Void in
            if error == nil {
                self.updateEntityWithModel(json)
            }
            completion()
        }
    }
}