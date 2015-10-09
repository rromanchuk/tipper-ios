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
        let object = NSEntityDescription.insertNewObjectForEntityForName(entity.className, inManagedObjectContext: context) as! T
        return object
    }

    class func all<T: NSManagedObject where T: CoreDataUpdatable>(entity: T.Type, context: NSManagedObjectContext) -> Array<AnyObject>? {
        let request = NSFetchRequest(entityName: entity.className)
        let results = try? context.executeFetchRequest(request)
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

    class func entityWithId<T: NSManagedObject where T: CoreDataUpdatable>(entity: T.Type, context: NSManagedObjectContext, lookupProperty: String, lookupValue: String) -> T? {
        let request = NSFetchRequest(entityName: entity.className)

        request.predicate = NSPredicate(format: "%K == %@", lookupProperty, lookupValue)
        return try! context.executeFetchRequest(request).last as? T
    }

    class func entityWithModel<T: NSManagedObject where T: CoreDataUpdatable>(entity: T.Type, model: ModelCoredataMapable, context: NSManagedObjectContext) -> T? {
        let request = NSFetchRequest(entityName: entity.className)
        request.predicate = NSPredicate(format: "%K == %@", model.lookupProperty(), model.lookupValue())
        var error: NSError? = nil
        let results: [AnyObject]?
        do {
            results = try context.executeFetchRequest(request)
        } catch let error1 as NSError {
            error = error1
            results = nil
        }
        if let _error = error {
            log.error("ERROR: \(_error)")
        }

        if (results == nil) {
            return nil
        } else if (results?.count == 0) {
            let entityObj = self.create(entity, context: context)

            entityObj.updateEntityWithModel(model)
            return entityObj
        } else {
            let entityObj = results?.last as? T
            entityObj?.updateEntityWithModel(model)
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
        log.warning("")
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
        return (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
    }

    func appManagedObjectContext() -> NSManagedObjectContext {
        return (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
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