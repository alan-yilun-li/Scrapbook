//
//  File.swift
//  Scrapbook
//
//  Created by Dev User on 2017-07-20.
//  Copyright © 2017 Alan Li. All rights reserved.
//

import Foundation
import UIKit

struct Scrapbook {
    
    var title: String
    
    var coverPhoto: UIImage
    
    var moments: [Moment]
    
    static let placeholder = Scrapbook("Add a Scrapbook", #imageLiteral(resourceName: "DefaultPhoto"))
    
    init(_ title: String, _ coverPhoto: UIImage) {
        self.title = title
        self.coverPhoto = coverPhoto
        self.moments = []
    }
}
