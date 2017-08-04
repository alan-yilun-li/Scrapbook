//
//  ViewCustomizer .swift
//  Scrapbooks
//
//  Created by Alan Li on 2017-08-03.
//  Copyright © 2017 Alan Li. All rights reserved.
//

import Foundation
import UIKit

struct ViewCustomizer {
    
    static func customize(navigationBar: UINavigationBar) {
        navigationBar.isTranslucent = true
        Colours.fill(navigationBar: navigationBar)
        navigationBar.titleTextAttributes = [NSFontAttributeName: Fonts.titleFont as Any]
    }

}
