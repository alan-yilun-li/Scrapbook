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
    
    /// The base collection view of the controller.
    @IBOutlet weak var scrapbookCollectionView: UICollectionView!
    
    /// The fetchedResultsController which fetches and manages goodies from core data.
    fileprivate var fetchedResultsController: NSFetchedResultsController<NSFetchRequestResult>!
    
    /// An alert controller presented so the user can name their new scrapbook.
    fileprivate var newScrapbookAlert: UIAlertController!
    
    /// An array of scrapbooks that the user currently has.
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
        
        navigationItem.leftBarButtonItem = editButtonItem
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        print("view will appear")
        
        do {
            try fetchedResultsController.performFetch()
            scrapbookCollectionView.reloadData()
        } catch let error  {
            print("FETCH FAILED ERROR: \(error)")
        }
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
            print("FETCH2 FAILED ERROR: \(error)")
        }
    }
}


// MARK: - UICollectionViewDelegate Methods
extension LibraryViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if isEditing {
            // Use this to be able to select and delete tables later on
        }
        
        if (scrapbooks == nil) || indexPath.item == scrapbooks!.count {
          
            if newScrapbookAlert == nil {
                initializeMakeScrapbookAlert()
            } else {
                newScrapbookAlert.textFields![0].text = ""
            }
            
            present(newScrapbookAlert, animated: true)
            
        } else {
        
            print("accessing an old scrapbook")
            let scrapbook = scrapbooks![indexPath.item]
            present(scrapbook: scrapbook)
        }
    }
    
    
    fileprivate func present(scrapbook: Scrapbook) {
        
        let newStoryboard = UIStoryboard(name: "Scrapbook", bundle: nil)
        
        let startViewController = newStoryboard.instantiateInitialViewController() as! UINavigationController
        
        let momentTableViewController = startViewController.topViewController! as! MomentTableViewController
        momentTableViewController.navigationItem.title = scrapbook.title
        momentTableViewController.scrapbook = scrapbook
        
        present(startViewController, animated: true, completion: nil)
    }
}


// MARK: - UICollectionViewDataSource Methods
extension LibraryViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ScrapbookCell", for: indexPath) as! ScrapbookViewCell
        
        if indexPath.item == fetchedResultsController.fetchedObjects!.count {
            
            cell.coverImageView.image = #imageLiteral(resourceName: "DefaultPhoto")
            cell.scrapbookTitleLabel.text = "Add Scrapbook"
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


// MARK: - UIAlertController Setup and Textfield Methods
extension LibraryViewController {
    
    func initializeMakeScrapbookAlert() {
        
        print("creating a new scrapbook")
        newScrapbookAlert = UIAlertController(title: "Create a New Scrapbook", message: "Pick a name for your new Scrapbook!", preferredStyle: .alert)
        
        newScrapbookAlert.addTextField(configurationHandler: { [unowned self] (textfield) in
            
            textfield.placeholder = "Enter your scrapbook's name here."
            
            textfield.addTarget(self, action: #selector(self.textFieldChanged), for: UIControlEvents.editingChanged)
        })
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        let continueAction = UIAlertAction(title: "Continue", style: .default, handler: { [unowned self] _ in
            
            let potentialTitle = self.newScrapbookAlert.textFields![0].text!
            
            if potentialTitle.isUniqueTitle(amongScrapbooks: self.scrapbooks) {
                
                let scrapbook = SBDataManager.createScrapbookEntityWith(title: potentialTitle) as! Scrapbook
                
                CoreDataStack.shared.saveContext()
                
                self.present(scrapbook: scrapbook)
                
            } else {
                
                let uniquenessAlert = UIAlertController(title: "Name Already Taken", message: "Please choose a new name that you haven't already used.", preferredStyle: .alert)
                let returnAction = UIAlertAction(title: "Return", style: .default, handler: {
                    [unowned self] _ in
                    
                    self.newScrapbookAlert.textFields![0].text = ""
                    self.present(self.newScrapbookAlert, animated: true)
                    
                })
                uniquenessAlert.addAction(returnAction)
                
                self.present(uniquenessAlert, animated: true)
            }
        })
        
        continueAction.isEnabled = false
        
        newScrapbookAlert.addAction(cancelAction)
        newScrapbookAlert.addAction(continueAction)
    }
    
    
    func textFieldChanged(_ textfield: UITextField) {
        let text = textfield.text ?? ""
        let continueAction = newScrapbookAlert.actions[1]
        
        continueAction.isEnabled = (text != "")
    }
}


// MARK: - Scrapbook-Name Uniqueness Functions
extension String {
    
    func isUniqueTitle(amongScrapbooks scrapbooks: [Scrapbook]?) -> Bool {
        
        let books = scrapbooks ?? []
        
        for scrapbook in books {
            if self == scrapbook.title! {
                return false
            }
        }
        return true
    }
}











