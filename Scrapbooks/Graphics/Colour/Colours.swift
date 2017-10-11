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
    
    static let yellow = UIColor(red: 255/255, green: 211/255, blue: 0/255, alpha: 1.0)
    
    static let tan = UIColor(red: 229/255, green: 211/255, blue: 181/255, alpha: 1.0)
    
    static let maroon = UIColor(red: 108/255, green: 55/255, blue: 31/255, alpha: 1.0)
    
    static let fadedMaroon = UIColor(red: 108/255, green: 55/255, blue: 31/255, alpha: 0.35)
    
    static let brown = UIColor(red: 105/255, green: 85/255, blue: 75/255, alpha: 1.0)
    
    static let fadedTextColor = UIColor(red: 84/255, green: 89/255, blue: 95/255, alpha: 0.35)
    
    static let textColor = UIColor(red: 84/255, green: 89/255, blue: 95/255, alpha: 1.0)
    
    static let skyBlue = #colorLiteral(red: 0.2392156869, green: 0.6745098233, blue: 0.9686274529, alpha: 1)
    
    // Colouring functions
    
    static func fill(navigationBar: UINavigationBar) {
        navigationBar.barTintColor = yellow
        navigationBar.tintColor = maroon
    }

}
