//
//  LibraryViewController.swift
//  Scrapbook
//
//  Created by Dev User on 2017-07-20.
//  Copyright © 2017 Alan Li. All rights reserved.
//

import UIKit
import CoreData

class LibraryViewController: UIViewController {
    
    @IBOutlet weak var scrapbookCollectionView: UICollectionView!
    
    fileprivate var fetchedResultsController: NSFetchedResultsController<NSFetchRequestResult>!
    
    var scrapbooks: [Scrapbook]? {
        get {
            if let scrapbooks = fetchedResultsController.fetchedObjects as? [Scrapbook] {
                return scrapbooks
            } else {
                return nil
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        scrapbookCollectionView.delegate = self
        scrapbookCollectionView.dataSource = self
        
        initializeFetchedResultsController()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

    /// Sets up the fetched results controller as well as performs the initial fetch.
    private func initializeFetchedResultsController() {
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: String(describing: Scrapbook.self))
        
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "title", ascending: true)]
        
        let managedObjectContext = CoreDataStack.shared.persistentContainer.viewContext
        let controller = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: managedObjectContext , sectionNameKeyPath: nil, cacheName: nil)
        
        fetchedResultsController = controller
        
        do {
            try fetchedResultsController.performFetch()
        } catch let error  {
            print("ERROR: \(error)")
        }
    }
}

extension LibraryViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        var scrapbook: Scrapbook!
        
        if (scrapbooks == nil) || indexPath.item == scrapbooks!.count {
            
            // Start a new scrapbook here
            scrapbook = SBDataManager.createScrapbookEntityWith(title: "New Scrapbook", coverPhotoName: "placeholder") as! Scrapbook
        } else {
        
            // Getting an existing scrapbook here
            scrapbook = scrapbooks![indexPath.item]
        }
        let newStoryboard = UIStoryboard(name: "Scrapbook", bundle: nil)
        
        let startViewController = newStoryboard.instantiateInitialViewController() as! UINavigationController
        
        startViewController.title = scrapbook.title
        
        let momentTableViewController = startViewController.topViewController! as! MomentTableViewController
        
        momentTableViewController.scrapbook = scrapbook
        
        present(startViewController, animated: true, completion: nil)
        
    }
}

extension LibraryViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ScrapbookCell", for: indexPath) as! ScrapbookViewCell
        
        if indexPath.item == fetchedResultsController.fetchedObjects!.count {
            
            cell.coverImageView.image = #imageLiteral(resourceName: "DefaultPhoto")
            cell.scrapbookTitleLabel.text = "Add a Scrapbook"
        } else {
         
            let scrapbook = fetchedResultsController.object(at: indexPath) as! Scrapbook
            cell.setup(withScrapbook: scrapbook)
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        guard let sections = fetchedResultsController.sections else {
            fatalError("No sections...")
        }
        let sectionInfo = sections[section]
        return sectionInfo.numberOfObjects + 1 // Plus one for the add scrapbook.
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return fetchedResultsController.sections!.count
    }
}



















