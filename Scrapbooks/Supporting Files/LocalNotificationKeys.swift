//
//  LocalNotificationKeys.swift
//  Scrapbooks
//
//  Created by Alan Li on 2017-09-23.
//  Copyright © 2017 Alan Li. All rights reserved.
//

import Foundation

/// Static structure for holding local notification keys. 
struct LocalNotificationKeys {
    
    // Keys for custom registered local notifications
    
    static let lockChangedNotifKey = "SCRAPBOOK_LOCK_CHANGED"
    
    static let passwordChangedNotifKey = "PASSWORD_CHANGED"
    
    static let lastSavedKey = "LAST_SAVED_KEY"
}
