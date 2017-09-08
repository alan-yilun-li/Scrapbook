//
//  MomentTableViewController.swift
//  Scrapbook
//
//  Created by Alan Li on 2016-11-23.
//  Copyright © 2016 Alan Li. All rights reserved.
//

import UIKit
import CoreData
import LocalAuthentication

class MomentTableViewController: UITableViewController {

    // MARK: - Outlets and Properties
    
    /// The searchbar to allow users to filter results in the root tableview.
    @IBOutlet weak var searchBar: UISearchBar!
    
    /// The scrapbook whose contents the MomentTableViewController summarizes
    var scrapbook: Scrapbook!
    
    /// A collection of all the moments belonging to this scrapbook.
    var moments: [Moment] {
        get {
            return scrapbook.moments.array as! [Moment]
        }
    }
    
    var toolbarManager: ScrapbookToolbarManager!
    
    /// A collection of all the moments belonging to this scrapbook to be displayed.
    var displayedMoments: [Moment] {
        
        // Filtering the list of moments based on the search criteria.
        /// Note: this is not very efficient at the moment because this huge block must be called everytime displayedMoments is accessed.... we can restructure this to be called less later.
        get {
            
            // If no search text, return just the unfiltered moments list
            guard let searchCriteria = searchBar.text?.lowercased(), searchCriteria != "" else {
                return moments
            }
            
            /// Array of words in the search.
            let searchWords = searchCriteria.components(separatedBy: " ")
            
            return moments.filter {
                
                // Getting a list of all the words in the caption and title
                
                /// All words in the name of a moment.
                let titleWords = $0.name.lowercased().components(separatedBy: " ")
                
                /// All words in the caption of a moment.
                let captionWords = $0.caption.lowercased().components(separatedBy: " ")
                
                
                // If the name has the entire search criteria inside.
                if (searchCriteria.characters.count > 1) && (($0.name.lowercased().contains(searchCriteria)) || ($0.caption.lowercased().contains(searchCriteria))) {
                    return true
                }
                
                for word in titleWords {
                    if searchCriteria.characters.first == word.characters.first {
                        return true
                    }
                
                }
                
                // Checking if individual words from the search criteria are in the moment.
                for word in searchWords {
                    
                    if titleWords.contains(word) || captionWords.contains(word) {
                        return true
                    }
                }
                
                return false
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("Table of Contents viewDidLoad")
        
        // Setting navigation bar appearance
        let navBar = navigationController!.navigationBar
        ViewCustomizer.customize(navigationBar: navBar)
        
        // Setting up the UISearchBar
        searchBar.delegate = self
        searchBar.returnKeyType = .default
        
        // Making so that the initial view has the searchBar hidden (scrolled above to the navbar)
        let topPosition = CGPoint(x: 0, y: searchBar.frame.height)
        
        tableView.setContentOffset(topPosition, animated: false)
        
        // Uncomment the following line to preserve selection between presentations
        // clearsSelectionOnViewWillAppear = false
        
        // Adding a touch gesture recognizer to resign the keyboard on tap.
        let searchKeyboardDismisser = UITapGestureRecognizer(target: self, action: #selector(endSearch))
        searchKeyboardDismisser.cancelsTouchesInView = false
        
        tableView.addGestureRecognizer(searchKeyboardDismisser)
        
        ViewCustomizer.customizeToolbar(forNavigationController: navigationController!)
        toolbarManager = ScrapbookToolbarManager(forMomentTable: self)
        
        // Showing the toolbar
        navigationController!.isToolbarHidden = false
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return displayedMoments.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        /// Reuse identifier for a cell to store a moment.
        let cellidentifier = Constants.momentTableViewCellIdentifier
        
        /// Cell retrieved by using the reuse identifier.
        let cell = tableView.dequeueReusableCell(withIdentifier: cellidentifier, for: indexPath) as! MomentTableViewCell
        
        /// The appropriate moment corresponding to the cell.
        let moment = displayedMoments[indexPath.row]
        
        // Setting cell values
        cell.setup(withMoment: moment)
                
        // To remove incorrect cell flashing on selection/return
        cell.selectionStyle = UITableViewCellSelectionStyle.none
        
        return cell
    }
    
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    
    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        
        let moment = moments[indexPath.row]
        
        // Share Button
        let shareButton = UITableViewRowAction(style: .normal, title: "Share", handler: { [unowned self] _ in
            
            let helper = SocialMediaManager(forController: self, forSharing: moment)
            helper.bringUpSharingOptions()
        })
        
        shareButton.backgroundColor = Colours.skyBlue
        shareButton.backgroundEffect = UIBlurEffect(style: .light)
        
        // Delete Button
        let deleteButton = UITableViewRowAction(style: .destructive, title: "Delete", handler: { [unowned self] _ in
            
            self.scrapbook.properlyRemove(moment: moment)
            CoreDataStack.shared.saveContext()
            tableView.deleteRows(at: [indexPath], with: .fade)
        })
        
        return [deleteButton, shareButton]
    }
 
    
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {
        
        // This is the function that allows you to press 'Edit' and then drag to rearrange cells. 
        // Thus: change your data arrangement here! (To correspond with the user's changes)
        
        /// The original row of the moment being moved.
        let originalRow = fromIndexPath.row
        
        /// The new row where the moment will reside.
        let newRow = to.row
        
        /// The moment being moved.
        // O(n) Implementation of swapping out the corrent moment and replacing it at the right place
        
        var i = originalRow
        while i != newRow {
            
            let n = (newRow > originalRow) ? 1 : -1
            moments[i].swapDataWith(moment: moments[i + n])
            i += n
        }
        
        CoreDataStack.shared.saveContext()
    }

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    
        let navigationControl = segue.destination as! UINavigationController
        navigationControl.navigationItem.title = scrapbook.name
        print("navigationControl title is \(navigationControl.navigationItem.title!)")
        
        if segue.identifier == "ShowDetail" {
            // Book is being shown
            
            let momentPageViewController = navigationControl.viewControllers.first as! BookViewController
        
            // Getting the cell that called for this segue
            if let selectedMomentCell = sender as? MomentTableViewCell {
                
                /// Currently selected index path.
                let indexPath = tableView.indexPath(for: selectedMomentCell)!
                
              
                var pages: [MomentViewController] = []
                    
                // Making the array of view controllers
                for i in 0..<moments.count {
                    let storyboard = UIStoryboard(name: "Scrapbook", bundle: nil)
                    
                    let page = storyboard.instantiateViewController(withIdentifier: "page") as! MomentViewController
                    page.moment = moments[i]
                    pages.append(page)
                    page.navigationBarHeight = navigationController!.navigationBar.frame.height
                }
                
                momentPageViewController.pages = pages
                
                // Setting the initial page based on which cell was selected
                let firstPage = pages[indexPath.row]
                
                momentPageViewController.setViewControllers([firstPage], direction: UIPageViewControllerNavigationDirection.forward, animated: true, completion: nil)
            }

        } else if segue.identifier == "AddItem" {
            print("an item is being added")
            let momentViewController = navigationControl.viewControllers.first as! MomentViewController
            
            momentViewController.scrapbook = scrapbook
        }
        
        // Resetting the filter from the search bar.
        searchBar.text = nil
        tableView.reloadData()
    }
    
    // Helps return to the table of contents view
    @IBAction func unwindToTableOfContentsID(sender: UIStoryboardSegue) {

        // Checking if a moment is supposed to be added
        if let sourceViewController = sender.source as? MomentViewController,
            let moment = sourceViewController.moment {
            
            print("Sender is MomentViewController")
            
            // Adding the moment
            scrapbook.insertIntoMoments(moment, at: scrapbook.moments.count)
        }
        
        // Saving the changes to the stack
        CoreDataStack.shared.saveContext()
        
        // Refreshing the view.
        tableView.reloadData()
    }
    
    @IBAction func backButtonTapped(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
}


// MARK: - UISearchBarDelegate Methods
extension MomentTableViewController: UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        endSearch()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        tableView.reloadData()
    }
    
