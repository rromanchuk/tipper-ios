//
//  NSManagedObject+Extension.swift
//  Tipper
//
//  Created by Ryan Romanchuk on 3/8/15.
//  Copyright (c) 2015 Ryan Romanchuk. All rights reserved.
//

import Foundation
import CoreData
import SwiftyJSON

extension NSManagedObject  {
    class func create<T: NSManagedObject where T: CoreDataUpdatable>(entity: T.Type, context: NSManagedObjectContext) -> T {
        var object = NSEntityDescription.insertNewObjectForEntityForName(entity.className, inManagedObjectContext: context) as! T
        return object
    }

    class func all<T: NSManagedObject where T: CoreDataUpdatable>(entity: T.Type, context: NSManagedObjectContext) -> Array<AnyObject>? {
        let request = NSFetchRequest(entityName: entity.className)
        let results = context.executeFetchRequest(request, error: nil)
        return results
    }

    class func first<T: NSManagedObject where T: CoreDataUpdatable>(entity: T.Type, context: NSManagedObjectContext) -> T? {
        return self.all(entity, context: context)?.first as? T
    }

    class func last<T: NSManagedObject where T: CoreDataUpdatable>(entity: T.Type, context: NSManagedObjectContext) -> T? {
        return self.all(entity, context: context)?.last as? T
    }

    class func count<T: NSManagedObject where T: CoreDataUpdatable>(entity: T.Type, context: NSManagedObjectContext) -> Int {
        let request = NSFetchRequest(entityName: entity.className)
        request.includesSubentities = false
        request.includesPropertyValues = false

        let results = context.countForFetchRequest(request, error: nil)
        if (results == NSNotFound) {
            return 0
        } else {
            return results
        }
    }

    class func entityWithJSON<T: NSManagedObject where T: CoreDataUpdatable>(entity: T.Type, json: JSON, context: NSManagedObjectContext) -> T? {
        let request = NSFetchRequest(entityName: entity.className)
        request.predicate = NSPredicate(format: "%K == %@", entity.lookupProperty, json[entity.lookupProperty].stringValue)
        var error: NSError? = nil
        let results = context.executeFetchRequest(request, error: &error)
        if let _error = error {
            println("ERROR: \(_error)")
        }

        if (results == nil) {
            return nil
        } else if (results?.count == 0) {
            let entityObj = self.create(entity, context: context)

            entityObj.updateEntityWithJSON(json)
            return entityObj
        } else {
            let entityObj = results?.last as? T
            entityObj?.updateEntityWithJSON(json)
            return entityObj
        }
    }




    class func entityWithDYNAMO<T: NSManagedObject where T: CoreDataUpdatable>(entity: T.Type, model: DynamoUpdatable, context: NSManagedObjectContext) -> T? {
        //println("\(entity.className) \(model.lookupProperty()) \(model.lookupValue())")
        let request = NSFetchRequest(entityName: entity.className)
        request.predicate = NSPredicate(format: "%K == %@", model.lookupProperty(), model.lookupValue())
        var error: NSError? = nil
        let results = context.executeFetchRequest(request, error: &error)
        if let _error = error {
            println("ERROR: \(_error)")
        }

        if (results == nil) {
            return nil
        } else if (results?.count == 0) {
            let entityObj = self.create(entity, context: context)

            entityObj.updateEntityWithDynamoModel(model)
            return entityObj
        } else {
            let entityObj = results?.last as? T
            entityObj?.updateEntityWithDynamoModel(model)
            return entityObj
        }
    }



    class func entityWithUUID<T: NSManagedObject where T: CoreDataUpdatable>(entity: T.Type, uuid: String, context: NSManagedObjectContext) -> T? {
        let request = NSFetchRequest(entityName: entity.className)
        request.predicate = NSPredicate(format: "uuid == %@", uuid)
        var error: NSError? = nil
        let results = context.executeFetchRequest(request, error: &error)
        if let _error = error {
            println("ERROR: \(_error)")
        }

        if (results == nil) {
            return nil
        } else if (results?.count == 0) {
            return nil
        } else {
            let entityObj = results?.last as? T
            return entityObj
        }
    }

    var privateContext: NSManagedObjectContext {
        get {
            let privateContext = NSManagedObjectContext(concurrencyType: NSManagedObjectContextConcurrencyType.PrivateQueueConcurrencyType)
            privateContext.parentContext = self.managedObjectContext
            return privateContext
        }
    }

    func destroy() {
        println("NSManagedObject::\(__FUNCTION__)")
        self.managedObjectContext?.deleteObject(self)
    }

    func save() {
        self.managedObjectContext?.saveMoc()
    }

    func writeToDisk() {
        NSManagedObject.writeToDisk()
    }

    class func writeToDisk() {
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        appDelegate.writeToDisk()
    }

    class func appManagedObjectContext() -> NSManagedObjectContext {
        return (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext!
    }

    func appManagedObjectContext() -> NSManagedObjectContext {
        return (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext!
    }
}

extension NSManagedObjectContext {
    var privateContext: NSManagedObjectContext {
        get {
            let privateContext = NSManagedObjectContext(concurrencyType: NSManagedObjectContextConcurrencyType.PrivateQueueConcurrencyType)
            privateContext.parentContext = self
            return privateContext
        }
    }

}