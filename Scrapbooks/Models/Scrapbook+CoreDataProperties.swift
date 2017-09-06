//
//  Scrapbook+CoreDataProperties.swift
//  Scrapbooks
//
//  Created by Alan Li on 2017-09-06.
//  Copyright © 2017 Alan Li. All rights reserved.
//

import Foundation
import CoreData


extension Scrapbook {

    @nonobjc public class func createFetchRequest() -> NSFetchRequest<Scrapbook> {
        return NSFetchRequest<Scrapbook>(entityName: "Scrapbook")
    }

    @NSManaged public var name: String!
    @NSManaged public var isLocked: Bool
    @NSManaged public var moments: NSOrderedSet!

}

// MARK: Generated accessors for moments
extension Scrapbook {

    @objc(insertObject:inMomentsAtIndex:)
    @NSManaged public func insertIntoMoments(_ value: Moment, at idx: Int)

    @objc(removeObjectFromMomentsAtIndex:)
    @NSManaged public func removeFromMoments(at idx: Int)

    @objc(insertMoments:atIndexes:)
    @NSManaged public func insertIntoMoments(_ values: [Moment], at indexes: NSIndexSet)

    @objc(removeMomentsAtIndexes:)
    @NSManaged public func removeFromMoments(at indexes: NSIndexSet)

    @objc(replaceObjectInMomentsAtIndex:withObject:)
    @NSManaged public func replaceMoments(at idx: Int, with value: Moment)

    @objc(replaceMomentsAtIndexes:withMoments:)
    @NSManaged public func replaceMoments(at indexes: NSIndexSet, with values: [Moment])

    @objc(addMomentsObject:)
    @NSManaged public func addToMoments(_ value: Moment)

    @objc(removeMomentsObject:)
    @NSManaged public func removeFromMoments(_ value: Moment)

    @objc(addMoments:)
    @NSManaged public func addToMoments(_ values: NSOrderedSet)

    @objc(removeMoments:)
    @NSManaged public func removeFromMoments(_ values: NSOrderedSet)

}
