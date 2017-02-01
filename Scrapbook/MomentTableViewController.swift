//
//  MomentTableViewController.swift
//  Scrapbook
//
//  Created by Alan Li on 2016-11-23.
//  Copyright © 2016 Alan Li. All rights reserved.
//

import UIKit

class MomentTableViewController: UITableViewController {

    // MARK: Properties 
    
    var moments = [Moment]()

    
    func loadSampleMoments() {
        
        let photo2 = UIImage(named: "test2")!
        let testMoment = Moment(name: "Flower From the Wall", photo: photo2, caption: "This is a sample caption. Scroll down to read! It's been two years, and they're still growing beautifully!")!
        
        moments += [testMoment]
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Setting navigation bar appearance
        let navBarAppearance = self.navigationController?.navigationBar
        navBarAppearance?.isTranslucent = true
        navBarAppearance?.barTintColor = UIColor.lightText
        
        // Adding the edit button programmatically
        self.navigationItem.leftBarButtonItem = self.editButtonItem
        
        // Loads any saved data, else loads the sample data
        if let savedMoments = loadMoments() {
            moments += savedMoments
        } else {
            loadSampleMoments()
        }

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
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
        
        let cellidentifier = "MomentTableViewCell"
        let cell = tableView.dequeueReusableCell(withIdentifier: cellidentifier, for: indexPath) as! MomentTableViewCell

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
 
        if let sourceViewController = sender.source as? BookViewController, let moment = sourceViewController.editedMoment {
            print("great success")
            if let selectedIndexPath = tableView.indexPathForSelectedRow {
                
                // Updating a moment in the array
                let indexChange = sourceViewController.indexTracker
                let newIndexRow = selectedIndexPath.row + indexChange
                moments[newIndexRow] = moment
                
                // Reloading the table to update the moment
                let newIndexPath = IndexPath(row: newIndexRow, section: 0)
                
                /*Enabling correct cell animation/selectionflash
                let cellidentifier = "MomentTableViewCell"
                let cell = tableView.dequeueReusableCell(withIdentifier: cellidentifier, for: newIndexPath) as! MomentTableViewCell
                cell.selectionStyle = UITableViewCellSelectionStyle.default */
                
                tableView.reloadRows(at: [newIndexPath], with: .right)
                
                // Save the moments
                saveMoments()
                return
            }
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

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

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
            
            print("a moment is being modified")
            
            let navigationControl = segue.destination as! UINavigationController
            
            let momentPageViewController = navigationControl.viewControllers.first as! BookViewController
            
        
            // Getting the cell that called for this segue
            if let selectedMomentCell = sender as? MomentTableViewCell {
                
                let indexPath = tableView.indexPath(for: selectedMomentCell)!
                momentPageViewController.initialIndex = indexPath
                momentPageViewController.moments = moments
                
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













