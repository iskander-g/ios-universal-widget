//
//  CoreDataHelper.swift
//  universalwidget
//
//  Created by Искандер on 22.06.15.
//  Copyright (c) 2015 beboss. All rights reserved.
//

import UIKit
import CoreData

class CoreDataHelper: NSObject {
    class var instance: CoreDataHelper {
        struct Singleton {
            static let instance = CoreDataHelper()
        }
        return Singleton.instance
    }
    
    var coordinator: NSPersistentStoreCoordinator
    var model: NSManagedObjectModel
    var context: NSManagedObjectContext
    
    private override init() {
        
        let modelUrl = NSBundle.mainBundle().URLForResource("JsonList", withExtension: "momd")
        model = NSManagedObjectModel(contentsOfURL: modelUrl!)!
        
        let FileManager = NSFileManager.defaultManager()
        //let docsUrl = FileManager.URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask).last as! NSURL
        let docsUrl = FileManager.containerURLForSecurityApplicationGroupIdentifier("group.beboss.universalwidget")!
        let storeUrl = docsUrl.URLByAppendingPathComponent("base.sqlite")
        
        coordinator = NSPersistentStoreCoordinator(managedObjectModel: model)
        do {
            let store = try coordinator.addPersistentStoreWithType(NSSQLiteStoreType, configuration: nil, URL: storeUrl, options: nil)
            
            context = NSManagedObjectContext();
            context.persistentStoreCoordinator = coordinator
        }
        catch {
            abort()
        }
    }
    
    
    func save() {
        do {
            try context.save()
        }
        catch {
        }
    }
}
