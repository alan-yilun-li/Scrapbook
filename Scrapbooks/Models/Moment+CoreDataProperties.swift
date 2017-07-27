//
//  Moment+CoreDataProperties.swift
//  Scrapbooks
//
//  Created by Dev User on 2017-07-26.
//  Copyright © 2017 Alan Li. All rights reserved.
//

import Foundation
import CoreData


extension Moment {

    @nonobjc public class func createFetchRequest() -> NSFetchRequest<Moment> {
        return NSFetchRequest<Moment>(entityName: "Moment")
    }

    @NSManaged public var caption: String
    @NSManaged public var name: String
    @NSManaged public var scrapbook: Scrapbook

}
