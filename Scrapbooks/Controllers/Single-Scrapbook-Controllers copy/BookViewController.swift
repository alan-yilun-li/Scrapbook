//
//  BookViewController.swift
//  Scrapbook
//
//  Created by Alan Li on 2017-01-18.
//  Copyright © 2017 Alan Li. All rights reserved.
//

import Foundation
import UIKit

class BookViewController: UIPageViewController {
    
    //MARK: - Properties
    
    /// The button that saves the moment being edited.
    @IBOutlet weak var SaveButton: UIBarButtonItem!
    
    /// Array to hold the pages that represent each momentViewController
    var pages = [MomentViewController]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        delegate = self
        dataSource = self
        
        // Navigationbar UI Specifications
        navigationItem.title = "Scrapbook"
        let navBarAppearance = navigationController?.navigationBar
        navBarAppearance?.isTranslucent = true
        navBarAppearance?.barTintColor = UIColor.lightText
        
        // Page related setup is in the prepare navigation function in MomentTableViewController
    }
    
    // MARK: - Actions
   
    @IBAction func Save(_ sender: UIBarButtonItem) {
        performSegue(withIdentifier: "unwindToTableOfContentsID", sender: self)
    }
    
    @IBAction func Return(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
    
     // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "unwindToTableOfContentsID", let currentViewController = viewControllers![0] as? MomentViewController, let table = segue.destination as? MomentTableViewController {
            
            // Hiding the keyboard
            currentViewController.nameTextField.resignFirstResponder()
            currentViewController.captionTextView.resignFirstResponder()
            
            // Updating the moment based on the changes made
            let currentIndex = pages.index(of: currentViewController)!
            let targetMoment = table.moments[currentIndex]
        
            targetMoment.name = currentViewController.nameTextField.text!
            targetMoment.caption = currentViewController.captionTextView.text
            targetMoment.photo = currentViewController.photoImageView.image!
        }
    }

}

// MARK: - UIPageViewControllerDataSource Methods
extension BookViewController: UIPageViewControllerDataSource {
    /*
     Note: I tried using a private global variable currentIndex to keep track in order to avoid the O(n) array.index(of:) from being run on every page turn... However, this results in some UI Bug with the UIPageViewController. Since people likely will not have thousands on thousands of moments in just one book, I've opted to play it safe with the O(n) implementation.
     */
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        
        let currentIndex = pages.index(of: viewController as! MomentViewController)!
        if currentIndex - 1 >= 0 {
            return pages[currentIndex - 1]
        } else { return nil }
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        
        let currentIndex = pages.index(of: viewController as! MomentViewController)!
        if currentIndex + 1 < pages.count {
            return pages[currentIndex + 1]
        } else { return nil }
    }
}


// MARK: - UIPageViewControllerDelegate Methods
extension BookViewController: UIPageViewControllerDelegate {
    
    func pageViewController(_ pageViewController: UIPageViewController, willTransitionTo pendingViewControllers: [UIViewController]) {
        // Forcing the current view to hide all keyboards before transition
        (pageViewController.viewControllers![0] as! MomentViewController).forceHideKeyboard()
    }
    
}
