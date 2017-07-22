//
//  LibraryViewController.swift
//  Scrapbook
//
//  Created by Dev User on 2017-07-20.
//  Copyright © 2017 Alan Li. All rights reserved.
//

import UIKit

class LibraryViewController: UIViewController {
    
    @IBOutlet weak var scrapbookCollectionView: UICollectionView!
    
    var scrapbooks: [Scrapbook] = []
    
    func makeSampleScrapbook() {
        let scrapbook1 = Scrapbook("scrapbook1", #imageLiteral(resourceName: "DefaultPhoto"))
        scrapbooks.append(scrapbook1)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        scrapbookCollectionView.delegate = self
        scrapbookCollectionView.dataSource = self
        
        if scrapbooks.isEmpty{
            makeSampleScrapbook()
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

}

extension LibraryViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if indexPath.item == scrapbooks.count {
            // Start a new scrapbook here
            let newScrapbook = Scrapbook("haha", #imageLiteral(resourceName: "DefaultPhoto"))
            scrapbooks.append(newScrapbook)
            
            collectionView.reloadData()
            
        } else {
            // Go edit an existing scrapbook here
            
            let newStoryboard = UIStoryboard(name: "Scrapbook", bundle: nil)
            
            let startViewController = newStoryboard.instantiateInitialViewController() as! UINavigationController
            
            let scrapbook = scrapbooks[indexPath.item]
            
            startViewController.title = scrapbook.title
            
            let momentTableViewController = startViewController.topViewController! as! MomentTableViewController
            
            momentTableViewController.moments = scrapbook.moments
            
            present(startViewController, animated: true, completion: nil)
        }
    }
}

extension LibraryViewController: UICollectionViewDataSource {
    @available(iOS 6.0, *)
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ScrapbookCell", for: indexPath) as! ScrapbookViewCell
        
        if indexPath.item == scrapbooks.count {
            cell.scrapbook = Scrapbook.placeholder
        } else {
            cell.scrapbook = scrapbooks[indexPath.item]
        }
        cell.setup()
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return scrapbooks.count + 1
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
}



