    /// Resigns the keyboard of the searchBar if the screen is tapped.
    @objc func endSearch() {
        if searchBar.isFirstResponder {
            
            // Removing the keyboard
            searchBar.endEditing(true)
        }
    }
}


// MARK: - Toolbar Related
extension MomentTableViewController {
    
    // Overriding so we can change the view when it begins editing
    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        
        if editing {
            toolbarManager.editingModeToolbarSetup()
        } else {
            toolbarManager.regularModeToolbarSetup(withLockStatus: scrapbook.isLocked)
        }
    }
    
    @objc func addLock() {
        
        let lockAddedAlert = UIAlertController(title: "Lock Scrapbook?", message: "Locking adds Touch ID security for accessing your scrapbook.", preferredStyle: .alert)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        let lockAction = UIAlertAction(title: "Lock", style: .destructive, handler: { [unowned self] _ in
            
            LockingManager.shared.changeLockStatus(forScrapbook: self.scrapbook, to: true)
            
            let lockResponseAlert = UIAlertController(title: "Scrapbook Locked", message: "You now need to enter Touch ID to access \'\(self.scrapbook.name!)\'.", preferredStyle: .alert)
            
            lockResponseAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            
            self.present(lockResponseAlert, animated: true)
        })
        
        lockAddedAlert.addAction(cancelAction)
        lockAddedAlert.addAction(lockAction)
        
        present(lockAddedAlert, animated: true)
    }
    
    
    @objc func removeLock() {
        
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
    
    
    @objc func trashScrapbook() {
        
        let scrapbookDeletionWarning = UIAlertController(title: "Delete Scrapbook?", message: "Warning! Your book and moments will be lost forever!", preferredStyle: .alert)
        
        let deleteAction = UIAlertAction(title: "Delete", style: .destructive, handler: { [unowned self] _ in
            
            let context = CoreDataStack.shared.persistentContainer.viewContext
            context.delete(self.scrapbook)
            CoreDataStack.shared.saveContext()
            
            self.dismiss(animated: true, completion: { _ in
                
                let deletionSuccessAlert = UIAlertController(title: "Scrapbook Deleted!", message: nil, preferredStyle: .alert)
                deletionSuccessAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                
                UIApplication.shared.keyWindow?.rootViewController?.present(deletionSuccessAlert, animated: true)
            })
        })
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        scrapbookDeletionWarning.addAction(cancelAction)
        scrapbookDeletionWarning.addAction(deleteAction)
        
        present(scrapbookDeletionWarning, animated: true)
    }
    
    
    /// Initial prompt to ask the user if they want to add a cover photo.
    func promptForCoverPhoto() {
        
        let prompt = UIAlertController(title: "Select Cover for \(scrapbook.name!)?", message: "Would you like to choose a cover photo for your scrapbook?", preferredStyle: .alert)
        
        prompt.addAction(UIAlertAction(title: "Not Now", style: .cancel, handler: nil))
        prompt.addAction(UIAlertAction(title: "Sure", style: .default, handler: { [unowned self] _ in
            self.selectCoverPhoto()
        }))
        
        present(prompt, animated: true)
    }
    
    
    @objc func selectCoverPhoto() {
        
        let imagePicker = UIImagePickerController()
        imagePicker.sourceType = .photoLibrary
        imagePicker.allowsEditing = true
        imagePicker.delegate = self
        present(imagePicker, animated: true)
        
    }

}

// MARK: - ImagePickerControllerDelegate Methods
extension MomentTableViewController: UIImagePickerControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        let pickedPicture = info[UIImagePickerControllerEditedImage] as! UIImage
        scrapbook.coverPhoto = pickedPicture
        
        // Maybe put handle error here for case where picture is not successfully saved?
        
        let coverPictureSuccessAlert = UIAlertController(title: "Great Choice!", message: "Your cover photo has been saved.", preferredStyle: .alert)

        coverPictureSuccessAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        
        dismiss(animated: true, completion: {[unowned self] in
            self.present(coverPictureSuccessAlert, animated: true)
        })
        
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
}

// MARK: - Empty UINavigationControllerDelegate Conformance
extension MomentTableViewController: UINavigationControllerDelegate {}




