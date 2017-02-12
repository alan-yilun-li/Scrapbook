//
//  Moment+CoreDataClass.swift
//  Scrapbook
//
//  Created by Alan Li on 2017-02-12.
//  Copyright © 2017 Alan Li. All rights reserved.
//  This file was automatically generated and should not be edited.
//

import Foundation
import CoreData
import UIKit

@objc(Moment)
public class Moment: NSManagedObject {
    
    // MARK: Initialization
    
    init?(name: String, photo: UIImage?, caption: String) {
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        super.init(entity: Moment(context: context), insertInto: context)
        
        // Initialize stored properties.
        self.name = name
        self.photo = photo
        self.caption = caption
        
        // Catching incorrect values
        if name.isEmpty {
            return nil
        }
    }
    
    
    // MARK: Equality Method
    func hasSameProperties(moment: Moment) -> Bool {
        if ((self.name == moment.name) && (self.photo!.isEqual(moment.photo)) && self.caption == moment.caption) {
            return true
        } else {
            return false
        }
    }
    
    

}
