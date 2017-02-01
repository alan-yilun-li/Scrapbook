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
    
    @IBOutlet weak var SaveButton: UIBarButtonItem!
    var editedMoment: Moment?
    var moments = [Moment]()
    var pages = [MomentViewController]()
    var initialIndex: IndexPath?
    var indexTracker: Int = 0
    
    func indexOfPage (page: MomentViewController, pages: [MomentViewController], accumulator: Int) -> Int {
        let targetMoment = page.moment
        
        if accumulator >= pages.count {
            return -1
        } else if (targetMoment?.hasSameProperties(moment: pages[accumulator].moment!))! {
            return accumulator
        } else {
            return indexOfPage(page: page, pages: pages, accumulator: accumulator + 1)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.delegate = self
        self.dataSource = self
        
        // Navigationbar UI Specifications
        self.navigationItem.title = "Scrapbook"
        let navBarAppearance = self.navigationController?.navigationBar
        navBarAppearance?.isTranslucent = true
        navBarAppearance?.barTintColor = UIColor.lightText
    
        // Making the array of view controllers
        for i in 0...(moments.count - 1) {
            let page = storyboard?.instantiateViewController(withIdentifier: "page") as! MomentViewController
            page.moment = moments[i]
            pages.append(page)
        }
        
        // Setting the initial page based on which cell was selected
        let firstPage = storyboard?.instantiateViewController(withIdentifier: "page") as! MomentViewController
        firstPage.moment = moments[initialIndex!.row]
        
        setViewControllers([firstPage], direction: UIPageViewControllerNavigationDirection.forward, animated: true, completion: nil)
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        
        print(pages.count)
        let currentIndex = indexOfPage(page: viewController as! MomentViewController, pages: pages, accumulator: 0)
        let priorIndex = currentIndex - 1
        
        if priorIndex >= 0 {
            return pages[priorIndex]
        } else { return nil }
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        let currentIndex = indexOfPage(page: viewController as! MomentViewController, pages: pages, accumulator: 0)
        let nextIndex = currentIndex + 1
        
        if nextIndex < pages.count {
            return pages[nextIndex]
        } else { return nil }
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, willTransitionTo pendingViewControllers: [UIViewController]) {
        let currentViewController = pageViewController.viewControllers?[0] as? MomentViewController
        currentViewController?.scrollToTop()
        let currentIndex = indexOfPage(page: currentViewController!, pages: pages, accumulator: 0)
        let nextIndex = indexOfPage(page: (pendingViewControllers[0] as? MomentViewController)!, pages: pages, accumulator: 0)
        indexTracker += (nextIndex - currentIndex)
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
        
        if segue.identifier == "unwindToTableOfContentsID", let currentViewController = self.viewControllers![0] as? MomentViewController {
            
            // Hiding the keyboard
            currentViewController.nameTextField.resignFirstResponder()
            currentViewController.captionTextView.resignFirstResponder()
            
            // Set the moment to be passed to the table view controller after the segue
            let name = currentViewController.nameTextField.text
            let photo = currentViewController.photoImageView.image
            let caption = currentViewController.captionTextView.text
            
            editedMoment = Moment(name: name!, photo: photo, caption: caption!)
        }
    }

}
