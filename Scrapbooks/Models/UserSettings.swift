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

class UserSettings {
    
    // Singleton Initialization
    
    static let current = UserSettings()
    
    private init() {}
    
    var password: String? {
        
        didSet { 
            UserDefaults.standard.setValue(password, forKey: PASSWORD_KEY)
        }
    }
    
    /// Retrieving settings from UserDefaults.
    /// - Note: Call this when the app starts to load settings.
    func load() {
        
        password = UserDefaults.standard.string(forKey: PASSWORD_KEY)
    }
}
