//
//  UserSettings.swift
//  Scrapbooks
//
//  Created by Alan Li on 2017-09-17.
//  Copyright © 2017 Alan Li. All rights reserved.
//

import Foundation

// UserDefault Key Constants

private let PASSWORD_KEY = "PASSWORD"
private let LAST_EDITED_KEY = "LAST_EDITED"

class UserSettings {
    
    // Singleton Initialization
    
    static let current = UserSettings()
    
    private init() {}
    
    var password: String? {
        
        didSet {
            // Positing a notification to update the settings/stats page
            NotificationCenter.default.post(Notification(name: NSNotification.Name(rawValue: LocalNotificationKeys.passwordChangedNotifKey)))
            
            // Saving the value into user defaults
            UserDefaults.standard.setValue(password, forKey: PASSWORD_KEY)
        }
    }
    
    var lastEdited: Date? {
        
        didSet {
            // Posting a notification to update the settings/stats page
            NotificationCenter.default.post(Notification(name: NSNotification.Name(rawValue: LocalNotificationKeys.passwordChangedNotifKey)))
            
            // Saving the value into user defaults
            UserDefaults.standard.setValue(password, forKey: LAST_EDITED_KEY)
        }
    }
    
    /// Retrieving settings from UserDefaults.
    /// - Note: Call this when the app starts to load settings.
    func load() {
        
        password = UserDefaults.standard.string(forKey: PASSWORD_KEY)
        lastEdited = UserDefaults.standard.object(forKey: LAST_EDITED_KEY) as? Date
    }
}
