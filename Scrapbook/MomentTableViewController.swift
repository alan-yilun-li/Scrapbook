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
        
        let photo1 = UIImage(named: "test1")!
        let moment1 = Moment(name: "Celebrating Her Scholarship!", photo: photo1, caption: "It was swell! Went over in the morning, brought some chocolates...")!
        
        let photo2 = UIImage(named: "test2")!
        let moment2 = Moment(name: "Flower From the Wall", photo: photo2, caption: "It's been two years, and they're still growing beautifully!")!
        
        let photo3 = UIImage(named: "test3")!
        let moment3 = Moment(name: "Being Silly", photo: photo3, caption: "Nothing much, just hanging out and it was a good moment")!
        
        moments += [moment1, moment2, moment3]
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadSampleMoments()

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

        cell.photoNameLabel.text = moment.name
        cell.photoImageView.image = moment.photo
        cell.captionTextView.text = moment.caption
        
        cell.captionTextView.textContainer.maximumNumberOfLines = 2;
        cell.captionTextView.textContainer.lineBreakMode = .byTruncatingTail;

        return cell
    }
    
    // Helps return to the table of contents view

    
    
    @IBAction func unwindToTableOfContentsID(sender: UIStoryboardSegue) {
     
        // Checking if a moment is supposed to be added
            print("segue working")
        
        if let sourceViewController = sender.source as? MomentViewController,
            let moment = sourceViewController.moment {
            
            if let selectedIndexPath = tableView.indexPathForSelectedRow {
                
                // Update an existing moment
                moments[selectedIndexPath.row] = moment
                tableView.reloadRows(at: [selectedIndexPath], with: .none)
            }
            
            else {
                
                // Adding the moment
                let newIndexPath = IndexPath(row: moments.count, section: 0)
                moments.append(moment)
                tableView.insertRows(at: [newIndexPath], with: .bottom)
                
                print("moment added")
            }
        }
    }

    
    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

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
            
            let momentDetailViewController = segue.destination as! MomentViewController
            
            // Getting the cell that called for this segue
            if let selectedMomentCell = sender as? MomentTableViewCell {
                
                let indexPath = tableView.indexPath(for: selectedMomentCell)!
                let selectedMoment = moments[indexPath.row]
                momentDetailViewController.moment = selectedMoment
            }
        }
            
        else if segue.identifier == "AddItem" {
            // Just an output to help with debugging
            print("an item is being added")
        }
    }
}
