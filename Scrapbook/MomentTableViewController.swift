//
//  MomentTableViewController.swift
//  Scrapbook
//
//  Created by Alan Li on 2016-11-23.
//  Copyright © 2016 Alan Li. All rights reserved.
//

import UIKit

class MomentTableViewController: UITableViewController, UISearchBarDelegate {

    // MARK: Outlets and Properties 
    
    /// The searchbar to allow users to filter results in the root tableview.
    @IBOutlet weak var searchBar: UISearchBar!
    
    /// The array of moments with which to populate the table.
    var moments = [Moment]()

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
        //tableView.tableHeaderView = searchBar
        
        
        // Loads any saved data, else loads the sample data
        if let savedMoments = loadMoments() {
            moments += savedMoments
        }

        // Uncomment the following line to preserve selection between presentations
        // clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // navigationItem.rightBarButtonItem = editButtonItem()
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
        return moments.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        /// Reuse identifier for a cell to store a moment.
        let cellidentifier = Constants.momentTableViewCellIdentifier
        
        /// Cell retrieved by using the reuse identifier.
        let cell = tableView.dequeueReusableCell(withIdentifier: cellidentifier, for: indexPath) as! MomentTableViewCell

        /// The appropriate moment corresponding to the cell
        let moment = moments[indexPath.row]
        print(indexPath.row)
        print(moments.count)

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
    
    
    
    // Helps return to the table of contents view

    @IBAction func unwindToTableOfContentsID(sender: UIStoryboardSegue) {
     
        print("segue working")
        
        // Checking if a moment is supposed to be added
        if let sourceViewController = sender.source as? MomentViewController,
            let moment = sourceViewController.moment {
            
            // Adding the moment
            let newIndexPath = IndexPath(row: 0, section: 0)
            moments.insert(moment, at: 0)
            tableView.insertRows(at: [newIndexPath], with: .bottom)
            print("moment added")
            
            // Save the moments
            saveMoments()
            return
        }
 
        if let sourceViewController = sender.source as? BookViewController {
            print("great success")
            
            // Reloading the table to update the moment
            let newIndexRow = sourceViewController.currentIndex
            let newIndexPath = IndexPath(row: newIndexRow, section: 0)
            
            tableView.reloadRows(at: [newIndexPath], with: .right)
            
            // Save the moments
            saveMoments()
            return
        }
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
            
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
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

    
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "ShowDetail" {
            
            print("a moment is being modified")
            
            let navigationControl = segue.destination as! UINavigationController
            
            let momentPageViewController = navigationControl.viewControllers.first as! BookViewController
            
        
            // Getting the cell that called for this segue
            if let selectedMomentCell = sender as? MomentTableViewCell {
                
                let indexPath = tableView.indexPath(for: selectedMomentCell)!
                momentPageViewController.currentIndex = indexPath.row
                momentPageViewController.pages = {
                    
                    var pages: [MomentViewController] = []
                    
                    // Making the array of view controllers
                    for i in 0...(moments.count - 1) {
                        let page = storyboard?.instantiateViewController(withIdentifier: "page") as! MomentViewController
                        page.moment = moments[i]
                        pages.append(page)
                    }
                    
                    return pages
                }()
            }

        } else if segue.identifier == "AddItem" {
            // Just an output to help with debugging
            print("an item is being added")
        }
    }
    
    // MARK: NSCoding
    
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








