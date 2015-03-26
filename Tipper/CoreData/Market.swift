
import Foundation
import CoreData
import SwiftyJSON

class Market: NSManagedObject, CoreDataUpdatable {

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

    static var lookupProperty: String {
        get {
            return "btc"
        }
    }

    var lookupValue: String {
        get {
            return self.btc!
        }
    }

    func updateEntityWithJSON(json: JSON) {
        println("\(className)::\(__FUNCTION__) \(json)")
        self.subtotalAmount = json["subtotal"].dictionaryValue["amount"]!.stringValue
        self.amount = json["total"].dictionaryValue["amount"]!.stringValue
        self.btc = json["btc"].dictionaryValue["amount"]!.stringValue
        self.updatedAt = NSDate()
    }

    func updateEntityWithDynamoModel(dynamoObject: DynamoUpdatable) {

    }

    class func market() -> Market {
        return (UIApplication.sharedApplication().delegate as! AppDelegate).market
    }

    func update(completion: () ->Void) {
        API.sharedInstance.market("0.002") { (json, error) -> Void in
            self.updateEntityWithJSON(json)
            self.writeToDisk()
            completion()
        }
    }
}