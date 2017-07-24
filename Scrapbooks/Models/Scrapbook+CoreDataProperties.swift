//
//  Scrapbook+CoreDataProperties.swift
//  Scrapbooks
//
//  Created by Dev User on 2017-07-24.
//  Copyright © 2017 Alan Li. All rights reserved.
//

import Foundation
import CoreData


extension Scrapbook {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Scrapbook> {
        return NSFetchRequest<Scrapbook>(entityName: "Scrapbook")
    }

    @NSManaged public var coverPhotoName: String?
    @NSManaged public var title: String?
    @NSManaged public var moments: NSSet?

}

// MARK: Generated accessors for moments
extension Scrapbook {

    @objc(addMomentsObject:)
    @NSManaged public func addToMoments(_ value: Moment)

    @objc(removeMomentsObject:)
    @NSManaged public func removeFromMoments(_ value: Moment)

    @objc(addMoments:)
    @NSManaged public func addToMoments(_ values: NSSet)

    @objc(removeMoments:)
    @NSManaged public func removeFromMoments(_ values: NSSet)

}
