//
//  MomentTableViewController.swift
//  Scrapbook
//
//  Created by Alan Li on 2016-11-23.
//  Copyright © 2016 Alan Li. All rights reserved.
//

import UIKit

class MomentTableViewController: UITableViewController {

    // MARK: Outlets and Properties 
    
    /// The searchbar to allow users to filter results in the root tableview.
    @IBOutlet weak var searchBar: UISearchBar!
    
    /// A gesture recognizer to allow searchBar keyboard to be dismissed on tap.
    private var endSearchRecognizer: UITapGestureRecognizer!
    
    /// A collection of all the moments belonging to this scrapbook.
    var moments = [Moment]()
    
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
        let navBarAppearance = navigationController?.navigationBar
        navBarAppearance?.isTranslucent = true
        navBarAppearance?.barTintColor = UIColor.lightText
        
        // Adding the edit button programmatically
        navigationItem.leftBarButtonItem = editButtonItem
        
        // Setting up the UISearchBar
        searchBar.delegate = self
        searchBar.returnKeyType = .default
        //tableView.tableHeaderView = searchBar
        
        // Making so that the initial view has the searchBar hidden (scrolled above to the navbar)
        let topPosition = CGPoint(x: 0, y: searchBar.frame.height)
        
        tableView.setContentOffset(topPosition, animated: false)
        
        // Loads any saved data, else loads the sample data
        if let savedMoments = loadMoments() {
            moments += savedMoments
        }

        // Uncomment the following line to preserve selection between presentations
        // clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // navigationItem.rightBarButtonItem = editButtonItem()
        
        // Adding a touch gesture recognizer to resign the keyboard on tap.
        
        let searchKeyboardDismisser = UITapGestureRecognizer(target: self, action: #selector(endSearch))
        searchKeyboardDismisser.cancelsTouchesInView = false
        
        tableView.addGestureRecognizer(searchKeyboardDismisser)
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
        
        // Adjusting photo resizing
        cell.photoImageView.contentMode = .scaleAspectFit
        
        // Setting cell values
        cell.photoNameLabel.text = moment.name
        cell.photoImageView.image = moment.photo
        cell.captionTextView.text = moment.caption
        
        cell.captionTextView.textContainer.maximumNumberOfLines = 8
        cell.captionTextView.textContainer.lineBreakMode = .byTruncatingTail
        
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
            
            moments.remove(at: indexPath.row)
            saveMoments()
            tableView.deleteRows(at: [indexPath], with: .fade)
            
        } 
    }
 
    
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {
        
        print("changed from row \(fromIndexPath.row) to row \(to.row)")
        
        // This is the function that allows you to press 'Edit' and then drag to rearrange cells. 
        // Thus: change your data arrangement here! (To correspond with the user's changes)
        
        /// The original row of the moment being moved.
        let originalRow = fromIndexPath.row
        
        /// The new row where the moment will reside.
        let newRow = to.row
        
        /// The moment being moved.
        let firstMoment = moments[originalRow]
        
        // O(n) Implementation of swapping out the corrent moment and replacing it at the right place
        moments.remove(at: originalRow)
        moments.insert(firstMoment, at: newRow)
    }

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    
    // MARK: Navigation

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
                    let page = storyboard?.instantiateViewController(withIdentifier: "page") as! MomentViewController
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
            
            // Adding the moment
            let newIndexPath = IndexPath(row: 0, section: 0)
            moments.insert(moment, at: 0)
            tableView.insertRows(at: [newIndexPath], with: .bottom)
        }
        
        saveMoments()
    }
}

// MARK: NSCoding Methods
extension MomentTableViewController {
    
    func saveMoments() {
        
        let isSuccessfulSave = NSKeyedArchiver.archiveRootObject(moments, toFile: Moment.archiveURL.path)
        if !isSuccessfulSave {
            print("failed to save")
        }
    }
    
    func loadMoments() -> [Moment]? {
        return NSKeyedUnarchiver.unarchiveObject(withFile: Moment.archiveURL.path) as? [Moment]
    }
}

// MARK: UISearchBarDelegate Methods
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







