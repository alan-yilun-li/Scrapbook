//
//  SettingsTableViewController.swift
//  Scrapbooks
//
//  Created by Alan Li on 2017-09-23.
//  Copyright © 2017 Alan Li. All rights reserved.
//

import UIKit
import CoreData

class SettingsTableViewController: UITableViewController {

    // MARK: - Storyboard Outlets
    
    @IBOutlet weak var versionLabel: UILabel!
    @IBOutlet weak var passwordLabel: UILabel!
    
    @IBOutlet weak var totalEntriesValueLabel: UILabel!
    @IBOutlet weak var totalEntriesLabel: UILabel!
    @IBOutlet weak var lastUpdatedValueLabel: UILabel!
    @IBOutlet weak var lastUpdatedLabel: UILabel!
    
    // MARK: - ViewController lifecycle functions
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Updating the views to display the correct settings data.
        updateAllViews()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Populating the version label
        versionLabel.text = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String
        
        // Setting up the navigation bar appearance
        ViewCustomizer.customize(navigationBar: navigationController!.navigationBar)
        
        // Setting up notification observers and senders, etc.
        configuringNotifications()
        
        // Setting self up for delegate of LockingManager.forSettings
        LockingManager.forSettings.delegate = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let row = indexPath.row
        
        // Password Related Section
        if indexPath.section == 0 {
            
            switch row {
            case 0:
                if UserSettings.current.password == nil {
                    LockingManager.forSettings.presentEditPasswordAlert(onController: self)
                } else {
                    LockingManager.forSettings.promptForID()
                }
                
            default: fatalError() // Placeholder in case more fields come
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
    
    func updateTotalEntriesLabel() {
        
        let fetchRequest = Scrapbook.createfetchRequest()
        do {
            let result = try CoreDataStack.shared.persistentContainer.viewContext.fetch(fetchRequest)
            
            var totalEntries = 0
            for scrapbook in result {
                totalEntries += scrapbook.moments.count
            }
            totalEntriesValueLabel.text = String(totalEntries)
            
        } catch (let error) {
            print("Error with fetching: \(String(describing: error))")
        }
    }
    
    func updateLastUpdatedLabel() {
        
        if let lastEditedDate = UserSettings.current.lastEdited {
            lastUpdatedValueLabel.text = String(describing: lastEditedDate).components(separatedBy: " ").first!

        } else {
            lastUpdatedValueLabel.text = "N/A"
        }
        
    }
    
    /// Updates all the views at once with the stored settings.
    /// - Note: call at the beginning of this view loading.
    func updateAllViews() {
        updatePasswordLabel()
        updateTotalEntriesLabel()
        updateLastUpdatedLabel()
        
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






