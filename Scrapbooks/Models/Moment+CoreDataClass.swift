//
//  Moment+CoreDataClass.swift
//  Scrapbooks
//
//  Created by Dev User on 2017-07-24.
//  Copyright © 2017 Alan Li. All rights reserved.
//

import Foundation
import CoreData
import UIKit


public class Moment: NSManagedObject {
    
    var photo: UIImage {
        get {
            return FileSystemHelper.retrieveFromDisk(photoWithName: name, forScrapbook: scrapbook)!
        }
        set {
            FileSystemHelper.removeFromDisk(photoWithName: name, forScrapbook: scrapbook)
            FileSystemHelper.saveToDisk(photo: newValue, withName: name, forScrapbook: scrapbook)
        }
    }
    
    func setup(withName newName: String, photo: UIImage, newCaption: String, chosenDate: Date, forScrapbook: Scrapbook) {
    
        name = newName
        scrapbook = forScrapbook
        FileSystemHelper.saveToDisk(photo: photo, withName: name, forScrapbook: forScrapbook)
        caption = newCaption
        date = chosenDate
    }
    
    /// Swapping data with another moment because working with NSSet can be weird. 
    /// - Note: Currently not in use, though could be useful later.
    func swapDataWith(moment: Moment) {
        
        let tempName = name
        let tempCaption = caption
        let tempScrapbook = scrapbook
        
        name = moment.name
        caption = moment.caption
        scrapbook = moment.scrapbook
        
        moment.name = tempName
        moment.caption = tempCaption
        moment.scrapbook = tempScrapbook
    }
}

extension Moment: Named {} 
