//
//  Colours.swift
//  Scrapbooks
//
//  Created by Alan Li on 2017-08-03.
//  Copyright © 2017 Alan Li. All rights reserved.
//

import Foundation
import UIKit

// Stores helpful colours for the scrapbook theme.
struct Colours {
    
    static let yellow = UIColor(colorLiteralRed: 255/255, green: 211/255, blue: 0/255, alpha: 1.0)
    
    static let tan = UIColor(colorLiteralRed: 229/255, green: 211/255, blue: 181/255, alpha: 1.0)
    
    static let maroon = UIColor(colorLiteralRed: 108/255, green: 55/255, blue: 31/255, alpha: 1.0)
    
    static let brown = UIColor(colorLiteralRed: 105/255, green: 85/255, blue: 75/255, alpha: 1.0)
    
    // Colouring functions
    
    static func fill(navigationBar: UINavigationBar) {
        navigationBar.barTintColor = yellow
        navigationBar.tintColor = maroon
    }

    
}
