//
//  SettingsTableViewController.swift
//  Scrapbooks
//
//  Created by Alan Li on 2017-09-23.
//  Copyright © 2017 Alan Li. All rights reserved.
//

import UIKit

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
        
        // Updating the views to display the correct settings data.
        updateAllViews()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 0
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 0
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
        passwordLabel.text = UserSettings.current.password ?? "None"
    }
    
    /// Updates all the views at once with the stored settings.
    /// - Note: call at the beginning of this view loading.
    func updateAllViews() {
        updatePasswordLabel()
        
    }
    
}







