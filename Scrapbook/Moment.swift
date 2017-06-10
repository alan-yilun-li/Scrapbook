//
//  Moment.swift
//  Scrapbook
//
//  Created by Alan Li on 2016-11-20.
//  Copyright © 2016 Alan Li. All rights reserved.
//

import UIKit

class Moment: NSObject, NSCoding {
    
    // MARK: Properties
    
    var name: String
    var photo: UIImage?
    var caption: String
    
    // MARK: Archiving Paths
    
    // Note: outside the class, access the path using Moment.ArchiveURL.path!
    static let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    static let archiveURL = documentsDirectory.appendingPathComponent("moments")
    
    // MARK: Types
    
    struct PropertyKey {
        static let nameKey = "name"
        static let photoKey = "photo"
        static let captionKey = "caption"
    }
    
    // MARK: Initialization
    
    init?(name: String, photo: UIImage?, caption: String) {
        
        // Initialize stored properties.
        self.name = name
        self.photo = photo
        self.caption = caption
        
        super.init()
        
        // Catching incorrect values
        if name.isEmpty {
            return nil
        }
    }
    
    // MARK: NSCoding
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(name, forKey: PropertyKey.nameKey)
        aCoder.encode(photo, forKey: PropertyKey.photoKey)
        aCoder.encode(caption, forKey: PropertyKey.captionKey)
    }
    
    required convenience init?(coder aDecoder: NSCoder) {
        let name = aDecoder.decodeObject(forKey: PropertyKey.nameKey) as! String
        let photo = aDecoder.decodeObject(forKey: PropertyKey.photoKey) as? UIImage
        let caption = aDecoder.decodeObject(forKey: PropertyKey.captionKey) as? String
        
        // Calling the designated initializer
        self.init(name: name, photo: photo, caption: caption!)
    }
    
    // MARK: Equality Method
    
    func hasSameProperties(moment: Moment) -> Bool {
        if ((name == moment.name) && (photo!.isEqual(moment.photo)) && caption == moment.caption) {
            return true
        } else {
            return false
        }
    }
}









