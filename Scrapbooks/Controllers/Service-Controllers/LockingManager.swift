//
//  LockingManager.swift
//  Scrapbooks
//
//  Created by Alan Li on 2017-09-05.
//  Copyright © 2017 Alan Li. All rights reserved.
//

import Foundation
import LocalAuthentication
import UIKit

struct LockingManager {
    
    static var shared = LockingManager()
    
    var delegate: LockingManagerDelegate?
    
    private init() {
        
    }
    
    /// Function that prompts the user for touch ID input.
    /// - Returns: True if authentication succeeded, and false otherwise.
    func promptForID(forScrapbook scrapbook: Scrapbook) {
        
        guard let responder = delegate else {
            print("Delegate not set")
            return
        }
        
        let context = LAContext()
        
        if canLockWithTouchID() {
            context.evaluatePolicy(LAPolicy.deviceOwnerAuthenticationWithBiometrics, localizedReason: "This scrapbook is locked! Please authenticate with Touch ID.", reply: { (success, error) in
                
                if success {
                    responder.authenticationFinished(withSuccess: true, scrapbook: scrapbook)
                }
                
                if (error != nil) {
                    
                    print(error.debugDescription)
                    responder.authenticationFinished(withSuccess: false, scrapbook: nil)
                    print("error")
                }
            })
        } else {
            print("ERROR: could not evaluate biometrics policy")
        }
    }
    
    /// Function to check if a user can use touch ID.
    func canLockWithTouchID() -> Bool {
        
        let context = LAContext()
        var error: NSError?
        return context.canEvaluatePolicy(LAPolicy.deviceOwnerAuthenticationWithBiometrics, error: &error)
    }
    
    func changeLockStatus(forScrapbook scrapbook: Scrapbook, to status: Bool) {
        
        scrapbook.isLocked = status
        CoreDataStack.shared.saveContext()
        
        NotificationCenter.default.post(name: NSNotification.Name(Constants.lockChangedNotifKey), object: nil)
    }

    
}

/// Protocol for an object which responds to the locking manager.
protocol LockingManagerDelegate {
    
    func authenticationFinished(withSuccess success: Bool, scrapbook: Scrapbook!)
    
}


extension LibraryViewController: LockingManagerDelegate {
    
    func authenticationFinished(withSuccess success: Bool, scrapbook: Scrapbook! = nil) {
        
        if success {
            present(scrapbook: scrapbook)
        } else {
            let response = UIAlertController(title: "Authentication Failed", message: "Please try again.", preferredStyle: .alert)
            response.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            
            present(response, animated: true)
        }
    }
}

