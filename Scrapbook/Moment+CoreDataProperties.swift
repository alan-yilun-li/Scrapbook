//
//  Moment+CoreDataProperties.swift
//  Scrapbook
//
//  Created by Alan Li on 2017-02-12.
//  Copyright © 2017 Alan Li. All rights reserved.
//  This file was automatically generated and should not be edited.
//

import Foundation
import CoreData
import UIKit

extension Moment {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Moment> {
        return NSFetchRequest<Moment>(entityName: "Moment");
    }
    
    @NSManaged public var name: String?
    @NSManaged public var caption: String?
    @NSManaged public var photo: NSObject?

}
