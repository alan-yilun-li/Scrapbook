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

class LockingManager {
    
    static var shared = LockingManager()
    
    var delegate: LockingManagerDelegate?
    
    var editPasswordController: UIAlertController!
    
    var authorizationFallbackController: UIAlertController!
    
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
                
                if let authError = error as? LAError {
                    
                    switch authError.code {
                        
                    case .userFallback:
                        self.presentFallbackAlert(onController: responder as! LibraryViewController, forScrapbook: scrapbook)
                        
                    case .userCancel: return
                        
                    case .touchIDNotEnrolled:
                        responder.presentAlertForNoTouchID(forScrapbook: scrapbook)
                        
                    default:
                        responder.authenticationFinished(withSuccess: false, scrapbook: nil)
                    }
                    
                    print(error.debugDescription)
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
    
    func presentAlertForNoTouchID(forScrapbook scrapbook: Scrapbook)
    
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
    
    
    func presentAlertForNoTouchID(forScrapbook scrapbook: Scrapbook) {
        
        let alert = UIAlertController(title: "No TouchID!", message: "Lock is unavailable as TouchID has been removed from your device.", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Access Scrapbook", style: .default, handler: { [unowned self] _ in
            
            self.present(scrapbook: scrapbook)
        }))
    }
}

/// Extension for holding locking workflow for a scrapbook 
extension MomentTableViewController {
    
    func startAddLockProcess() {
        
        let lockAddedAlert = UIAlertController(title: "Lock Scrapbook?", message: "Locking adds Touch ID security for accessing your scrapbook.", preferredStyle: .alert)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        let lockAction = UIAlertAction(title: "Lock", style: .destructive, handler: { [unowned self] _ in
            
            guard LockingManager.shared.canLockWithTouchID() else {
                
                let noTouchIDAlert = UIAlertController(title: "Cannot Lock!", message: "Please check to see if TouchID is configured on your device.", preferredStyle: .alert)
                
                noTouchIDAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                
                self.present(noTouchIDAlert, animated: true)
                return
            }
            
            if UserSettings.current.password == nil {
                
                LockingManager.shared.presentEditPasswordAlert(onController: self)
                return
            }
            
            LockingManager.shared.changeLockStatus(forScrapbook: self.scrapbook, to: true)
            
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
            
            LockingManager.shared.changeLockStatus(forScrapbook: self.scrapbook, to: false)
            
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
    
    func presentFallbackAlert(onController viewController: LibraryViewController, forScrapbook scrapbook: Scrapbook) {
        
        if authorizationFallbackController == nil {
            let fallbackAlert = UIAlertController(title: "Enter Password", message: "Enter Scrapbooks-specific password for access.", preferredStyle: .alert)
            
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
                    
                    viewController.present(scrapbook: scrapbook)
                } else {
                    
                    let wrongPasswordAlert = UIAlertController(title: "Wrong Password!", message: "Please try again.", preferredStyle: .alert)
                    
                    wrongPasswordAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                    
                    viewController.present(wrongPasswordAlert, animated: true)
                }
            })
            
            continueAction.isEnabled = false
            
            fallbackAlert.addAction(cancelAction)
            fallbackAlert.addAction(continueAction)
            
            authorizationFallbackController = fallbackAlert
        }
        
        viewController.present(authorizationFallbackController, animated: true)
    }
    
    
    func presentEditPasswordAlert(onController viewController: UIViewController) {
        
        if editPasswordController == nil {
            
            let setPasswordAlert = UIAlertController(title: "Set Password", message: "Set a password as a fallback option for TouchID. This will be your password for all of Scrapbooks.", preferredStyle: .alert)
            
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
            
            editPasswordController = setPasswordAlert
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
        
        continueAction.isEnabled = (text.characters.count > 3)
    }
    
    
}














