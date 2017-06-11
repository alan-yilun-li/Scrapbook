//
//  BookViewController.swift
//  Scrapbook
//
//  Created by Alan Li on 2017-01-18.
//  Copyright © 2017 Alan Li. All rights reserved.
//

import Foundation
import UIKit

class BookViewController: UIPageViewController, UIPageViewControllerDataSource, UIPageViewControllerDelegate {
    
    
    //MARK: Properties
    
    /// The button that saves the moment being edited.
    @IBOutlet weak var SaveButton: UIBarButtonItem!
    
    /// Array to hold the pages that represent each momentViewController
    var pages = [MomentViewController]() //
    
    /// Index representing the current page number the user is viewing.
    /// - Note: Is initialized to -1 to cause a crash if it is not otherwise set.
    var currentIndex: Int = -1
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        delegate = self
        dataSource = self
        
        // Navigationbar UI Specifications
        navigationItem.title = "Scrapbook"
        let navBarAppearance = navigationController?.navigationBar
        navBarAppearance?.isTranslucent = true
        navBarAppearance?.barTintColor = UIColor.lightText
        
        // Setting the initial page based on which cell was selected
        let firstPage = pages[currentIndex]
        
        setViewControllers([firstPage], direction: UIPageViewControllerNavigationDirection.forward, animated: true, completion: nil)
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        
        let priorIndex = currentIndex - 1
        
        if priorIndex >= 0 {
            currentIndex -= 1
            return pages[priorIndex]
        } else { return nil }
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        
        let nextIndex = currentIndex + 1
        
        if nextIndex < pages.count {
            currentIndex += 1
            return pages[nextIndex]
        } else { return nil }
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, willTransitionTo pendingViewControllers: [UIViewController]) {
        // Change transition behaviour here.
        
        // Forcing the current view to hide all keyboards before transition
        (pageViewController.viewControllers![0] as! MomentViewController).forceHideKeyboard()
    }
    
    // MARK: Actions
   
    @IBAction func Save(_ sender: UIBarButtonItem) {
        performSegue(withIdentifier: "unwindToTableOfContentsID", sender: self)
    }
    
    @IBAction func Return(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
    
     // MARK: Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "unwindToTableOfContentsID", let currentViewController = viewControllers![0] as? MomentViewController, let table = segue.destination as? MomentTableViewController {
            
            // Hiding the keyboard
            currentViewController.nameTextField.resignFirstResponder()
            currentViewController.captionTextView.resignFirstResponder()
            
            // Set the moment to be passed to the table view controller after the segue
            let name = currentViewController.nameTextField.text
            let photo = currentViewController.photoImageView.image
            let caption = currentViewController.captionTextView.text
            
            table.moments[currentIndex] = Moment(name: name!, photo: photo, caption: caption!)!
        }
    }

}
