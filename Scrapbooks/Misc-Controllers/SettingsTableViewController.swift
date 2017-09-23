//
//  SettingsTableViewController.swift
//  Scrapbooks
//
//  Created by Alan Li on 2017-09-23.
//  Copyright © 2017 Alan Li. All rights reserved.
//

import UIKit
import LocalAuthentication

class SettingsTableViewController: UITableViewController {

    // MARK: - Storyboard Outlets
    
    @IBOutlet weak var passwordLabel: UILabel!
    
    @IBOutlet weak var totalEntriesValueLabel: UILabel!
    @IBOutlet weak var totalEntriesLabel: UILabel!
    
    @IBOutlet weak var lastUpdatedValueLabel: NSLayoutConstraint!
    @IBOutlet weak var lastUpdatedLabel: UILabel!
    
    // MARK: - ViewController lifecycle functions
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Setting up the navigation bar appearance
        ViewCustomizer.customize(navigationBar: navigationController!.navigationBar)
        
        // Setting up notification observers and senders, etc.
        configuringNotifications()
        
        // Setting self up for delegate of LockingManager.forSettings
        LockingManager.forSettings.delegate = self 
        
        // Updating the views to display the correct settings data.
        updateAllViews()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if indexPath.section == 0 {
            
            let row = indexPath.row
            
            switch row {
            case 0: LockingManager.forSettings.promptForID()
            default: fatalError()
            }
        }
    }


    // MARK: IBActions
    
    /// Action for when the user presses the back button of the navigation controller.
    @IBAction func backButtonPressed(_ sender: Any) {
        dismiss(animated: true)
    }
    
    
    /// Registering for all notifications the SettingsTableViewController should listen for.
    func configuringNotifications() {
        
        NotificationCenter.default.addObserver(self, selector: #selector(updatePasswordLabel), name: NSNotification.Name(rawValue: LocalNotificationKeys.passwordChangedNotifKey), object: nil)
        
    }
    
    /// Updating the password on change
    @objc func updatePasswordLabel() {
        let passwordLength = UserSettings.current.password?.count ?? 0
        
        let displayString = String(repeating: "*", count: passwordLength)
        
        if displayString == "" {
            passwordLabel.text = "None"
        } else {
            passwordLabel.text = displayString
        }
    }
    
    /// Updates all the views at once with the stored settings.
    /// - Note: call at the beginning of this view loading.
    func updateAllViews() {
        updatePasswordLabel()
        
    }
    
    
    /// Function that prompts the user for touch ID input.
    func presentAuthForSettings() {
        let context = LAContext()
        
        if LockingManager.forScrapbooks.canLockWithTouchID() {
            context.evaluatePolicy(LAPolicy.deviceOwnerAuthenticationWithBiometrics, localizedReason: "This scrapbook is locked! Please authenticate with Touch ID.", reply: { (success, error) in
                /*
                if success {
                    
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
                }*/
            })
        } else {
            print("ERROR: could not evaluate biometrics policy")
        }
    }
}


// MARK: - LockingManager and TouchID Delegate Methods
extension SettingsTableViewController: LockingManagerDelegate {
    
    
    func authenticationFinished(withSuccess success: Bool, scrapbook: Scrapbook! = nil) {
        
        if success {
            LockingManager.forSettings.presentEditPasswordAlert(onController: self)
        } else {
            let response = UIAlertController(title: "Authentication Failed", message: "Please try again.", preferredStyle: .alert)
            response.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            
            present(response, animated: true)
        }
    }
    
    
    func presentAlertForNoTouchID(forScrapbook scrapbook: Scrapbook!) {
        
        let alert = UIAlertController(title: "No TouchID!", message: "Please edit password after Touch ID and locking has been restored in Settings > Touch ID & Passcode", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Access Scrapbook", style: .default, handler: nil))
        
        present(alert, animated: true)
    }
}






