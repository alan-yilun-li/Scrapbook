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

enum LockPromptReason: Int {

    case forLockedScrapbook = 0
    case forChangingPassword = 1
    
}

class LockingManager {
    
    static var forScrapbooks = LockingManager()
    
    static var forSettings = LockingManager()
    
    var delegate: LockingManagerDelegate?
    
    var editPasswordController: UIAlertController!
    
    var authorizationFallbackController: UIAlertController!
    
    private init() {
    }
    
    /// Function that prompts the user for touch ID input.
    func promptForID(forScrapbook scrapbook: Scrapbook! = nil) {
        
        guard let responder = delegate as? UIViewController else {
            print("Delegate not set")
            return
        }
        
        let context = LAContext()
        
        if canLockWithTouchID() {
            context.evaluatePolicy(LAPolicy.deviceOwnerAuthenticationWithBiometrics, localizedReason: "This scrapbook is locked! Please authenticate with Touch ID.", reply: { [unowned self] (success, error) in
                
                if success {
                    self.delegate!.authenticationFinished(withSuccess: true, scrapbook: scrapbook)
                }
                
                if let authError = error as? LAError {
                    
                    // Note: scrapbook can still equal nil here. This is the case for the settings page.
                    
                    switch authError.code {
                        
                    case .userFallback:
                        
                        self.presentFallbackAlert(onController: responder , forScrapbook: scrapbook)
                        
                    case .userCancel: return
                        
                    case .touchIDNotEnrolled:
                        self.delegate!.presentAlertForNoTouchID(forScrapbook: scrapbook)
                        
                    default:
                        self.delegate!.authenticationFinished(withSuccess: false, scrapbook: nil)
                    }
                    
                    print(error.debugDescription)
                }
            })
        } else {
            
            let biometricsFailedAlert = UIAlertController(title: "TouchID Temporarily Disabled", message: "Please lock and unlock your phone.", preferredStyle: .alert)
            biometricsFailedAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            
            responder.present(biometricsFailedAlert, animated: true)
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
        
        NotificationCenter.default.post(name: NSNotification.Name(LocalNotificationKeys.lockChangedNotifKey), object: nil)
    }
    
}


/// Protocol for an object which responds to the locking manager.
protocol LockingManagerDelegate {
    
    func authenticationFinished(withSuccess success: Bool, scrapbook: Scrapbook!)
    
    func presentAlertForNoTouchID(forScrapbook scrapbook: Scrapbook!)
    
}

// Adding locking conformance to LibraryViewController
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
    
    
    func presentAlertForNoTouchID(forScrapbook scrapbook: Scrapbook!) {
        
        let alert = UIAlertController(title: "No TouchID!", message: "Lock is unavailable as TouchID has been removed from your device.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Access Scrapbook", style: .default, handler: { [unowned self] _ in
            
            self.present(scrapbook: scrapbook)
        }))
        
        present(alert, animated: true)
    }
}

/// Extension for holding locking workflow for a scrapbook 
extension MomentTableViewController {
    
    func startAddLockProcess() {
        
        let lockAddedAlert = UIAlertController(title: "Lock Scrapbook?", message: "Locking adds Touch ID security for accessing your scrapbook.", preferredStyle: .alert)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        let lockAction = UIAlertAction(title: "Lock", style: .destructive, handler: { [unowned self] _ in
            
            guard LockingManager.forScrapbooks.canLockWithTouchID() else {
                
                let noTouchIDAlert = UIAlertController(title: "Cannot Lock!", message: "Please check to see if TouchID is configured on your device.", preferredStyle: .alert)
                
                noTouchIDAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                
                self.present(noTouchIDAlert, animated: true)
                return
            }
            
            if UserSettings.current.password == nil {
                
                LockingManager.forScrapbooks.presentEditPasswordAlert(onController: self)
                return
            }
            
            LockingManager.forScrapbooks.changeLockStatus(forScrapbook: self.scrapbook, to: true)
            
            let lockResponseAlert = UIAlertController(title: "Scrapbook Locked", message: "You now need to enter your Touch ID or password to access \'\(self.scrapbook.name!)\'.", preferredStyle: .alert)
            
            lockResponseAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            
            self.present(lockResponseAlert, animated: true)
        })
        
        lockAddedAlert.addAction(cancelAction)
        lockAddedAlert.addAction(lockAction)
        
        present(lockAddedAlert, animated: true)

    }
    
    
    func startRemoveLockProcess() {
        
        let lockAddedAlert = UIAlertController(title: "Remove Lock?", message: "Removing lock means you no longer need to use Touch ID to access the Scrapbook.", preferredStyle: .alert)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        let lockAction = UIAlertAction(title: "Unlock", style: .destructive, handler: { [unowned self] _ in
            
            LockingManager.forScrapbooks.changeLockStatus(forScrapbook: self.scrapbook, to: false)
            
            let unlockResponseAlert = UIAlertController(title: "Scrapbook Unlocked", message: "Anyone can now see \'\(self.scrapbook.name!)\' if they have access to your phone.", preferredStyle: .alert)
            
            unlockResponseAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            
            self.present(unlockResponseAlert, animated: true)
        })
        
        lockAddedAlert.addAction(cancelAction)
        lockAddedAlert.addAction(lockAction)
        
        present(lockAddedAlert, animated: true)

    }
}

