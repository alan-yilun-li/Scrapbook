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
    
    func setup(withName newName: String, photo: UIImage, newCaption: String, forScrapbook: Scrapbook) {
    
        name = newName
        scrapbook = forScrapbook
        FileSystemHelper.saveToDisk(photo: photo, withName: name, forScrapbook: forScrapbook)
        caption = newCaption
    }
    
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
