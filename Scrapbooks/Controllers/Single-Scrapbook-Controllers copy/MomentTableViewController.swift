//
//  MomentTableViewController.swift
//  Scrapbook
//
//  Created by Alan Li on 2016-11-23.
//  Copyright © 2016 Alan Li. All rights reserved.
//

import UIKit
import CoreData

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
        
        // Setting navigation bar appearance
        let navBarAppearance = navigationController!.navigationBar
        navBarAppearance.isTranslucent = true
        navBarAppearance.barTintColor = UIColor.lightText
        navBarAppearance.titleTextAttributes = [NSFontAttributeName: UIFont(name: "Futura", size: 20) as Any]
        
        // Setting up the UISearchBar
        searchBar.delegate = self
        searchBar.returnKeyType = .default
        //tableView.tableHeaderView = searchBar
        
        // Making so that the initial view has the searchBar hidden (scrolled above to the navbar)
        let topPosition = CGPoint(x: 0, y: searchBar.frame.height)
        
        tableView.setContentOffset(topPosition, animated: false)
        
        // Uncomment the following line to preserve selection between presentations
        // clearsSelectionOnViewWillAppear = false
        
        // Adding a touch gesture recognizer to resign the keyboard on tap.
        let searchKeyboardDismisser = UITapGestureRecognizer(target: self, action: #selector(endSearch))
        searchKeyboardDismisser.cancelsTouchesInView = false
        
        tableView.addGestureRecognizer(searchKeyboardDismisser)
        
        toolbarSetup()
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


    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            
            scrapbook.properlyRemove(moment: moments[indexPath.row])
            CoreDataStack.shared.saveContext()
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
        
        if editingStyle == .insert {
            
        }
    }
    
    /*
    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        // Can use to add in social media or other custom row actions..
    }*/
 
    
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

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "ShowDetail" {
            // Book is being shown
            
            let navigationControl = segue.destination as! UINavigationController
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
            // Just an output to help with debugging
            print("an item is being added")
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
            scrapbook.addToMoments(moment)
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
    
    /// Contains code that sets up the UIToolBar
    fileprivate func toolbarSetup() {
        
        let deleteScrapbookButton = UIBarButtonItem(barButtonSystemItem: .trash, target: self, action: #selector(trashScrapbook))
        
        let addCoverPhotoButton = UIBarButtonItem(title: "Add Cover Photo", style: .plain, target: self, action: #selector(selectCoverPhoto))
        
        let space = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        // Maybe there can be an import feature added here in the future too... for people to import photos en masse and add captions one by one.
        
        toolbarItems = [deleteScrapbookButton, space, addCoverPhotoButton, space, editButtonItem]
        navigationController?.isToolbarHidden = false
    }
    
    @objc private func trashScrapbook() {
        
        let scrapbookDeletionWarning = UIAlertController(title: "Delete Scrapbook?", message: "Warning! Your book and moments will be lost forever!", preferredStyle: .alert)
        
        let deleteAction = UIAlertAction(title: "Delete", style: .destructive, handler: { [unowned self] _ in
            
            let context = CoreDataStack.shared.persistentContainer.viewContext
            context.delete(self.scrapbook)
            CoreDataStack.shared.saveContext()
            
            let deletionSuccessAlert = UIAlertController(title: "Scrapbook Deleted!", message: nil, preferredStyle: .alert)
            let OKAction = UIAlertAction(title: "OK", style: .default, handler: { [unowned self] _ in
                self.dismiss(animated: true, completion: nil)
            })
            deletionSuccessAlert.addAction(OKAction)
            
            self.present(deletionSuccessAlert, animated: true)
        })
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        scrapbookDeletionWarning.addAction(cancelAction)
        scrapbookDeletionWarning.addAction(deleteAction)
        
        present(scrapbookDeletionWarning, animated: true)
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
        
        let coverPictureSuccessAlert = UIAlertController(title: "Great Choice!", message: "Your cover photo has been sucessfully stored.", preferredStyle: .alert)
        let OKAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        
        coverPictureSuccessAlert.addAction(OKAction)
        
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




