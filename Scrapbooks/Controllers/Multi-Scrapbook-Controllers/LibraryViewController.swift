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
    
    // MARK: - Storyboard Outlets
    
    /// The base collection view of the controller.
    @IBOutlet weak var scrapbookCollectionView: UICollectionView!
    
    // MARK: - Variables
    
    /// The fetchedResultsController which fetches and manages goodies from core data.
    private var fetchedResultsController: NSFetchedResultsController<NSFetchRequestResult>!
    
    /// An alert controller presented so the user can name their new scrapbook.
    private var newScrapbookAlert: UIAlertController!
    
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
    
    // MARK: - ViewController Life-Cycle Methods
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        do {
            try fetchedResultsController.performFetch()
            scrapbookCollectionView.reloadData()
        } catch let error  {
            print("FETCH FAILED ERROR: \(error)")
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        scrapbookCollectionView.delegate = self
        scrapbookCollectionView.dataSource = self
        
        LockingManager.forScrapbooks.delegate = self
        
        let toolBar = navigationController!.toolbar
        toolBar!.barTintColor = UIColor.scrapbooksYellow
        toolBar!.tintColor = UIColor.scrapbooksBrown
        
        let navBar = navigationController!.navigationBar
        ViewCustomizer.customize(navigationBar: navBar)
        
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
        
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
        
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
        
            let scrapbook = scrapbooks![indexPath.item]
            
            if scrapbook.isLocked {
                LockingManager.forScrapbooks.promptForID(forScrapbook: scrapbook)
            } else {
                present(scrapbook: scrapbook)
            }
        }
    }
    
    
    func present(scrapbook: Scrapbook, firstEntry: Bool = false) {
        
        let newStoryboard = UIStoryboard(name: "Scrapbook", bundle: nil)
        
        let startViewController = newStoryboard.instantiateInitialViewController() as! UINavigationController
        
        let momentTableViewController = startViewController.topViewController! as! MomentTableViewController
        momentTableViewController.navigationItem.title = scrapbook.name
        momentTableViewController.scrapbook = scrapbook
        
        // If first entry, prompt for cover photo; else, do nothing on completion
        present(startViewController, animated: true, completion: firstEntry ? { () in
            momentTableViewController.promptForCoverPhoto()
            } : nil)
    }
}


// MARK: - UICollectionViewDataSource Methods
extension LibraryViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
                
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ScrapbookCell", for: indexPath) as! ScrapbookViewCell
        
        if indexPath.item == fetchedResultsController.fetchedObjects!.count {
            
            cell.coverImageView.image = #imageLiteral(resourceName: "AddScrapbook")
            cell.scrapbookNameLabel.text = "Add Scrapbook"
            cell.refreshCellView(forScrapbook: nil)
            
        } else {
         
            let scrapbook = fetchedResultsController.object(at: indexPath) as! Scrapbook
            cell.setup(withScrapbook: scrapbook)
            cell.refreshCellView(forScrapbook: scrapbook)
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
        
        newScrapbookAlert = UIAlertController(title: "Create a New Scrapbook", message: "Pick a name for your new Scrapbook!", preferredStyle: .alert)
        
        newScrapbookAlert.addTextField(configurationHandler: { [unowned self] (textfield) in
            
            textfield.placeholder = "Enter your scrapbook's name here."
            textfield.autocapitalizationType = .words
            textfield.addTarget(self, action: #selector(self.textFieldChanged), for: UIControlEvents.editingChanged)
        })
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        let continueAction = UIAlertAction(title: "Continue", style: .default, handler: { [unowned self] _ in
            
            let potentialName = self.newScrapbookAlert.textFields![0].text!
            
            if potentialName.isUniqueName(among: self.scrapbooks) {
                
                let scrapbook = Scrapbook(context: CoreDataStack.shared.persistentContainer.viewContext)
                
                scrapbook.setup(withName: potentialName)
                
                CoreDataStack.shared.saveContext()
                
                self.present(scrapbook: scrapbook, firstEntry: true) 
                
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
    
    
    @objc func textFieldChanged(_ textfield: UITextField) {
        let text = textfield.text ?? ""
        let continueAction = newScrapbookAlert.actions[1]
        
        continueAction.isEnabled = (text != "")
    }
}