private enum pwTextSetupReason: Int {
    
    case initialSetup = 0
    case passwordCheck = 1
}

extension LockingManager {
    
    private func passwordTextFieldSetup(forTextfield textfield: UITextField, forReason reason: pwTextSetupReason) {
        
        textfield.placeholder = "Enter your password here."
        textfield.autocapitalizationType = .none
        textfield.tag = reason.rawValue
        textfield.isSecureTextEntry = true
        textfield.addTarget(self, action: #selector(self.textFieldChanged), for: UIControlEvents.editingChanged)
    }
    
    func presentFallbackAlert(onController viewController: UIViewController, forScrapbook scrapbook: Scrapbook) {
        
        if authorizationFallbackController == nil {
            let fallbackAlert = UIAlertController(title: "Enter Password", message: "Enter Scrapbooks-specific password for access.", preferredStyle: .alert)
            
            authorizationFallbackController = fallbackAlert
            
            fallbackAlert.addTextField(configurationHandler: { [unowned self] (textfield) in
                self.passwordTextFieldSetup(forTextfield: textfield, forReason: .passwordCheck)
            })
            
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: { [unowned self] _ in
                
                self.authorizationFallbackController.textFields![0].text = ""
            })
            
            let continueAction = UIAlertAction(title: "Continue", style: .default, handler: { [unowned self] _ in
                
                let password = self.authorizationFallbackController.textFields![0].text!
                self.authorizationFallbackController.textFields![0].text = ""
                
                if UserSettings.current.password == password {
                    if let libraryController = viewController as? LibraryViewController {
                        libraryController.present(scrapbook: scrapbook)
                    } else {
                        LockingManager.forSettings.presentEditPasswordAlert(onController: self.delegate as! UIViewController)
                    }
                } else {
                    
                    let wrongPasswordAlert = UIAlertController(title: "Wrong Password!", message: "Please try again.", preferredStyle: .alert)
                    
                    wrongPasswordAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                    
                    viewController.present(wrongPasswordAlert, animated: true)
                }
            })
            
            continueAction.isEnabled = false
            
            fallbackAlert.addAction(cancelAction)
            fallbackAlert.addAction(continueAction)
        
        }
        
        viewController.present(authorizationFallbackController, animated: true)
    }
    
    
    func presentEditPasswordAlert(onController viewController: UIViewController) {
        
        if editPasswordController == nil {
        
            let setPasswordAlert = UIAlertController(title: "Set Password", message: "Set a password as a fallback option for TouchID. This will be your password for all of Scrapbooks.", preferredStyle: .alert)
        
            self.editPasswordController = setPasswordAlert
            
            DispatchQueue.main.async {
                
                setPasswordAlert.addTextField(configurationHandler: { [unowned self] (textfield) in
                    self.passwordTextFieldSetup(forTextfield: textfield, forReason: .initialSetup)
                })
                
                let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: { [unowned self] _ in
                    
                    self.editPasswordController.textFields![0].text = ""
                })
                
                let continueAction = UIAlertAction(title: "Continue", style: .default, handler: { [unowned self] _ in
                    
                    let password = self.editPasswordController.textFields![0].text!
                    
                    UserSettings.current.password = password
                    
                    let passwordSuccessAlert = UIAlertController(title: "Password Set!", message: nil, preferredStyle: .alert)
                    
                    passwordSuccessAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                    
                    self.editPasswordController.textFields![0].text = ""
                    viewController.present(passwordSuccessAlert, animated: true)
                })
                
                continueAction.isEnabled = false
                
                setPasswordAlert.addAction(cancelAction)
                setPasswordAlert.addAction(continueAction)

            }
        }

        viewController.present(editPasswordController, animated: true)
    }
    
    
    @objc func textFieldChanged(_ textfield: UITextField) {
        let text = textfield.text ?? ""
        
        var continueAction: UIAlertAction!
        
        if textfield.tag == pwTextSetupReason.initialSetup.rawValue {
            continueAction = editPasswordController.actions[1]
        }
        
        if textfield.tag == pwTextSetupReason.passwordCheck.rawValue {
            continueAction = authorizationFallbackController.actions[1]
        }
        
        continueAction.isEnabled = (text.count > 3)
    }
    
    
}














