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
    
    var moments = [Moment]()
    var pages = [MomentViewController]()
    var initialIndex: IndexPath?
    
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
        
        self.navigationItem.title = "Scrapbook"
        
        for i in 0...(moments.count - 1) {
            let page = storyboard?.instantiateViewController(withIdentifier: "page") as! MomentViewController
            page.moment = moments[i]
            pages.append(page)
        }
        
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
    
}
