//
//  Moments.swift
//  Scrapbook
//
//  Created by Alan Li on 2017-02-12.
//  Copyright © 2017 Alan Li. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class Moments {
    
    var moments = [Moment]()
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    func getContext () -> NSManagedObjectContext {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        return appDelegate.persistentContainer.viewContext
    }
    
    // MARK: Saving
    
    func addMoment(name: String, photo: UIImage, caption: String) {
        let context = getContext()
        let entity =  NSEntityDescription.entity(forEntityName: "Moment", in: context)
        let moment = NSManagedObject(entity: entity!, insertInto: context)
        
        moment.setValue(name, forKey: "name")
        moment.setValue(photo, forKey: "photo")
        moment.setValue(caption, forKey: "caption")
        
        do {
            try context.save()
            print("saved!")
        } catch let error as NSError  {
            print("Could not save \(error), \(error.userInfo)")
        }
    }
    
    
}
