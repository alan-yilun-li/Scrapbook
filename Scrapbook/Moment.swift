//
//  Moment.swift
//  Scrapbook
//
//  Created by Alan Li on 2016-11-20.
//  Copyright © 2016 Alan Li. All rights reserved.
//

import UIKit

class Moment {
    // MARK: Properties
    
    var name: String
    var photo: UIImage?
    var caption: String
    
    
    // MARK: Initialization
    
    init?(name: String, photo: UIImage?, caption: String) {
        
        // Initialize stored properties.
        self.name = name
        self.photo = photo
        self.caption = caption
        
        // Catching incorrect values
        if name.isEmpty {
            return nil
        }
    }
}
